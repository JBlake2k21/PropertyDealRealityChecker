//
//  Rate.swift
//  PropertyDealRealityChecker
//
//  Stage 2 — Financial Value Types
//  Architectural Mandate: Canonical rate fraction wrapper backed by Decimal.
//  7% is stored as 0.07; converted only at input/output boundaries.
//

import Foundation

/// A percentage rate stored canonically as a decimal fraction (`0.07` for 7%).
///
/// Prevents unit confusion between integer percentages and decimal fractions
/// across domain rules, debt schedules, and sensitivity matrices.
public struct Rate: Sendable, Codable, Hashable, Comparable {
    /// The canonical fraction value (e.g., `0.07` for 7.00%).
    public let fraction: Decimal
    
    /// Initializes a canonical rate from a decimal fraction (`0.07`).
    public init(fraction: Decimal) {
        self.fraction = fraction
    }
    
    /// Initializes a canonical rate from a percentage (`7.0` -> `0.07`).
    public init(percentage: Decimal) {
        self.fraction = percentage / 100
    }
    
    /// A zero rate (`0.00`).
    public static let zero = Rate(fraction: 0)
    
    /// Returns the rate as a percentage (`0.07` -> `7.0`).
    public var percentage: Decimal {
        fraction * 100
    }
    
    /// Returns the monthly fractional rate (`APR / 12`).
    public var monthlyFraction: Decimal {
        fraction / 12
    }
    
    /// Returns the rate formatted for presentation rounded to 4 decimal places (`0.0725` -> `7.25%`).
    public var bankersRoundedPercentage: Decimal {
        var rounded = percentage
        var localAmount = percentage
        NSDecimalRound(&rounded, &localAmount, 2, .bankers)
        return rounded
    }
    
    // MARK: - Comparable
    
    public static func < (lhs: Rate, rhs: Rate) -> Bool {
        lhs.fraction < rhs.fraction
    }
}
