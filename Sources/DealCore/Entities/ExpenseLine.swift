//
//  ExpenseLine.swift
//  PropertyDealRealityChecker
//
//  Stage 2 — Domain Model & Financial Value Types
//  Architectural Mandate: Itemized operating expenses and capital reserves with explicit NOI inclusion flag.
//

import Foundation

/// Identifies the cost category of an expense line.
public enum ExpenseCategory: String, Sendable, Codable, Hashable, CaseIterable {
    /// Property tax (mandatory operating expense).
    case propertyTax = "Property Tax"
    /// Property hazard/liability insurance (mandatory operating expense).
    case insurance = "Property Insurance"
    /// Ongoing property maintenance and routine repairs (mandatory operating expense).
    case maintenance = "Maintenance & Repairs"
    /// Property management fees (operating expense).
    case propertyManagement = "Property Management"
    /// Landlord-paid utilities (operating expense).
    case utilities = "Utilities"
    /// Homeowners Association or Condo dues (operating expense).
    case hoa = "HOA / Condo Dues"
    /// Owner capital expenditure replacement reserves (excluded from accounting NOI by default).
    case capitalReserves = "Capital Replacement Reserves"
    /// Miscellaneous operating expenses.
    case otherOperating = "Other Operating Expense"
    
    /// Returns whether this category is included in accounting Net Operating Income (NOI) by default.
    public var isDefaultNOIExpense: Bool {
        switch self {
        case .capitalReserves:
            return false
        default:
            return true
        }
    }
}

/// An itemized expense line within a deal scenario.
public struct ExpenseLine: Sendable, Codable, Hashable, Identifiable {
    /// Unique identifier for this expense line.
    public let id: UUID
    
    /// The cost category.
    public var category: ExpenseCategory
    
    /// The unrounded monetary amount per frequency period.
    public var amount: CurrencyAmount
    
    /// The recurring frequency of the expense line (`monthly` or `annual`).
    public var frequency: Frequency
    
    /// Whether this expense is deducted when calculating accounting Net Operating Income (NOI).
    ///
    /// Per Blueprint Section 14:
    /// Accounting NOI strictly deducts operating expenses (`inclusionInNOI = true`),
    /// whereas Owner Pre-Tax Cash Flow also deducts non-NOI reserves (`inclusionInNOI = false`).
    public var inclusionInNOI: Bool
    
    /// Optional annual escalation rate fraction (`0.03` for 3%/yr).
    public var escalationRate: Rate?
    
    /// Provenance evidence for this expense assumption.
    public var source: SourceRecord
    
    /// Initializes an itemized expense line.
    public init(
        id: UUID = UUID(),
        category: ExpenseCategory,
        amount: CurrencyAmount,
        frequency: Frequency = .annual,
        inclusionInNOI: Bool? = nil,
        escalationRate: Rate? = nil,
        source: SourceRecord = .defaultManual
    ) {
        self.id = id
        self.category = category
        self.amount = amount
        self.frequency = frequency
        self.inclusionInNOI = inclusionInNOI ?? category.isDefaultNOIExpense
        self.escalationRate = escalationRate
        self.source = source
    }
    
    /// Returns the annualized expense amount (`amount * frequency.multiplier`).
    public var annualizedAmount: CurrencyAmount {
        let annualBase = frequency.annualize(amount: amount.amount)
        return CurrencyAmount(amount: annualBase, currencyCode: amount.currencyCode)
    }
}
