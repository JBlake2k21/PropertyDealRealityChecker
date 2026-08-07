#
#  validate_stage_6.ps1
#  PropertyDealRealityChecker
#
#  Stage 6 Platform-Independent Static Validator & Architectural Linter
#  Verifies feature module views, view models, zero forbidden imports, and state reactivity.
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

Write-Host "=== Property Deal Reality Checker -- Stage 6 Validator & Architectural Linter ===" -ForegroundColor Cyan

# 1. Verify all Stage 6 Feature source files exist
$requiredFeatureFiles = @(
    "Sources/FeatureDealEntry/DealEntryViewModel.swift",
    "Sources/FeatureDealEntry/DealEntryView.swift",
    "Sources/FeatureDashboard/DashboardViewModel.swift",
    "Sources/FeatureDashboard/DashboardView.swift",
    "Sources/FeatureScenarios/ScenarioComparisonViewModel.swift",
    "Sources/FeatureScenarios/ScenarioComparisonView.swift"
)

foreach ($filePath in $requiredFeatureFiles) {
    $fileExists = Test-Path $filePath
    Test-Check "Feature file $filePath exists" $fileExists "File $filePath missing."
}

# 2. Verify unit test files exist
$requiredTestFiles = @(
    "Tests/FeatureDealEntryTests/DealEntryViewModelTests.swift",
    "Tests/FeatureDashboardTests/DashboardViewModelTests.swift",
    "Tests/FeatureScenariosTests/ScenarioComparisonTests.swift"
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

# 4. Verify Package Isolation (Feature packages must NEVER import CalculationKit or PersistenceKit)
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

$entryFiles = Get-ChildItem -Path "Sources/FeatureDealEntry" -Filter "*.swift" -Recurse
$dashFiles = Get-ChildItem -Path "Sources/FeatureDashboard" -Filter "*.swift" -Recurse
$scenFiles = Get-ChildItem -Path "Sources/FeatureScenarios" -Filter "*.swift" -Recurse

foreach ($file in $entryFiles) {
    Test-FileImports $file "CalculationKit|PersistenceKit|FeatureDashboard|FeatureScenarios" "FeatureDealEntry isolation"
}
foreach ($file in $dashFiles) {
    Test-FileImports $file "CalculationKit|PersistenceKit|FeatureDealEntry|FeatureScenarios" "FeatureDashboard isolation"
}
foreach ($file in $scenFiles) {
    Test-FileImports $file "CalculationKit|PersistenceKit|FeatureDealEntry|FeatureDashboard" "FeatureScenarios isolation"
}

# 5. Verify ViewModel Architecture & State Methods
function Test-FileContains($path, $keyword, $label) {
    $content = Get-Content $path -Raw
    $found = $content -match $keyword
    Test-Check "$label implemented in $path" $found "Keyword $keyword not found in $path"
}

Test-FileContains "Sources/FeatureDealEntry/DealEntryViewModel.swift" "commitToCanonical" "DealEntryViewModel commitToCanonical"
Test-FileContains "Sources/FeatureDealEntry/DealEntryViewModel.swift" "updateDraftFromStrings" "DealEntryViewModel updateDraftFromStrings"
Test-FileContains "Sources/FeatureDashboard/DashboardViewModel.swift" "metricCards" "DashboardViewModel metricCards"
Test-FileContains "Sources/FeatureDashboard/DashboardViewModel.swift" "waterfallModel" "DashboardViewModel waterfallModel"
Test-FileContains "Sources/FeatureScenarios/ScenarioComparisonViewModel.swift" "addScenario" "ScenarioComparisonViewModel addScenario"

# Output Summary
Write-Host "`n=== Stage 6 Validation Summary ===" -ForegroundColor Cyan
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
    Write-Host "ALL STAGE 6 FEATURE MODULES & ARCHITECTURAL CHECKS PASSED." -ForegroundColor Green
    exit 0
}
