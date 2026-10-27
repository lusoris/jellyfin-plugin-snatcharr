#!/bin/sh
# SPDX-FileCopyrightText: 2026 lusoris <lusoris@pm.me>
# SPDX-License-Identifier: EUPL-1.2
#
# Planted cases for status.sh: job results with the verdict the rule must give, then the CI
# workflow against the rule table, unchanged and with one defect planted at a time.
#
#   tools/ci/status_test.sh
#
# Exit status: 0 every case behaved as recorded, 1 otherwise. Needs jq and awk.
set -eu

HERE="$(cd "$(dirname "$0")" && pwd)"
WORKFLOW="$HERE/../../.github/workflows/ci.yml"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

# Every job ran and succeeded.
ALL="$(jq -n '
  [ "workflows", "secret-scan", "semgrep", "trivy", "commits" ]
  | map({key: ., value: {result: "success", outputs: {}}}) | from_entries
')"
# Push or bot pull request: commits skipped.
COMMITS_SKIPPED="$(printf '%s' "$ALL" | jq '.commits.result = "skipped"')"

accepted=0
refused=0

# expect WANT NAME COMMITS_EXPECTED BASE [JQ EDIT [NEEDLE]]: the rule must exit WANT (0 or 1)
# on BASE after JQ EDIT, and name NEEDLE when it refuses.
expect() {
  want="$1" name="$2" commits="$3" needs="$(printf '%s' "$4" | jq -c "${5:-.}")" needle="${6:-}"
  got=0
  out="$(NEEDS="$needs" COMMITS_EXPECTED="$commits" sh "$HERE/status.sh" 2>&1)" || got=$?
  if [ "$got" -ne "$want" ]; then
    printf 'FAIL %s: exit %s, want %s\n%s\n' "$name" "$got" "$want" "$out" >&2
    exit 1
  fi
  case "$out" in
    *"$needle"*) ;;
    *)
      printf 'FAIL %s: refused without "%s"\n%s\n' "$name" "$needle" "$out" >&2
      exit 1
      ;;
  esac
  if [ "$want" -eq 0 ]; then accepted=$((accepted + 1)); else refused=$((refused + 1)); fi
  echo "ok   $name"
}

expect 0 "every job ran" true "$ALL"
expect 0 "bot pull request or push: commits skipped" false "$COMMITS_SKIPPED"

expect 1 "workflows failed" true "$ALL" '.workflows.result = "failure"' "job workflows: failure, must succeed"
expect 1 "workflows skipped" true "$ALL" '.workflows.result = "skipped"' "job workflows: skipped, must succeed"
expect 1 "secret-scan failed" true "$ALL" '.["secret-scan"].result = "failure"' "job secret-scan: failure, must succeed"
expect 1 "semgrep failed" true "$ALL" '.semgrep.result = "failure"' "job semgrep: failure, must succeed"
expect 1 "trivy failed" true "$ALL" '.trivy.result = "failure"' "job trivy: failure, must succeed"
expect 1 "commits skipped on a maintainer pull request" true "$ALL" \
  '.commits.result = "skipped"' "job commits: skipped, must succeed"
expect 1 "commits failed (draft)" true "$ALL" '.commits.result = "failure"' "job commits: failure, must succeed"
expect 1 "commits failed although not expected" false "$COMMITS_SKIPPED" \
  '.commits.result = "failure"' "job commits: failure, may only be skipped"
expect 1 "job without a rule" true "$ALL" \
  '.stray = {result: "success", outputs: {}}' "job stray: no rule in tools/ci/status.sh"
expect 1 "job missing from needs" true "$ALL" 'del(.trivy)' "job trivy: not in needs, must succeed"
expect 1 "results are not an object" true '[]' . "the job results could not be read"

# Unreadable input and a missing COMMITS_EXPECTED must not pass either.
for row in "empty results|true|1" "broken results|true|1" "commits expectation missing||2"; do
  name="${row%%|*}" rest="${row#*|}"
  needs="$ALL"
  [ "$name" = "empty results" ] && needs=""
  [ "$name" = "broken results" ] && needs="{"
  got=0
  NEEDS="$needs" COMMITS_EXPECTED="${rest%%|*}" sh "$HERE/status.sh" > /dev/null 2>&1 || got=$?
  if [ "$got" -ne "${rest#*|}" ]; then
    echo "FAIL $name: exit $got, want ${rest#*|}" >&2
    exit 1
  fi
  refused=$((refused + 1))
  echo "ok   $name"
