//
//  FeatureScenarios.swift
//  PropertyDealRealityChecker
//
//  Stage 1 Scaffolding — FeatureScenarios Module Marker
//  Architectural Mandate: Scenario duplication, sensitivity analysis grids, and interactive chart views.
//  Imports DealCore and DesignSystem.
//

import Foundation
import DealCore
import DesignSystem
#if canImport(SwiftUI)
import SwiftUI
#endif

/// The `FeatureScenarios` module namespace and sensitivity analysis marker.
public struct FeatureScenariosModule: Sendable {
    /// Identifies the scenarios feature module version.
    public static let version: String = "1.0.0"
    
    /// Initializes the FeatureScenarios module marker.
    public init() {}
}
