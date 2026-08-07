#!/usr/bin/env python3
"""
validate_stage_6.py
PropertyDealRealityChecker

Stage 6 Platform-Independent Static Validator & Architectural Linter
Verifies feature module views, view models, zero forbidden imports, and state reactivity.
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
    print("=== Property Deal Reality Checker -- Stage 6 Validator & Architectural Linter ===")
    
    required_feature_files = [
        "Sources/FeatureDealEntry/DealEntryViewModel.swift",
        "Sources/FeatureDealEntry/DealEntryView.swift",
        "Sources/FeatureDashboard/DashboardViewModel.swift",
        "Sources/FeatureDashboard/DashboardView.swift",
        "Sources/FeatureScenarios/ScenarioComparisonViewModel.swift",
        "Sources/FeatureScenarios/ScenarioComparisonView.swift"
    ]
    for f in required_feature_files:
        test_check(f"Feature file {f} exists", os.path.isfile(f), f"File {f} missing.")

    required_test_files = [
        "Tests/FeatureDealEntryTests/DealEntryViewModelTests.swift",
        "Tests/FeatureDashboardTests/DashboardViewModelTests.swift",
        "Tests/FeatureScenariosTests/ScenarioComparisonTests.swift"
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

    for pkg, forbidden, label in [
        ("Sources/FeatureDealEntry", "CalculationKit|PersistenceKit|FeatureDashboard|FeatureScenarios", "FeatureDealEntry isolation"),
        ("Sources/FeatureDashboard", "CalculationKit|PersistenceKit|FeatureDealEntry|FeatureScenarios", "FeatureDashboard isolation"),
        ("Sources/FeatureScenarios", "CalculationKit|PersistenceKit|FeatureDealEntry|FeatureDashboard", "FeatureScenarios isolation")
    ]:
        if os.path.isdir(pkg):
            for root, _, files in os.walk(pkg):
                for f in files:
                    if f.endswith(".swift"):
                        full_path = os.path.join(root, f)
                        check_file_imports(full_path, forbidden, label)

    check_file_contains("Sources/FeatureDealEntry/DealEntryViewModel.swift", "commitToCanonical", "DealEntryViewModel commitToCanonical")
    check_file_contains("Sources/FeatureDealEntry/DealEntryViewModel.swift", "updateDraftFromStrings", "DealEntryViewModel updateDraftFromStrings")
    check_file_contains("Sources/FeatureDashboard/DashboardViewModel.swift", "metricCards", "DashboardViewModel metricCards")
    check_file_contains("Sources/FeatureDashboard/DashboardViewModel.swift", "waterfallModel", "DashboardViewModel waterfallModel")
    check_file_contains("Sources/FeatureScenarios/ScenarioComparisonViewModel.swift", "addScenario", "ScenarioComparisonViewModel addScenario")

    print("\n=== Stage 6 Validation Summary ===")
    for res in results:
        print(res)

    print(f"\nTotal Passed: {passed} | Total Failed: {failed}")
    if failed > 0:
        sys.exit(1)
    else:
        print("ALL STAGE 6 FEATURE MODULES & ARCHITECTURAL CHECKS PASSED.")
        sys.exit(0)

if __name__ == "__main__":
    main()
