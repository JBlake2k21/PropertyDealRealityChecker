//
//  Deal.swift
//  PropertyDealRealityChecker
//
//  Stage 2 — Domain Model & Financial Value Types
//  Architectural Mandate: Long-lived aggregate root representing an investment property deal.
//

import Foundation

/// Identifies the real estate investment strategy being evaluated.
public enum DealStrategy: String, Sendable, Codable, Hashable, CaseIterable {
    /// Standard long-term buy and hold rental.
    case longTermRental = "Long-Term Rental"
    /// Buy, Rehab, Rent, Refinance, Repeat.
    case brrrr = "BRRRR"
    /// Seller-financed or subject-to acquisition.
    case sellerFinance = "Seller Financed"
    /// Custom or hybrid underwriting strategy.
    case custom = "Custom Strategy"
}

/// Identifies the overall completeness and lifecycle status of a deal.
public enum DealStatus: String, Sendable, Codable, Hashable {
    /// In progress; missing required inputs for calculation.
    case draft
    /// Ready for calculation; minimum required inputs are valid.
    case complete
    /// Calculation attempted but blocked due to missing or invalid data.
    case incomplete
    /// Archived deal no longer actively underwritten.
    case archived
}

/// The primary domain aggregate root representing a real estate investment deal.
///
/// Encapsulates the physical property details, multiple underwriting scenarios,
/// and audit timestamps.
public struct Deal: Sendable, Codable, Hashable, Identifiable {
    /// Unique identifier for this deal.
    public let id: UUID
    
    /// User-defined deal name (e.g., `"123 Maple St - Duplex"`).
    public var name: String
    
    /// Physical street address of the property.
    public var address: String
    
    /// Investment strategy being evaluated.
    public var strategy: DealStrategy
    
    /// Lifecycle status of the deal.
    public var status: DealStatus
    
    /// Owned physical property entity.
    public var property: Property
    
    /// Collection of underwriting scenarios (must contain at least one base scenario).
    public var scenarios: [Scenario]
    
    /// The ID of the currently selected scenario for dashboard inspection.
    public var selectedScenarioID: UUID?
    
    /// Audit timestamp when the deal was first created.
    public let createdAt: Date
    
    /// Audit timestamp of the last modification.
    public var updatedAt: Date
    
    /// Initializes a new deal aggregate root.
    public init(
        id: UUID = UUID(),
        name: String,
        address: String = "",
        strategy: DealStrategy = .longTermRental,
        status: DealStatus = .draft,
        property: Property = Property(),
        scenarios: [Scenario]? = nil,
        selectedScenarioID: UUID? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.strategy = strategy
        self.status = status
        self.property = property
        
        if let provided = scenarios, !provided.isEmpty {
            self.scenarios = provided
            self.selectedScenarioID = selectedScenarioID ?? provided.first?.id
        } else {
            let base = Scenario(name: "Base Case", isBase: true)
            self.scenarios = [base]
            self.selectedScenarioID = base.id
        }
        
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    /// Returns the currently active scenario, defaulting to the base scenario.
    public var activeScenario: Scenario {
        if let selID = selectedScenarioID, let match = scenarios.first(where: { $0.id == selID }) {
            return match
        }
        return scenarios.first(where: { $0.isBase }) ?? scenarios[0]
    }
}
