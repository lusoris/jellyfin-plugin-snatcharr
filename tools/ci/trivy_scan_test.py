# SPDX-FileCopyrightText: 2026 lusoris <lusoris@pm.me>
# SPDX-License-Identifier: EUPL-1.2
"""Planted cases for SARIF validation in trivy_scan.py (no Docker needed).

Usage: python3 -I tools/ci/trivy_scan_test.py
"""

import json
import pathlib
import sys

HERE = pathlib.Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import trivy_scan  # noqa: E402

VALID_SARIF = {
    "version": "2.1.0",
    "runs": [
        {
            "tool": {
                "driver": {
                    "name": "Trivy"
                }
            },
            "results": []
        }
    ]
}


def test_positive_valid():
    raw = json.dumps(VALID_SARIF).encode("utf-8")
    trivy_scan.validate_sarif(raw)
    print("ok   positive: valid SARIF accepted")


def test_negative_wrong_tool():
    bad = {
        "version": "2.1.0",
        "runs": [
            {
                "tool": {
                    "driver": {
                        "name": "Gosec"
                    }
                },
                "results": []
            }
        ]
    }
    raw = json.dumps(bad).encode("utf-8")
    try:
        trivy_scan.validate_sarif(raw)
    except trivy_scan.ScanError:
        print("ok   negative: wrong tool name refused")
        return
    raise AssertionError("wrong tool name was accepted")


def test_negative_wrong_version():
    bad = {
        "version": "2.0.0",
        "runs": [
            {
                "tool": {
                    "driver": {
                        "name": "Trivy"
                    }
                },
                "results": []
            }
        ]
    }
    raw = json.dumps(bad).encode("utf-8")
    try:
        trivy_scan.validate_sarif(raw)
    except trivy_scan.ScanError:
        print("ok   negative: wrong version refused")
        return
    raise AssertionError("wrong version was accepted")


def test_negative_not_json():
    raw = b"not-json-content"
    try:
        trivy_scan.validate_sarif(raw)
    except trivy_scan.ScanError:
        print("ok   negative: not JSON refused")
        return
    raise AssertionError("non-JSON data was accepted")


def test_boundary_empty_runs():
    bad = {
        "version": "2.1.0",
        "runs": []
    }
    raw = json.dumps(bad).encode("utf-8")
    try:
        trivy_scan.validate_sarif(raw)
    except trivy_scan.ScanError:
        print("ok   boundary: empty runs refused")
        return
    raise AssertionError("empty runs was accepted")


def main():
    test_positive_valid()
    test_negative_wrong_tool()
    test_negative_wrong_version()
    test_negative_not_json()
    test_boundary_empty_runs()
    print("trivy sarif validation: 1 accepted, 4 refused")
    return 0


if __name__ == "__main__":
    sys.exit(main())
