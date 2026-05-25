#!/usr/bin/env python3
"""
parse_sim_log.py - Parse Vivado XSim simulation log for errors and test results.

Usage: python3 scripts/parse_sim_log.py <log_file>

Extracts:
  - $error and $fatal messages with timestamps
  - FAIL / PASS lines from test cases
  - Final test summary (ALL TESTS PASSED / N TEST(S) FAILED)
  - Vivado tool errors and warnings
"""

import sys
import re
from pathlib import Path


def parse_log(filepath: str) -> dict:
    """Parse simulation log and return structured results."""
    path = Path(filepath)
    if not path.exists():
        return {"error": f"Log file not found: {filepath}"}

    content = path.read_text(encoding="utf-8", errors="replace")

    result = {
        "file": str(path),
        "tool_errors": [],
        "tool_warnings": [],
        "test_failures": [],
        "test_passes": [],
        "fatal_messages": [],
        "display_lines": [],
        "all_tests_passed": False,
        "failed_test_count": 0,
        "total_test_count": 0,
        "summary": "",
    }

    lines = content.split("\n")
    for i, line in enumerate(lines):
        # Vivado tool errors (not from $error, actual tool failures)
        if re.search(r"^\s*ERROR:", line, re.IGNORECASE):
            result["tool_errors"].append({"line": i + 1, "text": line.strip()})

        # Vivado tool warnings
        if re.search(r"^\s*WARNING:", line, re.IGNORECASE):
            result["tool_warnings"].append({"line": i + 1, "text": line.strip()})

        # $fatal messages (from Verilog $fatal system task)
        if "$fatal" in line.lower() or "FATAL" in line:
            result["fatal_messages"].append({"line": i + 1, "text": line.strip()})

        # Custom test failure markers
        if re.search(r"FAIL[:!\]]", line):
            result["test_failures"].append({"line": i + 1, "text": line.strip()})

        # Custom test pass markers
        if re.search(r"\bPASS\b", line) and "ALL TESTS PASSED" not in line:
            result["test_passes"].append({"line": i + 1, "text": line.strip()})

        # All $display lines
        if "$display" in line:
            # Extract just the displayed message
            match = re.search(r'"(.*?)"', line)
            if match:
                result["display_lines"].append(match.group(1))

        # Check for final test summary
        if "ALL TESTS PASSED" in line:
            result["all_tests_passed"] = True

        # Extract failed test count
        match_fail = re.search(r"(\d+)\s+TEST\(S\)\s+FAILED", line)
        if match_fail:
            result["failed_test_count"] = int(match_fail.group(1))

        # Extract total test count
        match_total = re.search(r"TEST COMPLETE:\s*(\d+)/(\d+)", line)
        if match_total:
            result["total_test_count"] = int(match_total.group(2))

    # Build summary
    total_issues = (
        len(result["tool_errors"])
        + len(result["test_failures"])
        + len(result["fatal_messages"])
    )

    if result["all_tests_passed"]:
        result["summary"] = "PASS - All tests passed"
    elif total_issues > 0:
        parts = []
        if result["tool_errors"]:
            parts.append(f"{len(result['tool_errors'])} tool error(s)")
        if result["test_failures"]:
            parts.append(f"{len(result['test_failures'])} test failure(s)")
        if result["fatal_messages"]:
            parts.append(f"{len(result['fatal_messages'])} fatal message(s)")
        result["summary"] = f"FAIL - {', '.join(parts)}"
    else:
        result["summary"] = "UNKNOWN - No clear pass/fail indicators found"

    return result


def print_report(result: dict) -> None:
    """Pretty-print the parse results."""
    if "error" in result:
        print(f"ERROR: {result['error']}")
        return

    print(f"=== Simulation Log Report: {result['file']} ===\n")
    print(f"Summary: {result['summary']}")

    if result["tool_errors"]:
        print(f"\n--- Tool Errors ({len(result['tool_errors'])}) ---")
        for e in result["tool_errors"]:
            print(f"  Line {e['line']}: {e['text']}")

    if result["tool_warnings"]:
        print(f"\n--- Tool Warnings ({len(result['tool_warnings'])}) ---")
        for w in result["tool_warnings"]:
            print(f"  Line {w['line']}: {w['text']}")

    if result["fatal_messages"]:
        print(f"\n--- Fatal Messages ({len(result['fatal_messages'])}) ---")
        for f in result["fatal_messages"]:
            print(f"  Line {f['line']}: {f['text']}")

    if result["test_failures"]:
        print(f"\n--- Test Failures ({len(result['test_failures'])}) ---")
        for f in result["test_failures"]:
            print(f"  Line {f['line']}: {f['text']}")

    if result["test_passes"]:
        print(f"\n--- Test Passes ({len(result['test_passes'])}) ---")
        for p in result["test_passes"]:
            print(f"  Line {p['line']}: {p['text']}")

    if result["all_tests_passed"]:
        print("\n  >> ALL TESTS PASSED <<")

    if result["display_lines"]:
        print(f"\n--- Display Output ({len(result['display_lines'])} lines) ---")
        for d in result["display_lines"]:
            print(f"  {d}")

    print()


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 parse_sim_log.py <log_file>")
        sys.exit(1)

    log_file = sys.argv[1]
    result = parse_log(log_file)
    print_report(result)

    # Exit with non-zero if failures found (for CI/scripting)
    if (
        result.get("tool_errors")
        or result.get("test_failures")
        or result.get("fatal_messages")
    ):
        sys.exit(1)
    elif not result.get("all_tests_passed"):
        sys.exit(2)  # Unknown status
    else:
        sys.exit(0)
