#!/usr/bin/env python3
"""
validate_stage_3.py
PropertyDealRealityChecker

Stage 3 Platform-Independent Static Validator & Anti-Double Linter
Verifies deterministic calculation engines, zero floating-point usage, formula completeness, and package boundaries.
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

def check_file_contains(file_path: str, keyword: str, label: str):
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()
    test_check(
        f"{label} implemented in {os.path.basename(file_path)}",
        keyword in content,
        f"Keyword {keyword} not found in {file_path}"
    )

def main():
    print("=== Property Deal Reality Checker -- Stage 3 Validator & Anti-Double Linter ===")
    
    required_calc_files = [
        "Sources/CalculationKit/RoundingEngine.swift",
        "Sources/CalculationKit/OperatingCalculator.swift",
        "Sources/CalculationKit/AmortizationEngine.swift",
        "Sources/CalculationKit/ReturnCalculator.swift",
        "Sources/CalculationKit/SensitivityEngine.swift",
        "Sources/DealCore/Calculation/UnderwritingEngine.swift",
        "Sources/DealCore/Snapshots/CalculationSnapshot.swift"
    ]
    for f in required_calc_files:
        test_check(f"Calculation engine file {f} exists", os.path.isfile(f), f"File {f} missing.")

    required_test_files = [
        "Tests/CalculationKitTests/OperatingCalculatorTests.swift",
        "Tests/CalculationKitTests/AmortizationEngineTests.swift",
        "Tests/CalculationKitTests/ReturnCalculatorTests.swift",
        "Tests/CalculationKitTests/SensitivityEngineTests.swift",
        "Tests/DealCoreTests/UnderwritingEngineTests.swift"
    ]
    for tf in required_test_files:
        test_check(f"Unit test suite {tf} exists", os.path.isfile(tf), f"File {tf} missing.")

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
                    check_file_imports(full_path, "DealCore|SwiftUI|SwiftData|UIKit|PersistenceKit", "CalculationKit isolation")

    check_file_contains("Sources/CalculationKit/OperatingCalculator.swift", "calculateGSI", "Gross Scheduled Income (GSI)")
    check_file_contains("Sources/CalculationKit/OperatingCalculator.swift", "calculateEGI", "Effective Gross Income (EGI)")
    check_file_contains("Sources/CalculationKit/OperatingCalculator.swift", "calculateNOI", "Accounting Net Operating Income (NOI)")
    check_file_contains("Sources/CalculationKit/OperatingCalculator.swift", "calculateOwnerCashFlow", "Owner Pre-Tax Cash Flow")
    check_file_contains("Sources/CalculationKit/AmortizationEngine.swift", "calculateMonthlyPayment", "Mortgage Monthly Payment (PMT)")
    check_file_contains("Sources/CalculationKit/AmortizationEngine.swift", "calculateBalloonBurden", "Balloon Principal Burden")
    check_file_contains("Sources/CalculationKit/ReturnCalculator.swift", "calculateCapRate", "Cap Rate (ADR-002)")
    check_file_contains("Sources/CalculationKit/ReturnCalculator.swift", "calculateCashOnCashReturn", "Cash-on-Cash Return")
    check_file_contains("Sources/CalculationKit/ReturnCalculator.swift", "calculateDSCR", "Debt Service Coverage Ratio (DSCR)")
    check_file_contains("Sources/CalculationKit/ReturnCalculator.swift", "calculateBreakEvenOccupancy", "Break-Even Occupancy Rate")
    check_file_contains("Sources/CalculationKit/ReturnCalculator.swift", "calculateLTV", "Loan-to-Value (LTV)")
    check_file_contains("Sources/CalculationKit/ReturnCalculator.swift", "calculateLTC", "Loan-to-Cost (LTC)")
    check_file_contains("Sources/CalculationKit/ReturnCalculator.swift", "calculateDebtYield", "Debt Yield")
    check_file_contains("Sources/CalculationKit/SensitivityEngine.swift", "generatePriceVsVacancyMatrix", "3x3 Sensitivity Matrix")
    check_file_contains("Sources/DealCore/Calculation/UnderwritingEngine.swift", "evaluate", "Underwriting Engine Orchestrator")

    print("\n=== Stage 3 Validation Summary ===")
    for res in results:
        print(res)

    print(f"\nTotal Passed: {passed} | Total Failed: {failed}")
    if failed > 0:
        sys.exit(1)
    else:
        print("ALL STAGE 3 CALCULATION & ANTI-DOUBLE CHECKS PASSED.")
        sys.exit(0)

if __name__ == "__main__":
    main()
