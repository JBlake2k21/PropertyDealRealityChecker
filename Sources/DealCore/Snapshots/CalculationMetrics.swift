//
//  CalculationMetrics.swift
//  PropertyDealRealityChecker
//
//  Stage 2 — Domain Model & Financial Value Types
//  Architectural Mandate: Unrounded Decimal results for all core financial formulas. Never Double.
//

import Foundation

/// Encapsulates the unrounded deterministic calculation results for a deal scenario.
///
/// Backed strictly by Swift `Decimal`. Rounding occurs only at presentation boundaries.
public struct CalculationMetrics: Sendable, Codable, Hashable {
    /// Gross Scheduled Income (GSI): Total annualized contractual or market rent + other scheduled revenue.
    public var grossScheduledIncome: CurrencyAmount
    
    /// Effective Gross Income (EGI): GSI minus vacancy and credit loss.
    public var effectiveGrossIncome: CurrencyAmount
    
    /// Net Operating Income (NOI — Accounting): EGI minus mandatory operating expenses (excludes capital reserves and debt service).
    public var netOperatingIncome: CurrencyAmount
    
    /// Owner Pre-Tax Cash Flow: Accounting NOI minus capital replacement reserves minus annual debt service.
    public var ownerCashFlow: CurrencyAmount
    
    /// Capitalization Rate fraction (`NOI / Purchase Price`, default denominator as per ADR-002).
    public var capRate: Rate
    
    /// Cash-on-Cash Return fraction (`Owner Cash Flow / Total Initial Cash Required`).
    public var cashOnCashReturn: Rate
    
    /// Debt Service Coverage Ratio (`NOI / Annual Debt Service`). Excludes balloon principal as per ADR-005.
    public var dscr: Decimal
    
    /// Break-Even Occupancy Rate fraction (`(Operating Expenses + Debt Service) / GSI`).
    public var breakEvenOccupancyRate: Rate
    
    /// Loan-to-Cost ratio fraction (`Total Debt Principal / Total Project Cost`).
    public var loanToCost: Rate
    
    /// Loan-to-Value ratio fraction (`Total Debt Principal / Property Value or Purchase Price`).
    public var loanToValue: Rate
    
    /// Debt Yield fraction (`NOI / Total Debt Principal`).
    public var debtYield: Rate
    
    /// Total upfront cash required from the investor (`Total Project Cost - Debt - Seller Credits`).
    public var initialCashRequired: CurrencyAmount
    
    /// Total annualized debt service across all amortizing and interest-only layers.
    public var annualDebtService: CurrencyAmount
    
    /// Total balloon principal due at maturity, if applicable.
    public var balloonPrincipalBurden: CurrencyAmount
    
    /// Initializes a calculation metrics struct.
    public init(
        grossScheduledIncome: CurrencyAmount = .zero,
        effectiveGrossIncome: CurrencyAmount = .zero,
        netOperatingIncome: CurrencyAmount = .zero,
        ownerCashFlow: CurrencyAmount = .zero,
        capRate: Rate = .zero,
        cashOnCashReturn: Rate = .zero,
        dscr: Decimal = 0,
        breakEvenOccupancyRate: Rate = .zero,
        loanToCost: Rate = .zero,
        loanToValue: Rate = .zero,
        debtYield: Rate = .zero,
        initialCashRequired: CurrencyAmount = .zero,
        annualDebtService: CurrencyAmount = .zero,
        balloonPrincipalBurden: CurrencyAmount = .zero
    ) {
        self.grossScheduledIncome = grossScheduledIncome
        self.effectiveGrossIncome = effectiveGrossIncome
        self.netOperatingIncome = netOperatingIncome
        self.ownerCashFlow = ownerCashFlow
        self.capRate = capRate
        self.cashOnCashReturn = cashOnCashReturn
        self.dscr = dscr
        self.breakEvenOccupancyRate = breakEvenOccupancyRate
        self.loanToCost = loanToCost
        self.loanToValue = loanToValue
        self.debtYield = debtYield
        self.initialCashRequired = initialCashRequired
        self.annualDebtService = annualDebtService
        self.balloonPrincipalBurden = balloonPrincipalBurden
    }
}
