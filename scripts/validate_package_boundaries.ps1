#
#  validate_package_boundaries.ps1
#  PropertyDealRealityChecker
#
#  Stage 1 Platform-Independent Static Validator
#  Verifies package scaffolding, target directories, and strict dependency rules.
#

$ErrorActionPreference = "Stop"
$passed = 0
$failed = 0
$results = @()

function Test-Check($name, $condition, $failMessage) {
    if ($condition) {
        $script:passed++
        $script:results += "[PASS] $name"
    } else {
        $script:failed++
        $script:results += "[FAIL] $name - $failMessage"
    }
}

Write-Host "=== Property Deal Reality Checker -- Package Boundary Validator ===" -ForegroundColor Cyan

# 1. Verify Package.swift exists
Test-Check "Package.swift existence" (Test-Path "Package.swift") "Package.swift not found at workspace root."

# 2. Verify all 11 required target directories exist in Sources/
$requiredTargets = @(
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
)

foreach ($target in $requiredTargets) {
    $dirExists = Test-Path "Sources/$target"
    Test-Check "Target directory Sources/$target exists" $dirExists "Directory Sources/$target missing."
}

# 3. Verify test targets exist in Tests/
$requiredTestTargets = @(
    "CalculationKitTests",
    "DealCoreTests",
    "PersistenceKitTests",
    "FeatureTests",
    "ExplanationKitTests",
    "ExportKitTests",
    "RealityCheckerAppTests"
)

foreach ($testTarget in $requiredTestTargets) {
    $dirExists = Test-Path "Tests/$testTarget"
    Test-Check "Test target directory Tests/$testTarget exists" $dirExists "Directory Tests/$testTarget missing."
}

function Test-FileImports($file, $forbiddenPattern, $label) {
    $lines = Get-Content $file.FullName
    $hasForbidden = $false
    foreach ($line in $lines) {
        $trimmed = $line.Trim()
        if (-not $trimmed.StartsWith("//") -and -not $trimmed.StartsWith("/*") -and -not $trimmed.StartsWith("*")) {
            if ($trimmed -match "^import\s+($forbiddenPattern)") {
                $hasForbidden = $true
                break
            }
        }
    }
    Test-Check "$label in $($file.Name)" (-not $hasForbidden) "Forbidden import detected in $($file.Name)"
}

# 4. Verify CalculationKit boundary (No SwiftUI, SwiftData, UIKit, DealCore, or PersistenceKit imports)
$calcFiles = Get-ChildItem -Path "Sources/CalculationKit" -Filter "*.swift" -Recurse
foreach ($file in $calcFiles) {
    Test-FileImports $file "SwiftUI|SwiftData|UIKit|DealCore|PersistenceKit" "CalculationKit isolation"
}

# 5. Verify DealCore boundary (No SwiftUI, SwiftData, UIKit, or PersistenceKit imports)
$dealFiles = Get-ChildItem -Path "Sources/DealCore" -Filter "*.swift" -Recurse
foreach ($file in $dealFiles) {
    Test-FileImports $file "SwiftUI|SwiftData|UIKit|PersistenceKit" "DealCore isolation"
}

# 6. Verify PersistenceKit boundary (No SwiftUI or UIKit imports)
$persFiles = Get-ChildItem -Path "Sources/PersistenceKit" -Filter "*.swift" -Recurse
foreach ($file in $persFiles) {
    Test-FileImports $file "SwiftUI|UIKit" "PersistenceKit isolation"
}

# Output Summary
Write-Host "`n=== Validation Summary ===" -ForegroundColor Cyan
foreach ($res in $results) {
    if ($res -like "[PASS]*") {
        Write-Host $res -ForegroundColor Green
    } else {
        Write-Host $res -ForegroundColor Red
    }
}

Write-Host "`nTotal Passed: $passed | Total Failed: $failed"
if ($failed -gt 0) {
    exit 1
} else {
    Write-Host "ALL PACKAGE BOUNDARY CHECKS PASSED." -ForegroundColor Green
    exit 0
}
