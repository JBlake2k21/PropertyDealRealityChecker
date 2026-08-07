# Property Deal Reality Checker

**Property Deal Reality Checker** is a production-quality native iOS application designed for small residential real-estate investors (1–20 units) to evaluate whether a property remains financially viable after realistic financing, vacancy, operating expenses, repairs, reserves, closing costs, rehabilitation costs, and exit assumptions are applied.

---

## Architectural & Technical Foundation
* **Platform**: Native iOS 18.0+ / iPadOS 18.0+ (SwiftUI, SwiftData, Swift Charts, StoreKit 2, PDFKit).
* **Modular Architecture**: Built as a decoupled multi-package workspace (`RealityCheckerApp`, `DealCore`, `CalculationKit`, `PersistenceKit`, `FeatureDealEntry`, `FeatureDashboard`, `FeatureScenarios`, `ExplanationKit`, `ExportKit`, `DesignSystem`, `TestFixtures`).
* **Mathematical Precision**: 100% `Decimal` arithmetic across all formulas and debt schedules. Binary floating-point types (`Double`/`Float`) are strictly prohibited in financial calculations.
* **Local-First & Offline**: Complete offline-first execution with on-device Data Protection and Keychain security. Zero custom backends or third-party telemetry SDKs.
* **AI Exclusion Boundary**: Deterministic rules generate all verdicts, confidence scores, and reason codes. AI is never permitted to calculate, modify, invent, or independently approve financial values.

---

## Target Dependency Graph
```
[RealityCheckerApp]
       │
       ├───► [FeatureDealEntry]  ───┐
       ├───► [FeatureDashboard]  ───┼──► [DesignSystem]
       └───► [FeatureScenarios]  ───┤
                                    │
       ┌────────────────────────────┘
       ▼
[PersistenceKit] (SwiftData Repositories)
       │
       ▼
 [DealCore] (Domain Entities, Verdicts, Confidence, Reason Codes)
       │
       ▼
[CalculationKit] (Pure Decimal Math, Amortization, Returns, Stress Engine)
```

---

## Verification & Build Instructions
1. **Platform-Independent Static Validation**:  
   Run python validation script `scripts/validate_package_boundaries.py` to verify strict dependency rules and package structure.
2. **Xcode / macOS Simulator Verification**:  
   Open `PropertyDealRealityChecker.xcworkspace` or `Package.swift` in Xcode 16+ on macOS Sequoia+ to compile targets and run unit tests.
