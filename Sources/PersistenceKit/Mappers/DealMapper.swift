//
//  DealMapper.swift
//  PropertyDealRealityChecker
//
//  Stage 4 — Persistence, Offline-First Repository & Migration Layer
//  Architectural Mandate: Explicit bidirectional DTO mapper isolating Domain entities from Persistence schemas.
//  Never expose `@Model` classes to UI or Feature packages.
//

import Foundation
import DealCore

/// Error thrown when decoding persisted JSON blobs fails during mapping.
public enum PersistenceMappingError: Error, Sendable {
    case corruptedPropertyJSON(dealID: UUID, underlying: Error)
    case corruptedScenariosJSON(dealID: UUID, underlying: Error)
    case corruptedSnapshotJSON(snapshotID: UUID, underlying: Error)
}

/// Bidirectional data mapper converting between pure domain entities (`DealCore`) and persistent schemas (`PersistenceKit`).
public struct DealMapper: Sendable {
    private static let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        return e
    }()
    
    private static let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()
    
    /// Converts a domain `Deal` entity into a `PersistedDeal` database schema object.
    /// - Parameter deal: Domain deal aggregate.
    /// - Returns: Persisted database model.
    public static func toPersistence(from deal: Deal) throws -> PersistedDeal {
        let propData = try encoder.encode(deal.property)
        let scenData = try encoder.encode(deal.scenarios)
        
        return PersistedDeal(
            id: deal.id,
            name: deal.name,
            address: deal.address,
            strategyRawValue: deal.strategy.rawValue,
            statusRawValue: deal.status.rawValue,
            propertyJSON: propData,
            scenariosJSON: scenData,
            selectedScenarioID: deal.selectedScenarioID,
            createdAt: deal.createdAt,
            updatedAt: deal.updatedAt,
            schemaVersion: SchemaVersion.current.rawValue
        )
    }
    
    /// Converts a `PersistedDeal` database model into an immutable domain `Deal` entity.
    /// - Parameter persisted: Persistent database object.
    /// - Returns: Reconstructed domain deal aggregate.
    public static func toDomain(from persisted: PersistedDeal) throws -> Deal {
        let prop: Property
        do {
            prop = try decoder.decode(Property.self, from: persisted.propertyJSON)
        } catch {
            throw PersistenceMappingError.corruptedPropertyJSON(dealID: persisted.id, underlying: error)
        }
        
        let scens: [Scenario]
        do {
            scens = try decoder.decode([Scenario].self, from: persisted.scenariosJSON)
        } catch {
            throw PersistenceMappingError.corruptedScenariosJSON(dealID: persisted.id, underlying: error)
        }
        
        let strategy = DealStrategy(rawValue: persisted.strategyRawValue) ?? .longTermRental
        let status = DealStatus(rawValue: persisted.statusRawValue) ?? .draft
        
        return Deal(
            id: persisted.id,
            name: persisted.name,
            address: persisted.address,
            strategy: strategy,
            status: status,
            property: prop,
            scenarios: scens,
            selectedScenarioID: persisted.selectedScenarioID,
            createdAt: persisted.createdAt,
            updatedAt: persisted.updatedAt
        )
    }
    
    /// Converts an immutable domain `CalculationSnapshot` into a `PersistedSnapshot` schema object.
    /// - Parameter snapshot: Domain calculation audit record.
    /// - Returns: Persisted audit database model.
    public static func toPersistence(from snapshot: CalculationSnapshot) throws -> PersistedSnapshot {
        let payload = try encoder.encode(snapshot)
        return PersistedSnapshot(
            id: snapshot.id,
            dealID: snapshot.dealID,
            scenarioID: snapshot.scenarioID,
            engineVersion: snapshot.engineVersion,
            ruleSetVersion: snapshot.ruleSetVersion,
            inputHash: snapshot.inputHash,
            createdAt: snapshot.createdAt,
            payloadJSON: payload
        )
    }
    
    /// Converts a `PersistedSnapshot` database model into a domain `CalculationSnapshot` entity.
    /// - Parameter persisted: Persistent audit database object.
    /// - Returns: Domain calculation audit snapshot.
    public static func toDomain(from persisted: PersistedSnapshot) throws -> CalculationSnapshot {
        do {
            return try decoder.decode(CalculationSnapshot.self, from: persisted.payloadJSON)
        } catch {
            throw PersistenceMappingError.corruptedSnapshotJSON(snapshotID: persisted.id, underlying: error)
        }
    }
}
