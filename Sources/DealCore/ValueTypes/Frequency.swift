//
//  Frequency.swift
//  PropertyDealRealityChecker
//
//  Stage 2 — Financial Value Types
//  Architectural Mandate: Explicit annual/monthly conversion rules.
//

import Foundation

/// Represents the recurring frequency of an income line, operating expense, or debt payment.
public enum Frequency: String, Sendable, Codable, Hashable, CaseIterable {
    case monthly
    case annual
    case oneTime
    
    /// The multiplier required to convert this frequency into an annual value.
    public var annualMultiplier: Decimal {
        switch self {
        case .monthly:
            return 12
        case .annual:
            return 1
        case .oneTime:
            return 0
        }
    }
    
    /// Converts a given amount to its annualized equivalent based on this frequency.
    public func annualize(amount: Decimal) -> Decimal {
        amount * annualMultiplier
    }
    
    /// Converts an annualized amount to this frequency's period equivalent.
    public func deannualize(annualAmount: Decimal) -> Decimal {
        switch self {
        case .monthly:
            return annualAmount / 12
        case .annual:
            return annualAmount
        case .oneTime:
            return annualAmount
        }
    }
}
