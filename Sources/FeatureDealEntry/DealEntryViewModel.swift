//
//  DealEntryViewModel.swift
//  PropertyDealRealityChecker
//
//  Stage 6 — Feature Modules: Deal Entry, Underwriting Dashboard & Scenario Comparison
//  Architectural Mandate: State management for guided property deal entry using DraftDeal.
//  Zero imports of CalculationKit or PersistenceKit.
//

import Foundation
import DealCore
import DesignSystem
#if canImport(SwiftUI)
import SwiftUI
#endif

/// State management and validation view model for guided investment deal entry.
///
/// Implements Blueprint Section 12 ("Feature Modules and UI Architecture"):
/// - Captures investor inputs using an intermediate `DraftDeal`.
/// - Validates inputs in real-time to generate non-blocking `ValidationIssue` warnings.
/// - Converts clean drafts into an immutable `CanonicalDeal` for underwriting evaluation.
#if canImport(SwiftUI)
@Observable
#endif
public final class DealEntryViewModel: @unchecked Sendable {
    public var draftDeal: DraftDeal
    public var purchasePriceString: String = "300000"
    public var closingCostsString: String = "8000"
    public var monthlyRentString: String = "2800"
    public var annualTaxString: String = "4500"
    public var annualInsuranceString: String = "1800"
    public var mortgagePrincipalString: String = "240000"
    public var interestRatePercentageString: String = "6.5"
    public var validationIssues: [ValidationIssue] = []
    
    public init(draftDeal: DraftDeal = DraftDeal(name: "New Rental Property")) {
        self.draftDeal = draftDeal
        updateStringsFromDraft()
    }
    
    /// Updates string binding buffers from the current `draftDeal` state.
    public func updateStringsFromDraft() {
        purchasePriceString = "\(NSDecimalNumber(decimal: draftDeal.baseScenario.projectCost.purchasePrice.amount))"
        closingCostsString = "\(NSDecimalNumber(decimal: draftDeal.baseScenario.projectCost.closingCosts.amount))"
        
        if let firstRent = draftDeal.baseScenario.incomeLines.first {
            monthlyRentString = "\(NSDecimalNumber(decimal: firstRent.amount.amount))"
        }
        if let mortgage = draftDeal.baseScenario.financingPlan.firstMortgage {
            mortgagePrincipalString = "\(NSDecimalNumber(decimal: mortgage.principal.amount))"
            interestRatePercentageString = "\(NSDecimalNumber(decimal: mortgage.interestRate.percentage))"
        }
    }
    
    /// Parses string binding buffers into exact `Decimal` domain values without floating-point conversion.
    public func updateDraftFromStrings() {
        let priceDecimal = Decimal(string: purchasePriceString) ?? 0
        let closingDecimal = Decimal(string: closingCostsString) ?? 0
        draftDeal.baseScenario.projectCost = ProjectCost(
            purchasePrice: CurrencyAmount(amount: priceDecimal),
            closingCosts: CurrencyAmount(amount: closingDecimal)
        )
        
        let rentDecimal = Decimal(string: monthlyRentString) ?? 0
        draftDeal.baseScenario.incomeLines = [
            IncomeLine(category: .contractualRent, amount: CurrencyAmount(amount: rentDecimal), frequency: .monthly)
        ]
        
        let taxDecimal = Decimal(string: annualTaxString) ?? 0
        let insDecimal = Decimal(string: annualInsuranceString) ?? 0
        draftDeal.baseScenario.expenseLines = [
            ExpenseLine(category: .propertyTax, amount: CurrencyAmount(amount: taxDecimal), frequency: .annual),
            ExpenseLine(category: .insurance, amount: CurrencyAmount(amount: insDecimal), frequency: .annual)
        ]
        
        let principalDecimal = Decimal(string: mortgagePrincipalString) ?? 0
        let ratePctDecimal = Decimal(string: interestRatePercentageString) ?? 0
        let rateFraction = ratePctDecimal / 100
        
        draftDeal.baseScenario.financingPlan = FinancingPlan(debtLayers: [
            DebtLayer(
                name: "First Mortgage",
                principal: CurrencyAmount(amount: principalDecimal),
                interestRate: Rate(fraction: rateFraction),
                amortizationMonths: 360,
                contractualTermMonths: 360
            )
        ])
        
        self.validationIssues = draftDeal.validateDraft()
    }
    
    /// Validates the current draft deal and returns non-blocking validation findings.
    public func validate() -> [ValidationIssue] {
        updateDraftFromStrings()
        return validationIssues
    }
    
    /// Commits the draft deal into an immutable `CanonicalDeal` ready for calculation.
    /// - Throws: `DealValidationError` if required inputs are missing or invalid.
    /// - Returns: Immutable canonical deal aggregate.
    public func commitToCanonical() throws -> CanonicalDeal {
        updateDraftFromStrings()
        return try draftDeal.toCanonical()
    }
}
