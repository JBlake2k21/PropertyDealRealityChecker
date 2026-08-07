//
//  Scenario.swift
//  PropertyDealRealityChecker
//
//  Stage 2 — Domain Model & Financial Value Types
//  Architectural Mandate: Scenario container holding itemized revenue, expenses, upfront costs, and financing.
//

import Foundation

/// A complete underwriting scenario within a deal aggregate.
///
/// Holds the itemized income, operating expenses, project costs, debt structure,
/// and versioned assumptions for an underwriting evaluation.
public struct Scenario: Sendable, Codable, Hashable, Identifiable {
    /// Unique identifier for this scenario.
    public let id: UUID
    
    /// User-friendly label (e.g., `"Base Case"`, `"Conservative Vacancy"`, `"Seller Financed"`).
    public var name: String
    
    /// Whether this is the default base-case scenario for the deal.
    public var isBase: Bool
    
    /// Itemized scheduled income lines.
    public var incomeLines: [IncomeLine]
    
    /// Itemized operating expenses and reserve lines.
    public var expenseLines: [ExpenseLine]
    
    /// Upfront acquisition costs, rehab budget, and seller concessions.
    public var projectCost: ProjectCost
    
    /// Structured financing plan (debt layers or all-cash).
    public var financingPlan: FinancingPlan
    
    /// Key-value dictionary of versioned scalar assumptions (e.g., `"vacancyRate"`, `"maintenanceRate"`).
    public var assumptions: [String: Assumption]
    
    /// Initializes a scenario entity.
    public init(
        id: UUID = UUID(),
        name: String = "Base Case",
        isBase: Bool = true,
        incomeLines: [IncomeLine] = [],
        expenseLines: [ExpenseLine] = [],
        projectCost: ProjectCost = ProjectCost(purchasePrice: .zero),
        financingPlan: FinancingPlan = .allCash,
        assumptions: [String: Assumption] = [:]
    ) {
        self.id = id
        self.name = name
        self.isBase = isBase
        self.incomeLines = incomeLines
        self.expenseLines = expenseLines
        self.projectCost = projectCost
        self.financingPlan = financingPlan
        self.assumptions = assumptions
    }
}
