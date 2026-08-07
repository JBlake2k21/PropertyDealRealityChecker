//
//  Assumption.swift
//  PropertyDealRealityChecker
//
//  Stage 2 — Domain Model & Financial Value Types
//  Architectural Mandate: Versioned assumption parameter within a Scenario.
//

import Foundation

/// A versioned financial assumption or parameter within a `Scenario`.
public struct Assumption: Sendable, Codable, Hashable {
    /// Unique assumption key (e.g., `"vacancyRate"`, `"maintenanceRate"`).
    public let key: String
    
    /// The unrounded Decimal value of the assumption.
    public var value: Decimal
    
    /// The unit of measurement (e.g., `"fraction"`, `"USD"`, `"months"`).
    public let unit: String
    
    /// Evidence metadata describing the source and confidence of this assumption.
    public var source: SourceRecord
    
    /// Optional user or system note explaining why this assumption was selected.
    public var note: String?
    
    /// Initializes a versioned assumption.
    public init(
        key: String,
        value: Decimal,
        unit: String,
        source: SourceRecord = .defaultManual,
        note: String? = nil
    ) {
        self.key = key
        self.value = value
        self.unit = unit
        self.source = source
        self.note = note
    }
}
