#
#  validate_stage_5.ps1
#  PropertyDealRealityChecker
#
#  Stage 5 Platform-Independent Static Validator & Accessibility Linter
#  Verifies design tokens, zero domain dependencies, tabular typography, and VoiceOver accessibility labels.
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

Write-Host "=== Property Deal Reality Checker -- Stage 5 Validator & Accessibility Linter ===" -ForegroundColor Cyan

# 1. Verify all Stage 5 DesignSystem source files exist
$requiredDesignFiles = @(
    "Sources/DesignSystem/Tokens/ColorTokens.swift",
    "Sources/DesignSystem/Tokens/ThemeEngine.swift",
    "Sources/DesignSystem/Typography/TypographyTokens.swift",
    "Sources/DesignSystem/Components/FinancialMetricCard.swift",
    "Sources/DesignSystem/Components/VerdictBadgeView.swift",
    "Sources/DesignSystem/Components/ReasonCodeRowView.swift",
    "Sources/DesignSystem/Components/CurrencyTextFieldView.swift",
    "Sources/DesignSystem/Charts/SensitivityMatrixGridView.swift",
    "Sources/DesignSystem/Charts/CashFlowWaterfallChartView.swift"
)

foreach ($filePath in $requiredDesignFiles) {
    $fileExists = Test-Path $filePath
    Test-Check "DesignSystem file $filePath exists" $fileExists "File $filePath missing."
}

# 2. Verify unit test files exist
$requiredTestFiles = @(
    "Tests/DesignSystemTests/TokenTests.swift",
    "Tests/DesignSystemTests/ComponentAccessibilityTests.swift"
)

foreach ($testPath in $requiredTestFiles) {
    $fileExists = Test-Path $testPath
    Test-Check "Test file $testPath exists" $fileExists "File $testPath missing."
}

# 3. ANTI-DOUBLE LINTER: Scan DealCore, CalculationKit, and PersistenceKit for any use of Double or Float
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
$calcFiles = Get-ChildItem -Path "Sources/CalculationKit" -Filter "*.swift" -Recurse
$persistFiles = Get-ChildItem -Path "Sources/PersistenceKit" -Filter "*.swift" -Recurse

foreach ($file in $coreFiles) { Test-NoFloatingPoint $file "Decimal-only policy" }
foreach ($file in $calcFiles) { Test-NoFloatingPoint $file "Decimal-only policy" }
foreach ($file in $persistFiles) { Test-NoFloatingPoint $file "Decimal-only policy" }

# 4. Verify Package Isolation (DesignSystem must NEVER import DealCore, CalculationKit, or PersistenceKit)
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

$designFiles = Get-ChildItem -Path "Sources/DesignSystem" -Filter "*.swift" -Recurse
foreach ($file in $designFiles) {
    Test-FileImports $file "DealCore|CalculationKit|PersistenceKit|FeatureDealEntry|FeatureDashboard" "DesignSystem zero domain isolation"
}

# 5. Verify Accessibility Description Implementations
function Test-FileContains($path, $keyword, $label) {
    $content = Get-Content $path -Raw
    $found = $content -match $keyword
    Test-Check "$label implemented in $path" $found "Keyword $keyword not found in $path"
}

Test-FileContains "Sources/DesignSystem/Components/FinancialMetricCard.swift" "accessibilityDescription" "FinancialMetricCard Accessibility"
Test-FileContains "Sources/DesignSystem/Components/VerdictBadgeView.swift" "accessibilityDescription" "VerdictBadgeView Accessibility"
Test-FileContains "Sources/DesignSystem/Components/ReasonCodeRowView.swift" "accessibilityDescription" "ReasonCodeRowView Accessibility"
Test-FileContains "Sources/DesignSystem/Components/CurrencyTextFieldView.swift" "accessibilityDescription" "CurrencyTextFieldView Accessibility"
Test-FileContains "Sources/DesignSystem/Charts/SensitivityMatrixGridView.swift" "accessibilityDescription" "SensitivityMatrixGrid Accessibility"
Test-FileContains "Sources/DesignSystem/Charts/CashFlowWaterfallChartView.swift" "accessibilityDescription" "CashFlowWaterfallChart Accessibility"
Test-FileContains "Sources/DesignSystem/Typography/TypographyTokens.swift" "isTabularNumbers" "Tabular Numbers Alignment Support"

# Output Summary
Write-Host "`n=== Stage 5 Validation Summary ===" -ForegroundColor Cyan
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
    Write-Host "ALL STAGE 5 DESIGN SYSTEM & ACCESSIBILITY CHECKS PASSED." -ForegroundColor Green
    exit 0
}
