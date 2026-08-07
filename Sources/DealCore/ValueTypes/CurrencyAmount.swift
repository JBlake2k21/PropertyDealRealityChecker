//
//  CurrencyAmount.swift
//  PropertyDealRealityChecker
//
//  Stage 2 — Financial Value Types
//  Architectural Mandate: Currency-aware Decimal wrapper. Never Double.
//

import Foundation

/// A currency-aware monetary value backed strictly by Swift `Decimal`.
///
/// Prevents floating-point rounding errors and preserves ISO 4217 currency metadata
/// across domain calculations and immutable snapshots.
public struct CurrencyAmount: Sendable, Codable, Hashable, Comparable {
    /// The ISO 4217 currency code (default: "USD").
    public let currencyCode: String
    
    /// The unrounded monetary amount stored with full Decimal precision.
    public let amount: Decimal
    
    /// Initializes a currency amount with an explicit currency code and Decimal value.
    public init(amount: Decimal, currencyCode: String = "USD") {
        self.amount = amount
        self.currencyCode = currencyCode
    }
    
    /// A zero dollar amount in USD.
    public static let zero = CurrencyAmount(amount: 0, currencyCode: "USD")
    
    /// Returns the presentation amount rounded to 2 decimal places using banker's rounding (`round-half-to-even`).
    public var bankersRoundedAmount: Decimal {
        var rounded = amount
        var localAmount = amount
        NSDecimalRound(&rounded, &localAmount, 2, .bankers)
        return rounded
    }
    
    // MARK: - Comparable & Equatable
    
    public static func < (lhs: CurrencyAmount, rhs: CurrencyAmount) -> Bool {
        guard lhs.currencyCode == rhs.currencyCode else {
            // Compare bare amounts if codes differ (in MVP, USD is universal default)
            return lhs.amount < rhs.amount
        }
        return lhs.amount < rhs.amount
    }
    
    // MARK: - Arithmetic Helpers
    
    public static func + (lhs: CurrencyAmount, rhs: CurrencyAmount) -> CurrencyAmount {
        CurrencyAmount(amount: lhs.amount + rhs.amount, currencyCode: lhs.currencyCode)
    }
    
    public static func - (lhs: CurrencyAmount, rhs: CurrencyAmount) -> CurrencyAmount {
        CurrencyAmount(amount: lhs.amount - rhs.amount, currencyCode: lhs.currencyCode)
    }
    
    public static func * (lhs: CurrencyAmount, multiplier: Decimal) -> CurrencyAmount {
        CurrencyAmount(amount: lhs.amount * multiplier, currencyCode: lhs.currencyCode)
    }
    
    public static func / (lhs: CurrencyAmount, divisor: Decimal) -> CurrencyAmount {
        guard divisor != 0 else { return lhs }
        return CurrencyAmount(amount: lhs.amount / divisor, currencyCode: lhs.currencyCode)
    }
}
