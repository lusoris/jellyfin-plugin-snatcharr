# SPDX-FileCopyrightText: 2026 lusoris <lusoris@pm.me>
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Verification entrypoint. `make verify-all` is the universal gate praetor audits. The plugin
# has no C# code yet, so the gate covers the governance checks and the planted cases of the CI
# scripts; the .NET build and test targets join it with the plugin code (ADR-0028 in
# lusoris/SnatchArr).
-include .config/praetor/engine.mk

SHELL := /bin/sh
.SHELLFLAGS := -ec
.ONESHELL:
.DEFAULT_GOAL := help

.PHONY: help verify-all governance-verify ci-scripts-verify workflows-lint

help: ## Show this help
	@grep -hE '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-18s %s\n", $$1, $$2}'

verify-all: governance-verify ci-scripts-verify ## Every gate (praetor universal verification)
	@echo "All jellyfin-plugin-snatcharr verification gates passed."

governance-verify: ## Agent context, caveman sources, praetor audit
	$(PRAETORCTL) compile-context --verify
	$(PRAETORCTL) caveman check --configured-sources
	$(PRAETORCTL) audit

ci-scripts-verify: ## Planted cases of the CI scripts (no container image needed)
	sh .config/hooks/commit-msg_test.sh
	sh tools/ci/status_test.sh
	sh tools/ci/status.sh mirror .github/workflows/ci.yml
	sh tools/ci/semgrep_scan_test.sh
	python3 -I tools/ci/trivy_scan_test.py
	python3 -I -m py_compile tools/ci/secret_scan.py tools/ci/semgrep_scan.py tools/ci/trivy_scan.py tools/ci/trivy_scan_test.py

# Not part of verify-all: needs Docker, the network and a forge token (GH_TOKEN, read access).
# The CI job "workflows" runs it on every pull request.
workflows-lint: ## actionlint + pinned actions (zizmor) on every workflow file, with planted cases
	bash tools/ci/workflow-check_test.sh
	bash tools/ci/workflow-check.sh
