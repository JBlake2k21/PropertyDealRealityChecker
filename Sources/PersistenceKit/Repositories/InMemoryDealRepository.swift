//
//  InMemoryDealRepository.swift
//  PropertyDealRealityChecker
//
//  Stage 4 — Persistence, Offline-First Repository & Migration Layer
//  Architectural Mandate: Actor-backed thread-safe repository implementation for previews and testing.
//

import Foundation
import DealCore

/// An actor-backed, thread-safe in-memory repository implementing `DealRepository`.
///
/// Uses `DealMapper` on every read and write to verify that serialization and mapping invariants
/// remain 100% sound without requiring physical disk storage.
public actor InMemoryDealRepository: DealRepository {
    private var persistedDeals: [UUID: PersistedDeal] = [:]
    private var persistedSnapshots: [UUID: [PersistedSnapshot]] = [:]
    
    /// Initializes an empty in-memory repository.
    public init() {}
    
    public func fetchAllDeals() async throws -> [Deal] {
        let sorted = persistedDeals.values.sorted { $0.updatedAt > $1.updatedAt }
        return try sorted.map { try DealMapper.toDomain(from: $0) }
    }
    
    public func fetchDeal(id: UUID) async throws -> Deal? {
        guard let persisted = persistedDeals[id] else {
            return nil
        }
        return try DealMapper.toDomain(from: persisted)
    }
    
    public func saveDeal(_ deal: Deal) async throws {
        let persisted = try DealMapper.toPersistence(from: deal)
        persistedDeals[deal.id] = persisted
    }
    
    public func deleteDeal(id: UUID) async throws {
        persistedDeals.removeValue(forKey: id)
        persistedSnapshots.removeValue(forKey: id)
    }
    
    public func fetchSnapshots(forDealID dealID: UUID) async throws -> [CalculationSnapshot] {
        guard let items = persistedSnapshots[dealID] else {
            return []
        }
        let sorted = items.sorted { $0.createdAt > $1.createdAt }
        return try sorted.map { try DealMapper.toDomain(from: $0) }
    }
    
    public func saveSnapshot(_ snapshot: CalculationSnapshot) async throws {
        let persisted = try DealMapper.toPersistence(from: snapshot)
        var current = persistedSnapshots[snapshot.dealID] ?? []
        current.append(persisted)
        persistedSnapshots[snapshot.dealID] = current
    }
}
