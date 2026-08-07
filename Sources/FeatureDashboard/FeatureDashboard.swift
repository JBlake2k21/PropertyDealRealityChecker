//
//  FeatureDashboard.swift
//  PropertyDealRealityChecker
//
//  Stage 1 Scaffolding — FeatureDashboard Module Marker
//  Architectural Mandate: Verdict presentation, metric cards, risk flag details, and driver breakdown.
//  Imports DealCore and DesignSystem.
//

import Foundation
import DealCore
import DesignSystem
#if canImport(SwiftUI)
import SwiftUI
#endif

/// The `FeatureDashboard` module namespace and presentation marker.
public struct FeatureDashboardModule: Sendable {
    /// Identifies the dashboard feature module version.
    public static let version: String = "1.0.0"
    
    /// Initializes the FeatureDashboard module marker.
    public init() {}
}
