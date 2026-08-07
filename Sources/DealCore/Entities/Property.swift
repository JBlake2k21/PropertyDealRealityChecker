//
//  Property.swift
//  PropertyDealRealityChecker
//
//  Stage 2 — Domain Model & Financial Value Types
//  Architectural Mandate: Core residential property entity (1–20 units) owned by Deal aggregate.
//

import Foundation

/// Identifies the residential building classification.
public enum PropertyType: String, Sendable, Codable, Hashable, CaseIterable {
    case singleFamily = "Single Family Residential"
    case multiFamily = "Multi-Family (2–20 Units)"
    case condo = "Condominium"
    case townhouse = "Townhouse"
    case other = "Other Residential"
}

/// Core residential property details owned by a `Deal` aggregate root.
public struct Property: Sendable, Codable, Hashable {
    /// The architectural classification of the property.
    public var propertyType: PropertyType
    
    /// Total number of residential rental units (1–20 for target small investors).
    public var numberOfUnits: Int
    
    /// Total gross rentable square footage, if known.
    public var totalSquareFeet: Int?
    
    /// The year the primary structure was built, if known.
    public var yearBuilt: Int?
    
    /// Current physical occupancy rate fraction (`0.0` to `1.0`).
    public var currentOccupancyRate: Rate
    
    /// Initializes a property entity.
    public init(
        propertyType: PropertyType = .singleFamily,
        numberOfUnits: Int = 1,
        totalSquareFeet: Int? = nil,
        yearBuilt: Int? = nil,
        currentOccupancyRate: Rate = Rate(fraction: 1.0)
    ) {
        self.propertyType = propertyType
        self.numberOfUnits = max(1, numberOfUnits)
        self.totalSquareFeet = totalSquareFeet
        self.yearBuilt = yearBuilt
        self.currentOccupancyRate = currentOccupancyRate
    }
}
