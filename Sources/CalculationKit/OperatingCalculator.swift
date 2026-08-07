//
//  OperatingCalculator.swift
//  PropertyDealRealityChecker
//
//  Stage 3 — Deterministic Calculation Engine
//  Architectural Mandate: Operating income, vacancy, expense, NOI, and cash flow formulas.
//  May import ONLY Foundation.
//

import Foundation

/// Represents an annualized operating cost or capital reserve line item passed into `CalculationKit`.
public struct OperatingInputLine: Sendable, Hashable {
    /// Item label or category name.
    public let name: String
    
    /// Annualized Decimal amount.
    public let annualAmount: Decimal
    
    /// Whether this item is deducted when calculating Accounting Net Operating Income (`true` for operating expenses; `false` for capital reserves).
    public let isNOIExpense: Bool
    
    /// Initializes an operating input line.
    public init(name: String, annualAmount: Decimal, isNOIExpense: Bool = true) {
        self.name = name
        self.annualAmount = annualAmount
        self.isNOIExpense = isNOIExpense
    }
}

/// Pure deterministic calculator for Gross Scheduled Income (GSI), Effective Gross Income (EGI),
/// Accounting Net Operating Income (NOI), and Owner Pre-Tax Cash Flow.
public struct OperatingCalculator: Sendable {
    /// Calculates Gross Scheduled Income (GSI) from a collection of annualized revenue amounts.
    /// - Parameter annualIncomeAmounts: Array of annualized revenue line amounts.
    /// - Returns: Total Gross Scheduled Income (`GSI`).
    public static func calculateGSI(annualIncomeAmounts: [Decimal]) -> Decimal {
        annualIncomeAmounts.reduce(0, +)
    }
    
    /// Calculates Effective Gross Income (EGI) after deducting vacancy and credit loss fractions.
    ///
    /// Formula: `EGI = GSI * (1 - vacancyRate - creditLossRate)`
    /// - Parameters:
    ///   - gsi: Total Gross Scheduled Income.
    ///   - vacancyRate: Vacancy rate fraction (`0.08` for 8%).
    ///   - creditLossRate: Credit loss and bad debt fraction (default: `0.0`).
    /// - Returns: Effective Gross Income (`EGI`).
    public static func calculateEGI(gsi: Decimal, vacancyRate: Decimal, creditLossRate: Decimal = 0) -> Decimal {
        let totalLossRate = vacancyRate + creditLossRate
        let effectiveFactor = max(0, 1 - totalLossRate)
        return gsi * effectiveFactor
    }
    
    /// Calculates total mandatory operating expenses included in Accounting NOI (`isNOIExpense == true`).
    /// - Parameter expenseLines: Array of operating input lines.
    /// - Returns: Sum of mandatory operating expenses.
    public static func calculateOperatingExpensesTotal(expenseLines: [OperatingInputLine]) -> Decimal {
        expenseLines
            .filter { $0.isNOIExpense }
            .reduce(0) { $0 + $1.annualAmount }
    }
    
    /// Calculates total capital replacement reserves excluded from Accounting NOI (`isNOIExpense == false`).
    /// - Parameter expenseLines: Array of operating input lines.
    /// - Returns: Sum of capital replacement reserves.
    public static func calculateCapitalReservesTotal(expenseLines: [OperatingInputLine]) -> Decimal {
        expenseLines
            .filter { !$0.isNOIExpense }
            .reduce(0) { $0 + $1.annualAmount }
    }
    
    /// Calculates Accounting Net Operating Income (NOI) in accordance with Blueprint Section 14.
    ///
    /// Formula: `Accounting NOI = EGI - Total Mandatory Operating Expenses`
    /// (Capital reserves and debt service are strictly excluded).
    /// - Parameters:
    ///   - egi: Effective Gross Income.
    ///   - expenseLines: Array of operating and reserve input lines.
    /// - Returns: Accounting Net Operating Income (`NOI`).
    public static func calculateNOI(egi: Decimal, expenseLines: [OperatingInputLine]) -> Decimal {
        let operatingExpenses = calculateOperatingExpensesTotal(expenseLines: expenseLines)
        return egi - operatingExpenses
    }
    
    /// Calculates Owner Pre-Tax Cash Flow in accordance with Blueprint Section 14.
    ///
    /// Formula: `Owner Cash Flow = Accounting NOI - Capital Replacement Reserves - Annual Debt Service`
    /// - Parameters:
    ///   - noi: Accounting Net Operating Income.
    ///   - capitalReserves: Total annual capital replacement reserves.
    ///   - annualDebtService: Total annual contractual debt service (excluding balloon principal).
    /// - Returns: Owner Pre-Tax Cash Flow.
    public static func calculateOwnerCashFlow(
        noi: Decimal,
        capitalReserves: Decimal,
        annualDebtService: Decimal
    ) -> Decimal {
        noi - capitalReserves - annualDebtService
    }
}
