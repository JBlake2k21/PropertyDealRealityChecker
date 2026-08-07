//
//  PersistedScenario.swift
//  PropertyDealRealityChecker
//
//  Stage 4 — Persistence, Offline-First Repository & Migration Layer
//  Architectural Mandate: SwiftData persistent entity for underwriting scenarios.
//

import Foundation
#if canImport(SwiftData)
import SwiftData

/// SwiftData persistent entity representing a saved underwriting scenario.
@Model
public final class PersistedScenario {
    @Attribute(.unique) public var id: UUID
    public var dealID: UUID
    public var name: String
    public var isBase: Bool
    public var payloadJSON: Data
    public var createdAt: Date
    public var updatedAt: Date
    
    public init(
        id: UUID = UUID(),
        dealID: UUID,
        name: String = "Base Case",
        isBase: Bool = true,
        payloadJSON: Data = Data(),
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.dealID = dealID
        self.name = name
        self.isBase = isBase
        self.payloadJSON = payloadJSON
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
#else
/// Cross-platform fallback persistence entity for an underwriting scenario.
public final class PersistedScenario: Codable, @unchecked Sendable, Identifiable {
    public var id: UUID
    public var dealID: UUID
    public var name: String
    public var isBase: Bool
    public var payloadJSON: Data
    public var createdAt: Date
    public var updatedAt: Date
    
    public init(
        id: UUID = UUID(),
        dealID: UUID,
        name: String = "Base Case",
        isBase: Bool = true,
        payloadJSON: Data = Data(),
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.dealID = dealID
        self.name = name
        self.isBase = isBase
        self.payloadJSON = payloadJSON
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
#endif
