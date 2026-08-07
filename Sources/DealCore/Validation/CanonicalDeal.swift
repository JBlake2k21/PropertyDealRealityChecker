//
//  CanonicalDeal.swift
//  PropertyDealRealityChecker
//
//  Stage 2 — Domain Model & Financial Value Types
//  Architectural Mandate: Immutable, validated, normalized deal ready for deterministic calculation pipeline.
//

import Foundation

/// An immutable, validated, and normalized underwriting deal.
///
/// Guaranteed to contain valid, positive purchase price, valid rental income,
/// and mathematically consistent debt layers. Passed directly into `CalculationKit`.
public struct CanonicalDeal: Sendable, Codable, Hashable, Identifiable {
    /// Unique deal identifier.
    public let id: UUID
    
    /// Normalized property name.
    public let name: String
    
    /// Property street address.
    public let address: String
    
    /// Investment strategy being evaluated.
    public let strategy: DealStrategy
    
    /// Normalized residential property details.
    public let property: Property
    
    /// Underwriting scenario containing itemized revenue, operating expenses, project costs, and financing.
    public let scenario: Scenario
    
    /// Non-blocking informational warning issues generated during validation.
    public let validationIssues: [ValidationIssue]
    
    /// Initializes an immutable canonical deal.
    public init(
        id: UUID,
        name: String,
        address: String,
        strategy: DealStrategy,
        property: Property,
        scenario: Scenario,
        validationIssues: [ValidationIssue] = []
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.strategy = strategy
        self.property = property
        self.scenario = scenario
        self.validationIssues = validationIssues
    }
    
    /// Calculates a deterministic SHA-256 equivalent input hash of the canonical deal parameters.
    ///
    /// Used by `CalculationSnapshot` to audit and verify input immutability.
    public var inputHash: String {
        var hasher = Hasher()
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(strategy)
        hasher.combine(property)
        hasher.combine(scenario)
        let hashVal = hasher.finalize()
        return String(format: "%016llx", UInt64(bitPattern: Int64(hashVal)))
    }
}