done

# mirror_refuses NAME NEEDLE AWK_PROGRAM: the workflow with one planted edit must be refused.
mirror_refuses() {
  awk "$3" "$WORKFLOW" > "$WORK/ci.yml"
  if cmp -s "$WORKFLOW" "$WORK/ci.yml"; then
    echo "FAIL $1: the planted edit changed nothing" >&2
    exit 1
  fi
  if out="$(sh "$HERE/status.sh" mirror "$WORK/ci.yml" 2>&1)"; then
    printf 'FAIL %s: accepted\n%s\n' "$1" "$out" >&2
    exit 1
  fi
  case "$out" in
    *"$2"*) ;;
    *)
      printf 'FAIL %s: refused without "%s"\n%s\n' "$1" "$2" "$out" >&2
      exit 1
      ;;
  esac
  refused=$((refused + 1))
  echo "ok   $1"
}

sh "$HERE/status.sh" mirror "$WORKFLOW" > /dev/null
accepted=$((accepted + 1))
echo "ok   the CI workflow matches the rule table"

# Renovate keeps a version comment after the pinned sha of a reusable workflow.
awk '{ sub(/commit-policy\.yml@[0-9a-f]+$/, "& # v0.6.9"); print }' "$WORKFLOW" > "$WORK/ci.yml"
if cmp -s "$WORKFLOW" "$WORK/ci.yml"; then
  echo "FAIL version comment: the planted edit changed nothing" >&2
  exit 1
fi
sh "$HERE/status.sh" mirror "$WORK/ci.yml" > /dev/null
accepted=$((accepted + 1))
echo "ok   a version comment after the pinned sha"

mirror_refuses "job dropped from the needs of status" "job trivy: not needed by the status job" \
  '!/^      - trivy$/'
mirror_refuses "job that is not in the rule table" "job stray: no rule in tools/ci/status.sh" \
  '{ sub(/^  trivy:$/, "  stray:"); print }'
mirror_refuses "filter put on the workflows job" \
  "job workflows: the workflow does not carry the condition of its rule (always)" \
  '{ print } /^    name: Workflows / { print "    if: github.event_name == \047push\047" }'
mirror_refuses "status no longer runs always" 'status: must run with "if: always()"' \
  '{ sub(/^    if: always\(\)$/, "    if: success()"); print }'
mirror_refuses "commits condition differs from the expectation" \
  "job commits: the workflow does not carry the condition of its rule (commits)" \
  '/^    if: github.event_name == / { print "    if: github.event_name == \047pull_request\047"; next } { print }'
mirror_refuses "draft step dropped from the semgrep job" \
  'job semgrep: the first step is not "Stop on a draft pull request"' \
  '/^  semgrep:$/ { in_job = 1 } /^  [a-z-]+:$/ && !/^  semgrep:$/ { in_job = 0 }
   in_job && /^      - (name: Stop on a draft pull request|\*stop-draft)$/ { skip = 1; next }
   skip && /^      - / { skip = 0 } !skip { print }'
# The jobs share the step through the YAML anchor &stop-draft: an alias reads the anchor's name.
mirror_refuses "anchored draft step names another step" \
  'job semgrep: the first step is not "Stop on a draft pull request"' \
  'prev == "      - &stop-draft" { sub(/name: Stop on a draft pull request$/, "name: Stop early") }
   { print; prev = $0 }'
mirror_refuses "expectation of the commits job removed" "status: no COMMITS_EXPECTED expression" \
  '!/^ *COMMITS_EXPECTED: /'
mirror_refuses "reusable workflow ref is a tag" \
  'job commits: the first step is not "Stop on a draft pull request"' \
  '{ sub(/@2bf15d49f0eca695707a999808bccd988e2160e1/, "@v0.6.8"); print }'
mirror_refuses "reusable workflow is another file" \
  'job commits: the first step is not "Stop on a draft pull request"' \
  '{ sub(/commit-policy\.yml@/, "release-please-app.yml@"); print }'
mirror_refuses "reusable workflow is from another owner" \
  'job commits: the first step is not "Stop on a draft pull request"' \
  '{ sub(/lusoris\/SnatchArr\//, "someone/SnatchArr/"); print }'
mirror_refuses "reusable workflow ref is a short sha" \
  'job commits: the first step is not "Stop on a draft pull request"' \
  '{ sub(/@2bf15d49f0eca695707a999808bccd988e2160e1/, "@2bf15d49"); print }'

echo "status rule: $accepted accepted, $refused refused"
