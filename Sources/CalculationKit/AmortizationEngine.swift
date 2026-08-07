//
//  AmortizationEngine.swift
//  PropertyDealRealityChecker
//
//  Stage 3 — Deterministic Calculation Engine
//  Architectural Mandate: Decimal mortgage payments, amortization schedules, and balloon remaining balance.
//  May import ONLY Foundation. Never Double.
//

import Foundation

/// Represents a clean loan input specification passed into `CalculationKit`.
public struct AmortizationInputLayer: Sendable, Hashable {
    /// Loan label.
    public let name: String
    /// Principal loan amount.
    public let principal: Decimal
    /// Canonical annual interest rate fraction (`0.07` for 7%).
    public let annualInterestRate: Decimal
    /// Amortization schedule length in months (`360` for 30 years).
    public let amortizationMonths: Int
    /// Contractual maturity term in months (`60` for a 5-year balloon).
    public let contractualTermMonths: Int
    /// Whether the loan is currently interest-only.
    public let isInterestOnly: Bool
    
    /// Initializes an amortization input layer.
    public init(
        name: String = "Mortgage",
        principal: Decimal,
        annualInterestRate: Decimal,
        amortizationMonths: Int = 360,
        contractualTermMonths: Int = 360,
        isInterestOnly: Bool = false
    ) {
        self.name = name
        self.principal = principal
        self.annualInterestRate = annualInterestRate
        self.amortizationMonths = max(1, amortizationMonths)
        self.contractualTermMonths = max(1, contractualTermMonths)
        self.isInterestOnly = isInterestOnly
    }
    
    /// Returns true if the contractual maturity is shorter than the amortization schedule.
    public var hasBalloon: Bool {
        contractualTermMonths < amortizationMonths && !isInterestOnly
    }
}

/// A month-by-month entry in an amortization schedule.
public struct AmortizationPeriod: Sendable, Hashable {
    /// Monthly period number (1-indexed).
    public let monthNumber: Int
    /// Principal balance at the beginning of the month.
    public let beginningBalance: Decimal
    /// Interest portion of the monthly payment.
    public let interestPayment: Decimal
    /// Principal reduction portion of the monthly payment.
    public let principalPayment: Decimal
    /// Principal balance at the end of the month.
    public let endingBalance: Decimal
    
    /// Initializes an amortization period record.
    public init(
        monthNumber: Int,
        beginningBalance: Decimal,
        interestPayment: Decimal,
        principalPayment: Decimal,
        endingBalance: Decimal
    ) {
        self.monthNumber = monthNumber
        self.beginningBalance = beginningBalance
        self.interestPayment = interestPayment
        self.principalPayment = principalPayment
        self.endingBalance = endingBalance
    }
}

/// Pure deterministic calculator for mortgage payments, amortization tables, and balloon maturities.
public struct AmortizationEngine: Sendable {
    /// Calculates the monthly payment (`PMT`) for a loan layer using exact `Decimal` arithmetic.
    ///
    /// Amortization formula:
    /// `PMT = P * r * (1 + r)^n / ((1 + r)^n - 1)`
    /// where `r = annualRate / 12`, `n = amortizationMonths`.
    /// - Parameter layer: Amortization input layer.
    /// - Returns: Monthly payment amount (`PMT`).
    public static func calculateMonthlyPayment(layer: AmortizationInputLayer) -> Decimal {
        guard layer.principal > 0 else { return 0 }
        
        let r = layer.annualInterestRate / 12
        
        if layer.isInterestOnly {
            return layer.principal * r
        }
        
        if r == 0 {
            return layer.principal / Decimal(layer.amortizationMonths)
        }
        
        let comp = RoundingEngine.power(base: 1 + r, exponent: layer.amortizationMonths)
        let numerator = layer.principal * r * comp
        let denominator = comp - 1
        
        guard denominator != 0 else { return layer.principal * r }
        return numerator / denominator
    }
    
    /// Calculates total annualized debt service across all active debt layers.
    ///
    /// Per ADR-005 and Blueprint Section 14, **excludes balloon principal** from annual debt service
    /// so that DSCR reflects ongoing operational debt-service capacity.
    /// - Parameter layers: Array of debt layers.
    /// - Returns: Total annualized contractual debt service.
    public static func calculateAnnualDebtService(layers: [AmortizationInputLayer]) -> Decimal {
        layers.reduce(0) { $0 + (calculateMonthlyPayment(layer: $1) * 12) }
    }
    
    /// Generates a month-by-month amortization schedule for a loan layer up to its contractual maturity.
    /// - Parameter layer: Amortization input layer.
    /// - Returns: Ordered array of `AmortizationPeriod` records from Month 1 to maturity.
    public static func generateAmortizationSchedule(layer: AmortizationInputLayer) -> [AmortizationPeriod] {
        guard layer.principal > 0 else { return [] }
        
        let monthlyPayment = calculateMonthlyPayment(layer: layer)
        let r = layer.annualInterestRate / 12
        let termMonths = min(layer.contractualTermMonths, layer.amortizationMonths)
        
        var periods: [AmortizationPeriod] = []
        var currentBalance = layer.principal
        
        for month in 1...termMonths {
            let interest = currentBalance * r
            var principalPay = layer.isInterestOnly ? 0 : (monthlyPayment - interest)
            
            if month == layer.amortizationMonths || currentBalance - principalPay < 0 {
                principalPay = currentBalance
            }
            
            let ending = max(0, currentBalance - principalPay)
            
            periods.append(AmortizationPeriod(
                monthNumber: month,
                beginningBalance: currentBalance,
                interestPayment: interest,
                principalPayment: principalPay,
                endingBalance: ending
            ))
            
            currentBalance = ending
            if currentBalance == 0 { break }
        }
        
        return periods
    }
    
    /// Calculates the total balloon principal balance remaining due at contractual maturity across all layers.
    /// - Parameter layers: Array of debt layers.
    /// - Returns: Total balloon principal burden due at maturity.
    public static func calculateBalloonBurden(layers: [AmortizationInputLayer]) -> Decimal {
        layers.reduce(0) { total, layer in
            guard layer.hasBalloon else { return total }
            let schedule = generateAmortizationSchedule(layer: layer)
            guard let lastPeriod = schedule.last else { return total + layer.principal }
            return total + lastPeriod.endingBalance
        }
    }
}
