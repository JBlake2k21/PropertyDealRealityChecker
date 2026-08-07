#!/usr/bin/env python3
"""
validate_stage_5.py
PropertyDealRealityChecker

Stage 5 Platform-Independent Static Validator & Accessibility Linter
Verifies design tokens, zero domain dependencies, tabular typography, and VoiceOver accessibility labels.
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
    print("=== Property Deal Reality Checker -- Stage 5 Validator & Accessibility Linter ===")
    
    required_design_files = [
        "Sources/DesignSystem/Tokens/ColorTokens.swift",
        "Sources/DesignSystem/Tokens/ThemeEngine.swift",
        "Sources/DesignSystem/Typography/TypographyTokens.swift",
        "Sources/DesignSystem/Components/FinancialMetricCard.swift",
        "Sources/DesignSystem/Components/VerdictBadgeView.swift",
        "Sources/DesignSystem/Components/ReasonCodeRowView.swift",
        "Sources/DesignSystem/Components/CurrencyTextFieldView.swift",
        "Sources/DesignSystem/Charts/SensitivityMatrixGridView.swift",
        "Sources/DesignSystem/Charts/CashFlowWaterfallChartView.swift"
    ]
    for f in required_design_files:
        test_check(f"DesignSystem file {f} exists", os.path.isfile(f), f"File {f} missing.")

    required_test_files = [
        "Tests/DesignSystemTests/TokenTests.swift",
        "Tests/DesignSystemTests/ComponentAccessibilityTests.swift"
    ]
    for tf in required_test_files:
        test_check(f"Test file {tf} exists", os.path.isfile(tf), f"File {tf} missing.")

    for folder in ["Sources/DealCore", "Sources/CalculationKit", "Sources/PersistenceKit"]:
        if os.path.isdir(folder):
            for root, _, files in os.walk(folder):
                for f in files:
                    if f.endswith(".swift"):
                        full_path = os.path.join(root, f)
                        check_no_floating_point(full_path, "Decimal-only policy")

    if os.path.isdir("Sources/DesignSystem"):
        for root, _, files in os.walk("Sources/DesignSystem"):
            for f in files:
                if f.endswith(".swift"):
                    full_path = os.path.join(root, f)
                    check_file_imports(
                        full_path,
                        "DealCore|CalculationKit|PersistenceKit|FeatureDealEntry|FeatureDashboard",
                        "DesignSystem zero domain isolation"
                    )

    check_file_contains("Sources/DesignSystem/Components/FinancialMetricCard.swift", "accessibilityDescription", "FinancialMetricCard Accessibility")
    check_file_contains("Sources/DesignSystem/Components/VerdictBadgeView.swift", "accessibilityDescription", "VerdictBadgeView Accessibility")
    check_file_contains("Sources/DesignSystem/Components/ReasonCodeRowView.swift", "accessibilityDescription", "ReasonCodeRowView Accessibility")
    check_file_contains("Sources/DesignSystem/Components/CurrencyTextFieldView.swift", "accessibilityDescription", "CurrencyTextFieldView Accessibility")
    check_file_contains("Sources/DesignSystem/Charts/SensitivityMatrixGridView.swift", "accessibilityDescription", "SensitivityMatrixGrid Accessibility")
    check_file_contains("Sources/DesignSystem/Charts/CashFlowWaterfallChartView.swift", "accessibilityDescription", "CashFlowWaterfallChart Accessibility")
    check_file_contains("Sources/DesignSystem/Typography/TypographyTokens.swift", "isTabularNumbers", "Tabular Numbers Alignment Support")

    print("\n=== Stage 5 Validation Summary ===")
    for res in results:
        print(res)

    print(f"\nTotal Passed: {passed} | Total Failed: {failed}")
    if failed > 0:
        sys.exit(1)
    else:
        print("ALL STAGE 5 DESIGN SYSTEM & ACCESSIBILITY CHECKS PASSED.")
        sys.exit(0)

if __name__ == "__main__":
    main()
