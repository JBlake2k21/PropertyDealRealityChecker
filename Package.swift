// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PropertyDealRealityChecker",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v18),
        .macOS(.v15)
    ],
    products: [
        // App Core Target
        .executable(name: "RealityCheckerApp", targets: ["RealityCheckerApp"]),
        
        // Domain & Calculation Engine
        .library(name: "DealCore", targets: ["DealCore"]),
        .library(name: "CalculationKit", targets: ["CalculationKit"]),
        
        // Persistence Layer
        .library(name: "PersistenceKit", targets: ["PersistenceKit"]),
        
        // Feature Modules
        .library(name: "FeatureDealEntry", targets: ["FeatureDealEntry"]),
        .library(name: "FeatureDashboard", targets: ["FeatureDashboard"]),
        .library(name: "FeatureScenarios", targets: ["FeatureScenarios"]),
        
        // Reporting, Explanations & Design System
        .library(name: "ExplanationKit", targets: ["ExplanationKit"]),
        .library(name: "ExportKit", targets: ["ExportKit"]),
        .library(name: "DesignSystem", targets: ["DesignSystem"]),
        
        // Testing & Fixture Support
        .library(name: "TestFixtures", targets: ["TestFixtures"])
    ],
    dependencies: [
        // Zero third-party dependencies as mandated by ADR-009 / Blueprint Rule 6.
    ],
    targets: [
        // 1. Pure Deterministic Mathematical Engine (No UI/Persistence dependencies)
        .target(
            name: "CalculationKit",
            dependencies: []
        ),
        
        // 2. Pure Domain Models, Rules, and Entity Definitions
        .target(
            name: "DealCore",
            dependencies: ["CalculationKit"]
        ),
        
        // 3. Shared Design System & Typography/Chart Tokens
        .target(
            name: "DesignSystem",
            dependencies: []
        ),
        
        // 4. Persistence Repository Abstraction & SwiftData Schemas
        .target(
            name: "PersistenceKit",
            dependencies: ["DealCore"]
        ),
        
        // 5. Feature Modules
        .target(
            name: "FeatureDealEntry",
            dependencies: ["DealCore", "DesignSystem"]
        ),
        .target(
            name: "FeatureDashboard",
            dependencies: ["DealCore", "DesignSystem"]
        ),
        .target(
            name: "FeatureScenarios",
            dependencies: ["DealCore", "DesignSystem"]
        ),
        
        // 6. Explanation & Report Export Engines
        .target(
            name: "ExplanationKit",
            dependencies: ["DealCore"]
        ),
        .target(
            name: "ExportKit",
            dependencies: ["DealCore"]
        ),
        
        // 7. Shared Test Fixtures
        .target(
            name: "TestFixtures",
            dependencies: ["DealCore", "CalculationKit"]
        ),
        
        // 8. Application Shell & Dependency Container
        .executableTarget(
            name: "RealityCheckerApp",
            dependencies: [
                "DealCore",
                "CalculationKit",
                "PersistenceKit",
                "FeatureDealEntry",
                "FeatureDashboard",
                "FeatureScenarios",
                "ExplanationKit",
                "ExportKit",
                "DesignSystem"
            ]
        ),
        
        // MARK: - Test Targets
        .testTarget(
            name: "CalculationKitTests",
            dependencies: ["CalculationKit", "TestFixtures"]
        ),
        .testTarget(
            name: "DealCoreTests",
            dependencies: ["DealCore", "CalculationKit", "TestFixtures"]
        ),
        .testTarget(
            name: "PersistenceKitTests",
            dependencies: ["PersistenceKit", "DealCore", "TestFixtures"]
        ),
        .testTarget(
            name: "FeatureTests",
            dependencies: [
                "FeatureDealEntry",
                "FeatureDashboard",
                "FeatureScenarios",
                "DesignSystem",
                "TestFixtures"
            ]
        ),
        .testTarget(
            name: "ExplanationKitTests",
            dependencies: ["ExplanationKit", "DealCore", "TestFixtures"]
        ),
        .testTarget(
            name: "ExportKitTests",
            dependencies: ["ExportKit", "DealCore", "TestFixtures"]
        ),
        .testTarget(
            name: "RealityCheckerAppTests",
            dependencies: ["RealityCheckerApp", "TestFixtures"]
        )
    ]
)
