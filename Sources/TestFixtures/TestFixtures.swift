//
//  TestFixtures.swift
//  PropertyDealRealityChecker
//
//  Stage 1 Scaffolding — TestFixtures Module Marker
//  Architectural Mandate: Canonical golden deals, verified amortization schedules, and edge-case mocks.
//  Imports DealCore and CalculationKit.
//

import Foundation
import DealCore
import CalculationKit

/// The `TestFixtures` module namespace and fixture catalog marker.
///
/// Houses verified spreadsheet golden deals (Rental-US-1.0), edge-case validation
/// scenarios, and deterministic calculation expectations.
public struct TestFixturesModule: Sendable {
    /// Identifies the golden fixture catalog version.
    public static let catalogVersion: String = "Rental-US-1.0-Golden"
    
    /// Initializes the TestFixtures module marker.
    public init() {}
}
