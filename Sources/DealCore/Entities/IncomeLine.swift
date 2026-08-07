//
//  IncomeLine.swift
//  PropertyDealRealityChecker
//
//  Stage 2 — Domain Model & Financial Value Types
//  Architectural Mandate: Separate tracking of contractual vs. market rents; itemized scheduled income.
//

import Foundation

/// Identifies the revenue category of an income line.
public enum IncomeCategory: String, Sendable, Codable, Hashable, CaseIterable {
    /// Currently contracted lease rent.
    case contractualRent = "Contractual Lease Rent"
    /// Estimated market rent for vacant units or post-rehab stabilization.
    case marketRent = "Market Rent Estimate"
    /// Scheduled laundry revenue.
    case laundry = "Laundry Revenue"
    /// Scheduled parking or garage revenue.
    case parking = "Parking / Garage Revenue"
    /// Scheduled storage fee revenue.
    case storage = "Storage Revenue"
    /// Miscellaneous scheduled revenue.
    case other = "Other Scheduled Revenue"
}

/// An itemized revenue line within a deal scenario.
public struct IncomeLine: Sendable, Codable, Hashable, Identifiable {
    /// Unique identifier for this income line.
    public let id: UUID
    
    /// The revenue category (separates contractual vs. market rents).
    public var category: IncomeCategory
    
    /// The unrounded contractual or estimated amount per frequency period.
    public var amount: CurrencyAmount
    
    /// The recurring frequency of the income line (`monthly` or `annual`).
    public var frequency: Frequency
    
    /// Optional label identifying the unit number or tenant name.
    public var unitOrTenantLabel: String?
    
    /// Collectibility factor (`0.0` to `1.0`, default: `1.0`).
    public var collectionFactor: Rate
    
    /// Provenance evidence for this income stream.
    public var source: SourceRecord
    
    /// Initializes an itemized income line.
    public init(
        id: UUID = UUID(),
        category: IncomeCategory,
        amount: CurrencyAmount,
        frequency: Frequency = .monthly,
        unitOrTenantLabel: String? = nil,
        collectionFactor: Rate = Rate(fraction: 1.0),
        source: SourceRecord = .defaultManual
    ) {
        self.id = id
        self.category = category
        self.amount = amount
        self.frequency = frequency
        self.unitOrTenantLabel = unitOrTenantLabel
        self.collectionFactor = collectionFactor
        self.source = source
    }
    
    /// Returns the annualized income amount (`amount * frequency.multiplier * collectionFactor`).
    public var annualizedAmount: CurrencyAmount {
        let annualBase = frequency.annualize(amount: amount.amount)
        let collected = annualBase * collectionFactor.fraction
        return CurrencyAmount(amount: collected, currencyCode: amount.currencyCode)
    }
}
