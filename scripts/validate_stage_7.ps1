#
#  validate_stage_7.ps1
#  PropertyDealRealityChecker
#
#  Stage 7 Validator & Linter
#  Verifies ExportKit and ExplanationKit completion.
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

Write-Host "=== Property Deal Reality Checker -- Stage 7 Validator ===" -ForegroundColor Cyan

# 1. Verify all Stage 7 files exist
$requiredFiles = @(
    "Sources/ExplanationKit/ExplanationEngine.swift",
    "Sources/ExplanationKit/MarkdownRenderer.swift",
    "Sources/ExportKit/CSVEncoder.swift",
    "Sources/ExportKit/PDFReportGenerator.swift"
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

$explanationFiles = Get-ChildItem -Path "Sources/ExplanationKit" -Filter "*.swift" -Recurse
foreach ($file in $explanationFiles) {
    Test-NoFloatingPoint $file "Decimal-only policy"
}

$exportFiles = Get-ChildItem -Path "Sources/ExportKit" -Filter "*.swift" -Recurse
foreach ($file in $exportFiles) {
    Test-NoFloatingPoint $file "Decimal-only policy"
}

# Output Summary
Write-Host "`n=== Stage 7 Validation Summary ===" -ForegroundColor Cyan
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
    Write-Host "ALL STAGE 7 CHECKS PASSED." -ForegroundColor Green
    exit 0
}
