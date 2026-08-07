#!/usr/bin/env python3
"""
validate_stage_2.py
PropertyDealRealityChecker

Stage 2 Platform-Independent Static Validator & Anti-Double Linter
Verifies zero binary floating-point types, domain schema completeness, and package boundaries.
"""

import os
import re
import sys

passed = 0
failed = 0
results = []

def test_check(name: str, condition: bool, fail_message: str):
    global passed, failed, results
    if condition:
        passed += 1
        results.append(f"[PASS] {name}")
    else:
        failed += 1
        results.append(f"[FAIL] {name} - {fail_message}")

def check_no_floating_point(file_path: str, label: str):
    with open(file_path, "r", encoding="utf-8") as f:
        lines = f.readlines()
    has_float = False
    for line in lines:
        trimmed = line.strip()
        if not trimmed.startswith("//") and not trimmed.startswith("/*") and not trimmed.startswith("*"):
            if re.search(r"(:\s*(Double|Float)\b|->\s*(Double|Float)\b|as\s+(Double|Float)\b|\b(Double|Float)\()", trimmed):
                has_float = True
                break
    test_check(
        f"{label} in {os.path.basename(file_path)}",
        not has_float,
        f"Forbidden binary floating-point type (Double/Float) detected in {os.path.basename(file_path)}"
    )

def check_file_imports(file_path: str, forbidden_pattern: str, label: str):
    with open(file_path, "r", encoding="utf-8") as f:
        lines = f.readlines()
    has_forbidden = False
    for line in lines:
        trimmed = line.strip()
        if not trimmed.startswith("//") and not trimmed.startswith("/*") and not trimmed.startswith("*"):
            if re.match(f"^import\\s+({forbidden_pattern})", trimmed):
                has_forbidden = True
                break
    test_check(
        f"{label} in {os.path.basename(file_path)}",
        not has_forbidden,
        f"Forbidden import detected in {os.path.basename(file_path)}"
    )

def main():
    print("=== Property Deal Reality Checker -- Stage 2 Validator & Anti-Double Linter ===")
    
    required_domain_files = [
        "Sources/DealCore/ValueTypes/CurrencyAmount.swift",
        "Sources/DealCore/ValueTypes/Rate.swift",
        "Sources/DealCore/ValueTypes/Frequency.swift",
        "Sources/DealCore/ValueTypes/ConfidenceLevel.swift",
        "Sources/DealCore/ValueTypes/SourceRecord.swift",
        "Sources/DealCore/Entities/Property.swift",
        "Sources/DealCore/Entities/Assumption.swift",
        "Sources/DealCore/Entities/IncomeLine.swift",
        "Sources/DealCore/Entities/ExpenseLine.swift",
        "Sources/DealCore/Entities/ProjectCost.swift",
        "Sources/DealCore/Entities/DebtLayer.swift",
        "Sources/DealCore/Entities/FinancingPlan.swift",
        "Sources/DealCore/Entities/Scenario.swift",
        "Sources/DealCore/Entities/Deal.swift",
        "Sources/DealCore/Validation/ValidationIssue.swift",
        "Sources/DealCore/Validation/DraftDeal.swift",
        "Sources/DealCore/Validation/CanonicalDeal.swift",
        "Sources/DealCore/Verdicts/ReasonCode.swift",
        "Sources/DealCore/Verdicts/Verdict.swift",
        "Sources/DealCore/Snapshots/CalculationMetrics.swift",
        "Sources/DealCore/Snapshots/CalculationSnapshot.swift",
        "Sources/DealCore/Settings/UserDefaultsProfile.swift"
    ]
    
    for f in required_domain_files:
        test_check(f"Domain file {f} exists", os.path.isfile(f), f"File {f} missing.")
        
    required_test_files = [
        "Tests/DealCoreTests/ValueTypeTests.swift",
        "Tests/DealCoreTests/DomainModelTests.swift",
        "Tests/DealCoreTests/ValidationAndDraftTests.swift"
    ]
    for tf in required_test_files:
        test_check(f"Test file {tf} exists", os.path.isfile(tf), f"File {tf} missing.")

    if os.path.isdir("Sources/DealCore"):
        for root, _, files in os.walk("Sources/DealCore"):
            for f in files:
                if f.endswith(".swift"):
                    full_path = os.path.join(root, f)
                    check_no_floating_point(full_path, "Decimal-only policy")
                    check_file_imports(full_path, "SwiftUI|SwiftData|UIKit|PersistenceKit", "DealCore isolation")

    if os.path.isdir("Sources/CalculationKit"):
        for root, _, files in os.walk("Sources/CalculationKit"):
            for f in files:
                if f.endswith(".swift"):
                    full_path = os.path.join(root, f)
                    check_no_floating_point(full_path, "Decimal-only policy")

    print("\n=== Stage 2 Validation Summary ===")
    for res in results:
        print(res)

    print(f"\nTotal Passed: {passed} | Total Failed: {failed}")
    if failed > 0:
        sys.exit(1)
    else:
        print("ALL STAGE 2 DOMAIN & ANTI-DOUBLE CHECKS PASSED.")
        sys.exit(0)

if __name__ == "__main__":
    main()
