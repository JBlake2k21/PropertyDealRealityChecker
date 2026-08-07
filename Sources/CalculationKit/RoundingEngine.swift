//
//  RoundingEngine.swift
//  PropertyDealRealityChecker
//
//  Stage 3 — Deterministic Calculation Engine
//  Architectural Mandate: Pure Decimal arithmetic and Banker's rounding (round-half-to-even). Never Double.
//

import Foundation

/// Provides deterministic precision rounding and high-precision `Decimal` exponentiation.
///
/// Mandated by Blueprint Section 6.1:
/// "Rounding policy is explicit: retain precision internally, round currency at presentation,
/// and define payment-schedule rounding in formula metadata."
public struct RoundingEngine: Sendable {
    /// Rounds a monetary Decimal amount to the specified decimal places using Banker's rounding (`round-half-to-even`).
    /// - Parameters:
    ///   - amount: The unrounded Decimal value.
    ///   - places: The number of fractional digits to retain (default: `2`).
    /// - Returns: The banker-rounded Decimal value.
    public static func roundToBankers(amount: Decimal, places: Int = 2) -> Decimal {
        var rounded = amount
        var localAmount = amount
        NSDecimalRound(&rounded, &localAmount, places, .bankers)
        return rounded
    }
    
    /// Rounds a fractional rate to the specified decimal places using Banker's rounding.
    /// - Parameters:
    ///   - rate: The unrounded rate fraction (e.g., `0.072543`).
    ///   - places: The number of fractional digits to retain (default: `4` for 0.01% precision).
    /// - Returns: The rounded rate fraction.
    public static func roundRate(rate: Decimal, places: Int = 4) -> Decimal {
        var rounded = rate
        var localRate = rate
        NSDecimalRound(&rounded, &localRate, places, .bankers)
        return rounded
    }
    
    /// Computes `base^exponent` for integer exponents using exact `Decimal` exponentiation-by-squaring.
    ///
    /// Eliminates the need for `pow(Double, Double)` in mortgage payment calculations,
    /// ensuring 100% deterministic mathematical precision without floating-point conversion.
    /// - Parameters:
    ///   - base: The Decimal base value.
    ///   - exponent: The integer exponent (e.g., `360` for 30-year amortization).
    /// - Returns: The exact Decimal power result.
    public static func power(base: Decimal, exponent: Int) -> Decimal {
        guard exponent != 0 else { return 1 }
        guard base != 0 else { return 0 }
        
        var absExp = abs(exponent)
        var result: Decimal = 1
        var currentBase = base
        
        while absExp > 0 {
            if absExp % 2 == 1 {
                result = result * currentBase
            }
            currentBase = currentBase * currentBase
            absExp /= 2
        }
        
        if exponent < 0 {
            return 1 / result
        }
        return result
    }
}
