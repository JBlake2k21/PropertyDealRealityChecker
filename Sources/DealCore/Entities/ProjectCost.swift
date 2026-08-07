//
//  ProjectCost.swift
//  PropertyDealRealityChecker
//
//  Stage 2 — Domain Model & Financial Value Types
//  Architectural Mandate: Upfront capital allocation, rehab budgets, closing costs, and seller credits.
//

import Foundation

/// Itemized upfront capital uses, acquisition costs, and seller concessions for a scenario.
public struct ProjectCost: Sendable, Codable, Hashable {
    /// Contractual purchase price of the property.
    public var purchasePrice: CurrencyAmount
    
    /// Acquisition closing costs (title, escrow, transfer taxes, attorney fees, inspection).
    public var closingCosts: CurrencyAmount
    
    /// Estimated rehabilitation and capital improvement budget.
    public var rehabBudget: CurrencyAmount
    
    /// Rehab contingency reserve (default 10–15% of rehab budget).
    public var rehabContingency: CurrencyAmount
    
    /// Upfront loan origination, points, and financing fees.
    public var financingFees: CurrencyAmount
    
    /// Seller-paid closing credits or price concessions (reduces initial cash required).
    public var sellerCredits: CurrencyAmount
    
    /// Initializes a project cost allocation.
    public init(
        purchasePrice: CurrencyAmount,
        closingCosts: CurrencyAmount = .zero,
        rehabBudget: CurrencyAmount = .zero,
        rehabContingency: CurrencyAmount = .zero,
        financingFees: CurrencyAmount = .zero,
        sellerCredits: CurrencyAmount = .zero
    ) {
        self.purchasePrice = purchasePrice
        self.closingCosts = closingCosts
        self.rehabBudget = rehabBudget
        self.rehabContingency = rehabContingency
        self.financingFees = financingFees
        self.sellerCredits = sellerCredits
    }
    
    /// Returns the total capital cost of the project before financing:
    /// `Purchase Price + Closing Costs + Rehab Budget + Rehab Contingency + Financing Fees`
    ///
    /// This value serves as the denominator for Loan-to-Cost (LTC).
    public var totalProjectCost: CurrencyAmount {
        let total = purchasePrice.amount +
                    closingCosts.amount +
                    rehabBudget.amount +
                    rehabContingency.amount +
                    financingFees.amount
        return CurrencyAmount(amount: total, currencyCode: purchasePrice.currencyCode)
    }
    
    /// Returns the total upfront cash required from the investor given a total debt principal amount:
    /// `Total Project Cost - Total Debt Principal - Seller Credits`
    public func totalInitialCashRequired(totalDebtPrincipal: CurrencyAmount) -> CurrencyAmount {
        let cash = totalProjectCost.amount - totalDebtPrincipal.amount - sellerCredits.amount
        let clamped = max(0, cash)
        return CurrencyAmount(amount: clamped, currencyCode: purchasePrice.currencyCode)
    }
}
