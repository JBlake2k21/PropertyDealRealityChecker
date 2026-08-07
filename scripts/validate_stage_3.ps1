#
#  validate_stage_3.ps1
#  PropertyDealRealityChecker
#
#  Stage 3 Platform-Independent Static Validator & Anti-Double Linter
#  Verifies deterministic calculation engines, zero floating-point usage, formula completeness, and package boundaries.
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

Write-Host "=== Property Deal Reality Checker -- Stage 3 Validator & Anti-Double Linter ===" -ForegroundColor Cyan

# 1. Verify all Stage 3 calculation engine files exist
$requiredCalcFiles = @(
    "Sources/CalculationKit/RoundingEngine.swift",
    "Sources/CalculationKit/OperatingCalculator.swift",
    "Sources/CalculationKit/AmortizationEngine.swift",
    "Sources/CalculationKit/ReturnCalculator.swift",
    "Sources/CalculationKit/SensitivityEngine.swift",
    "Sources/DealCore/Calculation/UnderwritingEngine.swift",
    "Sources/DealCore/Snapshots/CalculationSnapshot.swift"
)

foreach ($filePath in $requiredCalcFiles) {
    $fileExists = Test-Path $filePath
    Test-Check "Calculation engine file $filePath exists" $fileExists "File $filePath missing."
}

# 2. Verify all Stage 3 test files exist
$requiredTestFiles = @(
    "Tests/CalculationKitTests/OperatingCalculatorTests.swift",
    "Tests/CalculationKitTests/AmortizationEngineTests.swift",
    "Tests/CalculationKitTests/ReturnCalculatorTests.swift",
    "Tests/CalculationKitTests/SensitivityEngineTests.swift",
    "Tests/DealCoreTests/UnderwritingEngineTests.swift"
)

foreach ($testPath in $requiredTestFiles) {
    $fileExists = Test-Path $testPath
    Test-Check "Unit test suite $testPath exists" $fileExists "File $testPath missing."
}

# 3. ANTI-DOUBLE LINTER: Scan DealCore and CalculationKit for any use of Double or Float
function Test-NoFloatingPoint($file, $label) {
    $lines = Get-Content $file.FullName
    $hasFloat = $false
    foreach ($line in $lines) {
        $trimmed = $line.Trim()
        if (-not $trimmed.StartsWith("//") -and -not $trimmed.StartsWith("/*") -and -not $trimmed.StartsWith("*")) {
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

# 4. Verify Package Isolation
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

foreach ($file in $calcFiles) {
    Test-FileImports $file "DealCore|SwiftUI|SwiftData|UIKit|PersistenceKit" "CalculationKit isolation"
}

foreach ($file in $coreFiles) {
    Test-FileImports $file "SwiftUI|SwiftData|UIKit|PersistenceKit" "DealCore isolation"
}

# 5. Verify Formula Completeness in CalculationKit
function Test-FileContains($path, $keyword, $label) {
    $content = Get-Content $path -Raw
    $found = $content -match $keyword
    Test-Check "$label implemented in $path" $found "Keyword $keyword not found in $path"
}

Test-FileContains "Sources/CalculationKit/OperatingCalculator.swift" "calculateGSI" "Gross Scheduled Income (GSI)"
Test-FileContains "Sources/CalculationKit/OperatingCalculator.swift" "calculateEGI" "Effective Gross Income (EGI)"
Test-FileContains "Sources/CalculationKit/OperatingCalculator.swift" "calculateNOI" "Accounting Net Operating Income (NOI)"
Test-FileContains "Sources/CalculationKit/OperatingCalculator.swift" "calculateOwnerCashFlow" "Owner Pre-Tax Cash Flow"
Test-FileContains "Sources/CalculationKit/AmortizationEngine.swift" "calculateMonthlyPayment" "Mortgage Monthly Payment (PMT)"
Test-FileContains "Sources/CalculationKit/AmortizationEngine.swift" "calculateBalloonBurden" "Balloon Principal Burden"
Test-FileContains "Sources/CalculationKit/ReturnCalculator.swift" "calculateCapRate" "Cap Rate (ADR-002)"
Test-FileContains "Sources/CalculationKit/ReturnCalculator.swift" "calculateCashOnCashReturn" "Cash-on-Cash Return"
Test-FileContains "Sources/CalculationKit/ReturnCalculator.swift" "calculateDSCR" "Debt Service Coverage Ratio (DSCR)"
Test-FileContains "Sources/CalculationKit/ReturnCalculator.swift" "calculateBreakEvenOccupancy" "Break-Even Occupancy Rate"
Test-FileContains "Sources/CalculationKit/ReturnCalculator.swift" "calculateLTV" "Loan-to-Value (LTV)"
Test-FileContains "Sources/CalculationKit/ReturnCalculator.swift" "calculateLTC" "Loan-to-Cost (LTC)"
Test-FileContains "Sources/CalculationKit/ReturnCalculator.swift" "calculateDebtYield" "Debt Yield"
Test-FileContains "Sources/CalculationKit/SensitivityEngine.swift" "generatePriceVsVacancyMatrix" "3x3 Sensitivity Matrix"
Test-FileContains "Sources/DealCore/Calculation/UnderwritingEngine.swift" "evaluate" "Underwriting Engine Orchestrator"

# Output Summary
Write-Host "`n=== Stage 3 Validation Summary ===" -ForegroundColor Cyan
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
    Write-Host "ALL STAGE 3 CALCULATION & ANTI-DOUBLE CHECKS PASSED." -ForegroundColor Green
    exit 0
}
