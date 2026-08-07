//
//  DealCore.swift
//  PropertyDealRealityChecker
//
//  Stage 1 Scaffolding — DealCore Module Marker
//  Architectural Mandate: Pure Swift domain entities, verdict rules, and reason codes.
//  May import ONLY Foundation and CalculationKit. Must NEVER import SwiftUI, SwiftData, or AI libraries.
//

import Foundation
import CalculationKit

/// The `DealCore` module namespace and rule-set version marker.
///
/// Encapsulates domain entities (`Deal`, `Property`, `Scenario`, `Assumption`, `DebtLayer`),
/// validation rules, confidence scoring, verdict assignment, and `CalculationSnapshot` immutability.
public struct DealCoreModule: Sendable {
    /// Canonical rule-set version as mandated by Blueprint Appendix A.
    public static let ruleSetVersion: String = "Rental-US-1.0"
    
    /// Initializes the DealCore module marker.
    public init() {}
    
    /// Returns the underlying calculation engine version imported from `CalculationKit`.
    public static var engineVersion: String {
        CalculationKitModule.engineVersion
    }
}
