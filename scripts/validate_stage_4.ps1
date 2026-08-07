#
#  validate_stage_4.ps1
#  PropertyDealRealityChecker
#
#  Stage 4 Platform-Independent Static Validator & Anti-Double Linter
#  Verifies persistence schemas, repository pattern, DTO mapper isolation, and migration supervisor.
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

Write-Host "=== Property Deal Reality Checker -- Stage 4 Validator & Anti-Double Linter ===" -ForegroundColor Cyan

# 1. Verify all Stage 4 PersistenceKit source files exist
$requiredPersistFiles = @(
    "Sources/PersistenceKit/Schemas/SchemaVersion.swift",
    "Sources/PersistenceKit/Schemas/PersistedDeal.swift",
    "Sources/PersistenceKit/Schemas/PersistedScenario.swift",
    "Sources/PersistenceKit/Schemas/PersistedSnapshot.swift",
    "Sources/PersistenceKit/Mappers/DealMapper.swift",
    "Sources/PersistenceKit/Repositories/DealRepository.swift",
    "Sources/PersistenceKit/Repositories/InMemoryDealRepository.swift",
    "Sources/PersistenceKit/Repositories/SwiftDataDealRepository.swift",
    "Sources/PersistenceKit/Migrations/PersistenceSupervisor.swift"
)

foreach ($filePath in $requiredPersistFiles) {
    $fileExists = Test-Path $filePath
    Test-Check "Persistence source file $filePath exists" $fileExists "File $filePath missing."
}

# 2. Verify unit test files exist
$requiredTestFiles = @(
    "Tests/PersistenceKitTests/DealMapperTests.swift",
    "Tests/PersistenceKitTests/InMemoryRepositoryTests.swift",
    "Tests/PersistenceKitTests/PersistenceSupervisorTests.swift"
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

foreach ($file in $coreFiles) {
    Test-NoFloatingPoint $file "Decimal-only policy"
}
foreach ($file in $calcFiles) {
    Test-NoFloatingPoint $file "Decimal-only policy"
}
foreach ($file in $persistFiles) {
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

foreach ($file in $persistFiles) {
    Test-FileImports $file "SwiftUI|UIKit|CalculationKit" "PersistenceKit isolation"
}
foreach ($file in $coreFiles) {
    Test-FileImports $file "SwiftUI|SwiftData|UIKit|PersistenceKit" "DealCore isolation"
}
foreach ($file in $calcFiles) {
    Test-FileImports $file "DealCore|SwiftUI|SwiftData|UIKit|PersistenceKit" "CalculationKit isolation"
}

# 5. Verify Repository & Migration Completeness
function Test-FileContains($path, $keyword, $label) {
    $content = Get-Content $path -Raw
    $found = $content -match $keyword
    Test-Check "$label implemented in $path" $found "Keyword $keyword not found in $path"
}

Test-FileContains "Sources/PersistenceKit/Mappers/DealMapper.swift" "toPersistence" "DealMapper toPersistence"
Test-FileContains "Sources/PersistenceKit/Mappers/DealMapper.swift" "toDomain" "DealMapper toDomain"
Test-FileContains "Sources/PersistenceKit/Repositories/DealRepository.swift" "fetchAllDeals" "DealRepository fetchAllDeals"
Test-FileContains "Sources/PersistenceKit/Repositories/DealRepository.swift" "saveDeal" "DealRepository saveDeal"
Test-FileContains "Sources/PersistenceKit/Repositories/DealRepository.swift" "fetchSnapshots" "DealRepository fetchSnapshots"
Test-FileContains "Sources/PersistenceKit/Migrations/PersistenceSupervisor.swift" "checkAndRecoverStoreHealth" "PersistenceSupervisor Health Check"
Test-FileContains "Sources/PersistenceKit/Migrations/PersistenceSupervisor.swift" "quarantineCorruptedStore" "Quarantine Corrupted Store Recovery"

# Output Summary
Write-Host "`n=== Stage 4 Validation Summary ===" -ForegroundColor Cyan
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
    Write-Host "ALL STAGE 4 PERSISTENCE & ANTI-DOUBLE CHECKS PASSED." -ForegroundColor Green
    exit 0
}
