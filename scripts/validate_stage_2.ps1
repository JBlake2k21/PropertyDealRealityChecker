#
#  validate_stage_2.ps1
#  PropertyDealRealityChecker
#
#  Stage 2 Platform-Independent Static Validator & Anti-Double Linter
#  Verifies zero binary floating-point types, domain schema completeness, and package boundaries.
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

Write-Host "=== Property Deal Reality Checker -- Stage 2 Validator & Anti-Double Linter ===" -ForegroundColor Cyan

# 1. Verify all Stage 2 domain files exist
$requiredDomainFiles = @(
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
)

foreach ($filePath in $requiredDomainFiles) {
    $fileExists = Test-Path $filePath
    Test-Check "Domain file $filePath exists" $fileExists "File $filePath missing."
}

# 2. Verify unit test files exist
$requiredTestFiles = @(
    "Tests/DealCoreTests/ValueTypeTests.swift",
    "Tests/DealCoreTests/DomainModelTests.swift",
    "Tests/DealCoreTests/ValidationAndDraftTests.swift"
)

foreach ($testPath in $requiredTestFiles) {
    $fileExists = Test-Path $testPath
    Test-Check "Test file $testPath exists" $fileExists "File $testPath missing."
}

# 3. ANTI-DOUBLE LINTER: Scan DealCore and CalculationKit for any use of Double or Float
function Test-NoFloatingPoint($file, $label) {
    $lines = Get-Content $file.FullName
    $hasFloat = $false
    foreach ($line in $lines) {
        $trimmed = $line.Trim()
        # Ignore comments
        if (-not $trimmed.StartsWith("//") -and -not $trimmed.StartsWith("/*") -and -not $trimmed.StartsWith("*")) {
            # Check for ': Double', ': Float', '-> Double', '-> Float', 'as Double', 'as Float', 'Double(' or 'Float('
            if ($trimmed -match "(:\s*(Double|Float)\b|->\s*(Double|Float)\b|as\s+(Double|Float)\b|\b(Double|Float)\()") {
                $hasFloat = $true
                break
            }
        }
    }
    Test-Check "$label in $($file.Name)" (-not $hasFloat) "Forbidden binary floating-point type (Double/Float) detected in $($file.Name)"
}

$coreFiles = Get-ChildItem -Path "Sources/DealCore" -Filter "*.swift" -Recurse
foreach ($file in $coreFiles) {
    Test-NoFloatingPoint $file "Decimal-only policy"
}

$calcFiles = Get-ChildItem -Path "Sources/CalculationKit" -Filter "*.swift" -Recurse
foreach ($file in $calcFiles) {
    Test-NoFloatingPoint $file "Decimal-only policy"
}

# 4. Re-verify Package Boundary isolation
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

foreach ($file in $coreFiles) {
    Test-FileImports $file "SwiftUI|SwiftData|UIKit|PersistenceKit" "DealCore isolation"
}

# Output Summary
Write-Host "`n=== Stage 2 Validation Summary ===" -ForegroundColor Cyan
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
    Write-Host "ALL STAGE 2 DOMAIN & ANTI-DOUBLE CHECKS PASSED." -ForegroundColor Green
    exit 0
}
