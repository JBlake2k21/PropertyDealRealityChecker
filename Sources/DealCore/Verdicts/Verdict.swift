//
//  Verdict.swift
//  PropertyDealRealityChecker
//
//  Stage 2 — Domain Model & Financial Value Types
//  Architectural Mandate: Deterministic verdict classification accompanied by structured reason codes and separate confidence rank.
//

import Foundation

/// Identifies the overall profitability and risk classification of an investment property deal.
public enum VerdictCategory: String, Sendable, Codable, Hashable, CaseIterable {
    /// Exceeds investor's return and safety thresholds across base and conservative scenarios.
    case strong = "Strong Deal"
    /// Meets primary return targets in base scenario; workable with monitoring.
    case workable = "Workable Deal"
    /// Fails one or more primary targets or exhibits vulnerability to modest stress.
    case marginal = "Marginal Deal"
    /// Severely underperforms, fails DSCR safety checks, or requires speculative appreciation to break even.
    case highRisk = "High Risk / Speculative"
    /// Calculation incomplete or blocked due to missing required verification.
    case incomplete = "Incomplete / Unverified"
}

/// The overall evaluation verdict for a property deal scenario.
///
/// Combines the profitability category (`strong`, `workable`, `marginal`, `highRisk`, `incomplete`),
/// the evidence reliability (`confidence`), and an ordered list of structured reason codes.
public struct Verdict: Sendable, Codable, Hashable {
    /// The profitability and risk classification.
    public let category: VerdictCategory
    
    /// The evidence reliability rank (computed separately from profitability).
    public let confidence: ConfidenceLevel
    
    /// Ordered list of structured reason codes explaining why metrics passed or failed.
    public let reasonCodes: [ReasonCode]
    
    /// Initializes a deal verdict.
    public init(
        category: VerdictCategory,
        confidence: ConfidenceLevel,
        reasonCodes: [ReasonCode] = []
    ) {
        self.category = category
        self.confidence = confidence
        self.reasonCodes = reasonCodes
    }
    
    /// Returns all failing reason codes (where `isSuccess == false`).
    public var failingReasons: [ReasonCode] {
        reasonCodes.filter { !$0.isSuccess }
    }
    
    /// Returns all passing reason codes (where `isSuccess == true`).
    public var passingReasons: [ReasonCode] {
        reasonCodes.filter { $0.isSuccess }
    }
}
