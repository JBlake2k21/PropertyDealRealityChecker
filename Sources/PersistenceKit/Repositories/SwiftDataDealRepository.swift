//
//  SwiftDataDealRepository.swift
//  PropertyDealRealityChecker
//
//  Stage 4 — Persistence, Offline-First Repository & Migration Layer
//  Architectural Mandate: Offline-first local SwiftData repository with cross-platform fallback.
//

import Foundation
import DealCore
#if canImport(SwiftData)
import SwiftData

/// An offline-first persistent repository backed by Apple SwiftData (`ModelContext`).
///
/// Implements Blueprint Section 8:
/// Operates locally without requiring network connectivity. Uses `DealMapper` to convert
/// SwiftData `@Model` classes to immutable `DealCore` domain aggregates.
@ModelActor
public actor SwiftDataDealRepository: DealRepository {
    
    public func fetchAllDeals() async throws -> [Deal] {
        let descriptor = FetchDescriptor<PersistedDeal>(sortBy: [SortDescriptor(\.updatedAt, order: .reverse)])
        let persistedList = try modelContext.fetch(descriptor)
        return try persistedList.map { try DealMapper.toDomain(from: $0) }
    }
    
    public func fetchDeal(id: UUID) async throws -> Deal? {
        let predicate = #Predicate<PersistedDeal> { $0.id == id }
        var descriptor = FetchDescriptor<PersistedDeal>(predicate: predicate)
        descriptor.fetchLimit = 1
        guard let persisted = try modelContext.fetch(descriptor).first else {
            return nil
        }
        return try DealMapper.toDomain(from: persisted)
    }
    
    public func saveDeal(_ deal: Deal) async throws {
        let predicate = #Predicate<PersistedDeal> { $0.id == deal.id }
        var descriptor = FetchDescriptor<PersistedDeal>(predicate: predicate)
        descriptor.fetchLimit = 1
        
        if let existing = try modelContext.fetch(descriptor).first {
            let updated = try DealMapper.toPersistence(from: deal)
            existing.name = updated.name
            existing.address = updated.address
            existing.strategyRawValue = updated.strategyRawValue
            existing.statusRawValue = updated.statusRawValue
            existing.propertyJSON = updated.propertyJSON
            existing.scenariosJSON = updated.scenariosJSON
            existing.selectedScenarioID = updated.selectedScenarioID
            existing.updatedAt = updated.updatedAt
            existing.schemaVersion = updated.schemaVersion
        } else {
            let newPersisted = try DealMapper.toPersistence(from: deal)
            modelContext.insert(newPersisted)
        }
        try modelContext.save()
    }
    
    public func deleteDeal(id: UUID) async throws {
        let dealPredicate = #Predicate<PersistedDeal> { $0.id == id }
        try modelContext.delete(model: PersistedDeal.self, where: dealPredicate)
        
        let snapPredicate = #Predicate<PersistedSnapshot> { $0.dealID == id }
        try modelContext.delete(model: PersistedSnapshot.self, where: snapPredicate)
        
        try modelContext.save()
    }
    
    public func fetchSnapshots(forDealID dealID: UUID) async throws -> [CalculationSnapshot] {
        let predicate = #Predicate<PersistedSnapshot> { $0.dealID == dealID }
        let descriptor = FetchDescriptor<PersistedSnapshot>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        let persistedList = try modelContext.fetch(descriptor)
        return try persistedList.map { try DealMapper.toDomain(from: $0) }
    }
    
    public func saveSnapshot(_ snapshot: CalculationSnapshot) async throws {
        let persisted = try DealMapper.toPersistence(from: snapshot)
        modelContext.insert(persisted)
        try modelContext.save()
    }
}
#else
/// Cross-platform fallback repository wrapping `InMemoryDealRepository` when SwiftData is unavailable.
public actor SwiftDataDealRepository: DealRepository {
    private let fallback = InMemoryDealRepository()
    
    public init() {}
    
    public func fetchAllDeals() async throws -> [Deal] {
        try await fallback.fetchAllDeals()
    }
    
    public func fetchDeal(id: UUID) async throws -> Deal? {
        try await fallback.fetchDeal(id: id)
    }
    
    public func saveDeal(_ deal: Deal) async throws {
        try await fallback.saveDeal(deal)
    }
    
    public func deleteDeal(id: UUID) async throws {
        try await fallback.deleteDeal(id: id)
    }
    
    public func fetchSnapshots(forDealID dealID: UUID) async throws -> [CalculationSnapshot] {
        try await fallback.fetchSnapshots(forDealID: dealID)
    }
    
    public func saveSnapshot(_ snapshot: CalculationSnapshot) async throws {
        try await fallback.saveSnapshot(snapshot)
    }
}
#endif
