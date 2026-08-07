//
//  PersistedSnapshot.swift
//  PropertyDealRealityChecker
//
//  Stage 4 — Persistence, Offline-First Repository & Migration Layer
//  Architectural Mandate: SwiftData persistent entity for immutable calculation snapshots (ADR-003).
//

import Foundation
#if canImport(SwiftData)
import SwiftData

/// SwiftData persistent entity representing an immutable calculation audit snapshot.
@Model
public final class PersistedSnapshot {
    @Attribute(.unique) public var id: UUID
    public var dealID: UUID
    public var scenarioID: UUID
    public var engineVersion: String
    public var ruleSetVersion: String
    public var inputHash: String
    public var createdAt: Date
    public var payloadJSON: Data
    
    public init(
        id: UUID = UUID(),
        dealID: UUID,
        scenarioID: UUID,
        engineVersion: String,
        ruleSetVersion: String,
        inputHash: String,
        createdAt: Date = Date(),
        payloadJSON: Data = Data()
    ) {
        self.id = id
        self.dealID = dealID
        self.scenarioID = scenarioID
        self.engineVersion = engineVersion
        self.ruleSetVersion = ruleSetVersion
        self.inputHash = inputHash
        self.createdAt = createdAt
        self.payloadJSON = payloadJSON
    }
}
#else
/// Cross-platform fallback persistence entity for a calculation audit snapshot.
public final class PersistedSnapshot: Codable, @unchecked Sendable, Identifiable {
    public var id: UUID
    public var dealID: UUID
    public var scenarioID: UUID
    public var engineVersion: String
    public var ruleSetVersion: String
    public var inputHash: String
    public var createdAt: Date
    public var payloadJSON: Data
    
    public init(
        id: UUID = UUID(),
        dealID: UUID,
        scenarioID: UUID,
        engineVersion: String,
        ruleSetVersion: String,
        inputHash: String,
        createdAt: Date = Date(),
        payloadJSON: Data = Data()
    ) {
        self.id = id
        self.dealID = dealID
        self.scenarioID = scenarioID
        self.engineVersion = engineVersion
        self.ruleSetVersion = ruleSetVersion
        self.inputHash = inputHash
        self.createdAt = createdAt
        self.payloadJSON = payloadJSON
    }
}
#endif
