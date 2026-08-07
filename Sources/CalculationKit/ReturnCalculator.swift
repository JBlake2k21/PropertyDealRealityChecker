//
//  ReturnCalculator.swift
//  PropertyDealRealityChecker
//
//  Stage 3 — Deterministic Calculation Engine
//  Architectural Mandate: Cap Rate, Cash-on-Cash, DSCR, Break-Even Occupancy, LTC, LTV, and Debt Yield formulas.
//  May import ONLY Foundation. Never Double.
//

import Foundation

/// Pure deterministic calculator for investor return and risk-safety metrics.
public struct ReturnCalculator: Sendable {
    /// Calculates Capitalization Rate (Cap Rate) fraction.
    ///
    /// Per ADR-002, supports both Purchase Price (default) and Total Project Cost as the denominator.
    /// - Parameters:
    ///   - noi: Accounting Net Operating Income.
    ///   - purchasePrice: Contractual purchase price.
    ///   - totalProjectCost: Upfront acquisition cost (`Purchase Price + Rehab + Closing Costs`).
    ///   - useProjectCostAsDenominator: Whether to use Total Project Cost (`true`) or Purchase Price (`false`).
    /// - Returns: Capitalization Rate fraction (`0.07` for 7%).
    public static func calculateCapRate(
        noi: Decimal,
        purchasePrice: Decimal,
        totalProjectCost: Decimal,
        useProjectCostAsDenominator: Bool = false
    ) -> Decimal {
        let denominator = useProjectCostAsDenominator ? totalProjectCost : purchasePrice
        guard denominator > 0 else { return 0 }
        return noi / denominator
    }
    
    /// Calculates Cash-on-Cash Return (CoC) fraction.
    ///
    /// Formula: `Owner Pre-Tax Cash Flow / Total Initial Cash Required`
    /// - Parameters:
    ///   - ownerCashFlow: Annual Owner Pre-Tax Cash Flow.
    ///   - initialCashRequired: Upfront investor equity cash required.
    /// - Returns: Cash-on-Cash Return rate fraction (`0.08` for 8%).
    public static func calculateCashOnCashReturn(
        ownerCashFlow: Decimal,
        initialCashRequired: Decimal
    ) -> Decimal {
        guard initialCashRequired > 0 else {
            return ownerCashFlow > 0 ? 9.99 : 0 // Cap infinite return display at 999%
        }
        return ownerCashFlow / initialCashRequired
    }
    
    /// Calculates Debt Service Coverage Ratio (DSCR).
    ///
    /// Formula: `Accounting NOI / Annual Debt Service`
    /// - Parameters:
    ///   - noi: Accounting Net Operating Income.
    ///   - annualDebtService: Total annual contractual debt service (excluding balloon principal).
    /// - Returns: DSCR ratio (`1.25` for 1.25x). Returns `99.99` for all-cash deals.
    public static func calculateDSCR(
        noi: Decimal,
        annualDebtService: Decimal
    ) -> Decimal {
        guard annualDebtService > 0 else {
            return 99.99 // All-cash deal indicator
        }
        return noi / annualDebtService
    }
    
    /// Calculates Break-Even Occupancy Rate fraction.
    ///
    /// Formula: `(Mandatory Operating Expenses + Annual Debt Service) / Gross Scheduled Income (GSI)`
    /// - Parameters:
    ///   - operatingExpenses: Total annual mandatory operating expenses.
    ///   - annualDebtService: Total annual contractual debt service.
    ///   - gsi: Gross Scheduled Income.
    /// - Returns: Break-Even Occupancy Rate fraction (`0.75` for 75%).
    public static func calculateBreakEvenOccupancy(
        operatingExpenses: Decimal,
        annualDebtService: Decimal,
        gsi: Decimal
    ) -> Decimal {
        guard gsi > 0 else { return 1.0 }
        let requiredRevenue = operatingExpenses + annualDebtService
        let ratio = requiredRevenue / gsi
        return min(1.0, max(0, ratio))
    }
    
    /// Calculates Loan-to-Value (LTV) ratio fraction.
    ///
    /// Formula: `Total Debt Principal / Property Value or Purchase Price`
    /// - Parameters:
    ///   - totalDebtPrincipal: Sum of principal across all debt layers.
    ///   - propertyValue: Property value or contractual purchase price.
    /// - Returns: LTV fraction (`0.75` for 75%).
    public static func calculateLTV(
        totalDebtPrincipal: Decimal,
        propertyValue: Decimal
    ) -> Decimal {
        guard propertyValue > 0 else { return 0 }
        return totalDebtPrincipal / propertyValue
    }
    
    /// Calculates Loan-to-Cost (LTC) ratio fraction.
    ///
    /// Formula: `Total Debt Principal / Total Project Cost`
    /// - Parameters:
    ///   - totalDebtPrincipal: Sum of principal across all debt layers.
    ///   - totalProjectCost: Total upfront project cost (`Purchase Price + Rehab + Closing Costs`).
    /// - Returns: LTC fraction (`0.80` for 80%).
    public static func calculateLTC(
        totalDebtPrincipal: Decimal,
        totalProjectCost: Decimal
    ) -> Decimal {
        guard totalProjectCost > 0 else { return 0 }
        return totalDebtPrincipal / totalProjectCost
    }
    
    /// Calculates Debt Yield fraction.
    ///
    /// Formula: `Accounting NOI / Total Debt Principal`
    /// - Parameters:
    ///   - noi: Accounting Net Operating Income.
    ///   - totalDebtPrincipal: Sum of principal across all debt layers.
    /// - Returns: Debt Yield fraction (`0.10` for 10%).
    public static func calculateDebtYield(
        noi: Decimal,
        totalDebtPrincipal: Decimal
    ) -> Decimal {
        guard totalDebtPrincipal > 0 else { return 0 }
        return noi / totalDebtPrincipal
    }
}
