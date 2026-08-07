//
//  RealityCheckerApp.swift
//  PropertyDealRealityChecker
//
//  Stage 1 Scaffolding — RealityCheckerApp Module Marker & Container Shell
//  Architectural Mandate: Application shell, dependency container, navigation root, and StoreKit entitlements.
//

import Foundation
import DealCore
import CalculationKit
import PersistenceKit
import FeatureDealEntry
import FeatureDashboard
import FeatureScenarios
import ExplanationKit
import ExportKit
import DesignSystem
#if canImport(SwiftUI)
import SwiftUI
#endif

/// The top-level application dependency container and release marker.
///
/// Wires together domain engines, repositories, feature modules, explanation renderers,
/// and export services without violating unidirectional package boundaries.
public struct RealityCheckerAppModule: Sendable {
    /// Identifies the application release version.
    public static let appVersion: String = "1.0.0"
    
    /// Initializes the application dependency container marker.
    public init() {}
    
    /// Returns the active engine version from CalculationKit.
    public static var activeEngineVersion: String {
        CalculationKitModule.engineVersion
    }
    
    /// Returns the active rule-set version from DealCore.
    public static var activeRuleSetVersion: String {
        DealCoreModule.ruleSetVersion
    }
}

#if canImport(SwiftUI) && canImport(SwiftData)
import SwiftData

@main
struct RealityCheckerApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            PersistedDeal.self,
            PersistedScenario.self,
            PersistedSnapshot.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(sharedModelContainer)
    }
}
#endif
