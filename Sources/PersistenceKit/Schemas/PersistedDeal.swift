//
//  PersistedDeal.swift
//  PropertyDealRealityChecker
//
//  Stage 4 — Persistence, Offline-First Repository & Migration Layer
//  Architectural Mandate: SwiftData persistence entity with cross-platform fallback (Rule 10).
//  Never expose persisted models directly to UI or CalculationKit.
//

import Foundation
#if canImport(SwiftData)
import SwiftData

/// SwiftData persistent entity representing a saved investment property deal.
///
/// Stores complex domain entities (`Property`, `[Scenario]`) as versioned JSON blobs
/// to ensure schema stability and eliminate CoreData/SwiftData impedance mismatch.
@Model
public final class PersistedDeal {
    @Attribute(.unique) public var id: UUID
    public var name: String
    public var address: String
    public var strategyRawValue: String
    public var statusRawValue: String
    public var propertyJSON: Data
    public var scenariosJSON: Data
    public var selectedScenarioID: UUID?
    public var createdAt: Date
    public var updatedAt: Date
    public var schemaVersion: String
    
    public init(
        id: UUID = UUID(),
        name: String,
        address: String = "",
        strategyRawValue: String = "Long-Term Rental",
        statusRawValue: String = "draft",
        propertyJSON: Data = Data(),
        scenariosJSON: Data = Data(),
        selectedScenarioID: UUID? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        schemaVersion: String = SchemaVersion.current.rawValue
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.strategyRawValue = strategyRawValue
        self.statusRawValue = statusRawValue
        self.propertyJSON = propertyJSON
        self.scenariosJSON = scenariosJSON
        self.selectedScenarioID = selectedScenarioID
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.schemaVersion = schemaVersion
    }
}
#else
/// Cross-platform fallback persistence entity representing a saved investment property deal.
///
/// Used for platform-independent compilation and validation on Windows/Linux host environments (Rule 10).
public final class PersistedDeal: Codable, @unchecked Sendable, Identifiable {
    public var id: UUID
    public var name: String
    public var address: String
    public var strategyRawValue: String
    public var statusRawValue: String
    public var propertyJSON: Data
    public var scenariosJSON: Data
    public var selectedScenarioID: UUID?
    public var createdAt: Date
    public var updatedAt: Date
    public var schemaVersion: String
    
    public init(
        id: UUID = UUID(),
        name: String,
        address: String = "",
        strategyRawValue: String = "Long-Term Rental",
        statusRawValue: String = "draft",
        propertyJSON: Data = Data(),
        scenariosJSON: Data = Data(),
        selectedScenarioID: UUID? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        schemaVersion: String = SchemaVersion.current.rawValue
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.strategyRawValue = strategyRawValue
        self.statusRawValue = statusRawValue
        self.propertyJSON = propertyJSON
        self.scenariosJSON = scenariosJSON
        self.selectedScenarioID = selectedScenarioID
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.schemaVersion = schemaVersion
    }
}
#endif
