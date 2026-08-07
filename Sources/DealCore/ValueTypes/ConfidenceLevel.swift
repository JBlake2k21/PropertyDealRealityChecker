//
//  ConfidenceLevel.swift
//  PropertyDealRealityChecker
//
//  Stage 2 — Financial Value Types
//  Architectural Mandate: Separate confidence (evidence quality) from verdict (profitability).
//

import Foundation

/// Represents the reliability and evidence quality of a deal assumption or overall evaluation.
///
/// As mandated by Blueprint Section 4.4:
/// "Confidence is computed separately from attractiveness. It falls when the user relies on unknown values,
/// broad estimates, unsupported rents, stale data, or internally inconsistent assumptions."
public enum ConfidenceLevel: String, Sendable, Codable, Hashable, Comparable {
    /// Supported by verified documents, historical leases, or tax bills.
    case high
    /// Supported by active listings or recent verifiable market comps.
    case medium
    /// Derived from broad market estimates, unverified user input, or consent-based placeholders.
    case low
    /// Missing required verification or containing conflicting assumptions.
    case unverified
    
    /// Numeric rank for comparison (`high` > `medium` > `low` > `unverified`).
    private var rank: Int {
        switch self {
        case .high: return 3
        case .medium: return 2
        case .low: return 1
        case .unverified: return 0
        }
    }
    
    public static func < (lhs: ConfidenceLevel, rhs: ConfidenceLevel) -> Bool {
        lhs.rank < rhs.rank
    }
}
