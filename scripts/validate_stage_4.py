#!/usr/bin/env python3
"""
validate_stage_4.py
PropertyDealRealityChecker

Stage 4 Platform-Independent Static Validator & Anti-Double Linter
Verifies persistence schemas, repository pattern, DTO mapper isolation, and migration supervisor.
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
    print("=== Property Deal Reality Checker -- Stage 4 Validator & Anti-Double Linter ===")
    
    required_persist_files = [
        "Sources/PersistenceKit/Schemas/SchemaVersion.swift",
        "Sources/PersistenceKit/Schemas/PersistedDeal.swift",
        "Sources/PersistenceKit/Schemas/PersistedScenario.swift",
        "Sources/PersistenceKit/Schemas/PersistedSnapshot.swift",
        "Sources/PersistenceKit/Mappers/DealMapper.swift",
        "Sources/PersistenceKit/Repositories/DealRepository.swift",
        "Sources/PersistenceKit/Repositories/InMemoryDealRepository.swift",
        "Sources/PersistenceKit/Repositories/SwiftDataDealRepository.swift",
        "Sources/PersistenceKit/Migrations/PersistenceSupervisor.swift"
    ]
    for f in required_persist_files:
        test_check(f"Persistence source file {f} exists", os.path.isfile(f), f"File {f} missing.")

    required_test_files = [
        "Tests/PersistenceKitTests/DealMapperTests.swift",
        "Tests/PersistenceKitTests/InMemoryRepositoryTests.swift",
        "Tests/PersistenceKitTests/PersistenceSupervisorTests.swift"
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

    if os.path.isdir("Sources/PersistenceKit"):
        for root, _, files in os.walk("Sources/PersistenceKit"):
            for f in files:
                if f.endswith(".swift"):
                    full_path = os.path.join(root, f)
                    check_file_imports(full_path, "SwiftUI|UIKit|CalculationKit", "PersistenceKit isolation")

    if os.path.isdir("Sources/DealCore"):
        for root, _, files in os.walk("Sources/DealCore"):
            for f in files:
                if f.endswith(".swift"):
                    full_path = os.path.join(root, f)
                    check_file_imports(full_path, "SwiftUI|SwiftData|UIKit|PersistenceKit", "DealCore isolation")

    if os.path.isdir("Sources/CalculationKit"):
        for root, _, files in os.walk("Sources/CalculationKit"):
            for f in files:
                if f.endswith(".swift"):
                    full_path = os.path.join(root, f)
                    check_file_imports(full_path, "DealCore|SwiftUI|SwiftData|UIKit|PersistenceKit", "CalculationKit isolation")

    check_file_contains("Sources/PersistenceKit/Mappers/DealMapper.swift", "toPersistence", "DealMapper toPersistence")
    check_file_contains("Sources/PersistenceKit/Mappers/DealMapper.swift", "toDomain", "DealMapper toDomain")
    check_file_contains("Sources/PersistenceKit/Repositories/DealRepository.swift", "fetchAllDeals", "DealRepository fetchAllDeals")
    check_file_contains("Sources/PersistenceKit/Repositories/DealRepository.swift", "saveDeal", "DealRepository saveDeal")
    check_file_contains("Sources/PersistenceKit/Repositories/DealRepository.swift", "fetchSnapshots", "DealRepository fetchSnapshots")
    check_file_contains("Sources/PersistenceKit/Migrations/PersistenceSupervisor.swift", "checkAndRecoverStoreHealth", "PersistenceSupervisor Health Check")
    check_file_contains("Sources/PersistenceKit/Migrations/PersistenceSupervisor.swift", "quarantineCorruptedStore", "Quarantine Corrupted Store Recovery")

    print("\n=== Stage 4 Validation Summary ===")
    for res in results:
        print(res)

    print(f"\nTotal Passed: {passed} | Total Failed: {failed}")
    if failed > 0:
        sys.exit(1)
    else:
        print("ALL STAGE 4 PERSISTENCE & ANTI-DOUBLE CHECKS PASSED.")
        sys.exit(0)

if __name__ == "__main__":
    main()
