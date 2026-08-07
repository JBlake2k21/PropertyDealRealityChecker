#
#  validate_stage_8.ps1
#  PropertyDealRealityChecker
#
#  Stage 8 Validator & Linter
#  Verifies RealityCheckerApp container shell completion.
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

Write-Host "=== Property Deal Reality Checker -- Stage 8 Validator ===" -ForegroundColor Cyan

# 1. Verify all Stage 8 files exist
$requiredFiles = @(
    "Sources/RealityCheckerApp/RealityCheckerApp.swift",
    "Sources/RealityCheckerApp/MainTabView.swift"
)

foreach ($filePath in $requiredFiles) {
    $fileExists = Test-Path $filePath
    Test-Check "File $filePath exists" $fileExists "File $filePath missing."
}

# 2. ANTI-DOUBLE LINTER
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

$appFiles = Get-ChildItem -Path "Sources/RealityCheckerApp" -Filter "*.swift" -Recurse
foreach ($file in $appFiles) {
    Test-NoFloatingPoint $file "Decimal-only policy"
}

# Output Summary
Write-Host "`n=== Stage 8 Validation Summary ===" -ForegroundColor Cyan
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
    Write-Host "ALL STAGE 8 CHECKS PASSED." -ForegroundColor Green
    exit 0
}
