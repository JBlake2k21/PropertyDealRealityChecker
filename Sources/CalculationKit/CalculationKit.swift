//
//  CalculationKit.swift
//  PropertyDealRealityChecker
//
//  Stage 1 Scaffolding — CalculationKit Module Marker
//  Architectural Mandate: Pure Swift financial math engine using Decimal.
//  May import ONLY Foundation. Must NEVER import SwiftUI, SwiftData, or any UI/Persistence framework.
//

import Foundation

/// The `CalculationKit` module namespace and architectural version marker.
///
/// Encapsulates all deterministic financial formulas, amortization scheduling,
/// operating metrics, return calculations, and sensitivity stress matrices.
public struct CalculationKitModule: Sendable {
    /// Canonical formula engine version as mandated by Blueprint Appendix A.
    public static let engineVersion: String = "1.0.0"
    
    /// Initializes the CalculationKit module marker.
    public init() {}
}
