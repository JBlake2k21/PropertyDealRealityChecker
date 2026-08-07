//
//  FinancingPlan.swift
//  PropertyDealRealityChecker
//
//  Stage 2 — Domain Model & Financial Value Types
//  Architectural Mandate: Collection of debt layers supporting all-cash, single mortgage, and multi-lien structures.
//

import Foundation

/// A structured financing plan containing one or more debt layers.
public struct FinancingPlan: Sendable, Codable, Hashable {
    /// Ordered list of debt layers (first lien first).
    public var debtLayers: [DebtLayer]
    
    /// Initializes a financing plan.
    public init(debtLayers: [DebtLayer] = []) {
        self.debtLayers = debtLayers.sorted { $0.lienPosition < $1.lienPosition }
    }
    
    /// Standard all-cash financing plan (zero debt layers).
    public static let allCash = FinancingPlan(debtLayers: [])
    
    /// Returns true if there are zero active debt layers.
    public var isAllCash: Bool {
        debtLayers.isEmpty || totalDebtPrincipal.amount == 0
    }
    
    /// Returns the total principal across all debt layers.
    public var totalDebtPrincipal: CurrencyAmount {
        guard let first = debtLayers.first else {
            return .zero
        }
        let total = debtLayers.reduce(Decimal(0)) { $0 + $1.principal.amount }
        return CurrencyAmount(amount: total, currencyCode: first.principal.currencyCode)
    }
    
    /// Returns the primary first-position mortgage, if present.
    public var firstMortgage: DebtLayer? {
        debtLayers.first { $0.lienPosition == 1 }
    }
    
    /// Returns all subordinate or second-position debt layers.
    public var subordinateLayers: [DebtLayer] {
        debtLayers.filter { $0.lienPosition > 1 }
    }
    
    /// Returns whether any debt layer in this plan has a balloon maturity.
    public var hasBalloon: Bool {
        debtLayers.contains { $0.hasBalloon }
    }
}
