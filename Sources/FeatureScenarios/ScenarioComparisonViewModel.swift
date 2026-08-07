//
//  ScenarioComparisonViewModel.swift
//  PropertyDealRealityChecker
//
//  Stage 6 — Feature Modules: Deal Entry, Underwriting Dashboard & Scenario Comparison
//  Architectural Mandate: Side-by-side scenario comparator for Base, Optimistic, and Conservative cases.
//  Zero imports of CalculationKit or PersistenceKit.
//

import Foundation
import DealCore
import DesignSystem
#if canImport(SwiftUI)
import SwiftUI
#endif

/// Data model representing a single scenario column in a side-by-side comparison table.
public struct ScenarioComparisonColumnModel: Sendable, Hashable, Codable, Identifiable {
    public let id: UUID
    public let scenarioName: String
    public let noiText: String
    public let capRateText: String
    public let cocText: String
    public let dscrText: String
    public let isPassing: Bool
    
    public init(
        id: UUID = UUID(),
        scenarioName: String,
        noiText: String,
        capRateText: String,
        cocText: String,
        dscrText: String,
        isPassing: Bool
    ) {
        self.id = id
        self.scenarioName = scenarioName
        self.noiText = noiText
        self.capRateText = capRateText
        self.cocText = cocText
        self.dscrText = dscrText
        self.isPassing = isPassing
    }
}

/// Side-by-side scenario comparison view model.
///
/// Implements Blueprint Section 12 ("Feature Modules and UI Architecture"):
/// - Allows small investors to evaluate sensitivity across Optimistic, Base, and Conservative underwriting scenarios.
#if canImport(SwiftUI)
@Observable
#endif
public final class ScenarioComparisonViewModel: @unchecked Sendable {
    public var columns: [ScenarioComparisonColumnModel] = []
    
    public init(columns: [ScenarioComparisonColumnModel] = []) {
        self.columns = columns
    }
    
    /// Adds a scenario comparison column to the table.
    public func addScenario(
        name: String,
        noi: CurrencyAmount,
        capRate: Rate,
        coc: Rate,
        dscr: Decimal,
        isPassing: Bool
    ) {
        let noiString = "$\(NSDecimalNumber(decimal: noi.amount))"
        let capString = String(format: "%.2f%%", NSDecimalNumber(decimal: capRate.percentage).doubleValue)
        let cocString = String(format: "%.2f%%", NSDecimalNumber(decimal: coc.percentage).doubleValue)
        let dscrString = String(format: "%.2fx", NSDecimalNumber(decimal: dscr).doubleValue)
        
        let column = ScenarioComparisonColumnModel(
            scenarioName: name,
            noiText: noiString,
            capRateText: capString,
            cocText: cocString,
            dscrText: dscrString,
            isPassing: isPassing
        )
        columns.append(column)
    }
}
