#!/usr/bin/env python3
"""
validate_package_boundaries.py
PropertyDealRealityChecker

Stage 1 Platform-Independent Static Validator (Python)
Verifies package scaffolding, target directories, and strict dependency rules.
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
    print("=== Property Deal Reality Checker -- Package Boundary Validator ===")
    
    # 1. Verify Package.swift exists
    test_check("Package.swift existence", os.path.isfile("Package.swift"), "Package.swift not found at workspace root.")
    
    # 2. Verify all 11 required target directories exist in Sources/
    required_targets = [
        "CalculationKit",
        "DealCore",
        "DesignSystem",
        "PersistenceKit",
        "FeatureDealEntry",
        "FeatureDashboard",
        "FeatureScenarios",
        "ExplanationKit",
        "ExportKit",
        "TestFixtures",
        "RealityCheckerApp"
    ]
    for target in required_targets:
        dir_path = os.path.join("Sources", target)
        test_check(f"Target directory {dir_path} exists", os.path.isdir(dir_path), f"Directory {dir_path} missing.")
        
    # 3. Verify test targets exist in Tests/
    required_test_targets = [
        "CalculationKitTests",
        "DealCoreTests",
        "PersistenceKitTests",
        "FeatureTests",
        "ExplanationKitTests",
        "ExportKitTests",
        "RealityCheckerAppTests"
    ]
    for test_target in required_test_targets:
        dir_path = os.path.join("Tests", test_target)
        test_check(f"Test target directory {dir_path} exists", os.path.isdir(dir_path), f"Directory {dir_path} missing.")

    # 4. Verify CalculationKit boundary
    if os.path.isdir("Sources/CalculationKit"):
        for root, _, files in os.walk("Sources/CalculationKit"):
            for f in files:
                if f.endswith(".swift"):
                    check_file_imports(os.path.join(root, f), "SwiftUI|SwiftData|UIKit|DealCore|PersistenceKit", "CalculationKit isolation")

    # 5. Verify DealCore boundary
    if os.path.isdir("Sources/DealCore"):
        for root, _, files in os.walk("Sources/DealCore"):
            for f in files:
                if f.endswith(".swift"):
                    check_file_imports(os.path.join(root, f), "SwiftUI|SwiftData|UIKit|PersistenceKit", "DealCore isolation")

    # 6. Verify PersistenceKit boundary
    if os.path.isdir("Sources/PersistenceKit"):
        for root, _, files in os.walk("Sources/PersistenceKit"):
            for f in files:
                if f.endswith(".swift"):
                    check_file_imports(os.path.join(root, f), "SwiftUI|UIKit", "PersistenceKit isolation")

    print("\n=== Validation Summary ===")
    for res in results:
        print(res)

    print(f"\nTotal Passed: {passed} | Total Failed: {failed}")
    if failed > 0:
        sys.exit(1)
    else:
        print("ALL PACKAGE BOUNDARY CHECKS PASSED.")
        sys.exit(0)

if __name__ == "__main__":
    main()
