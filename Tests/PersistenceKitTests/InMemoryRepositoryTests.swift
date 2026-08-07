//
//  InMemoryRepositoryTests.swift
//  PropertyDealRealityCheckerTests
//
//  Stage 4 — InMemoryDealRepository Unit Tests
//

import Foundation
import DealCore
import PersistenceKit

#if canImport(Testing)
import Testing

@Test("Verify InMemoryDealRepository save, fetch, update, and delete lifecycle")
func testInMemoryRepositoryLifecycle() async throws {
    let repo = InMemoryDealRepository()
    
    // 1. Initial fetch should be empty
    let initialList = try await repo.fetchAllDeals()
    #expect(initialList.isEmpty)
    
    // 2. Save a deal
    var deal1 = Deal(name: "Deal One", strategy: .longTermRental)
    try await repo.saveDeal(deal1)
    
    let fetched1 = try await repo.fetchDeal(id: deal1.id)
    #expect(fetched1?.name == "Deal One")
    
    // 3. Update the deal
    deal1.name = "Deal One Updated"
    try await repo.saveDeal(deal1)
    
    let updatedFetch = try await repo.fetchDeal(id: deal1.id)
    #expect(updatedFetch?.name == "Deal One Updated")
    
    // 4. Save a second deal
    let deal2 = Deal(name: "Deal Two", strategy: .brrrr)
    try await repo.saveDeal(deal2)
    
    let allDeals = try await repo.fetchAllDeals()
    #expect(allDeals.count == 2)
    
    // 5. Delete deal1
    try await repo.deleteDeal(id: deal1.id)
    let afterDelete = try await repo.fetchAllDeals()
    #expect(afterDelete.count == 1)
    #expect(afterDelete[0].name == "Deal Two")
}

@Test("Verify InMemoryDealRepository calculation snapshot storage and ordering")
func testSnapshotRepositoryStorage() async throws {
    let repo = InMemoryDealRepository()
    let dealID = UUID()
    let scenarioID = UUID()
    
    let snap1 = CalculationSnapshot(
        dealID: dealID,
        scenarioID: scenarioID,
        inputHash: "hash_001",
        normalizedInputs: CanonicalDeal(id: dealID, name: "Test", address: "", strategy: .longTermRental, property: Property(), scenario: Scenario()),
        metrics: CalculationMetrics(),
        verdict: Verdict(category: .workable, confidence: .high)
    )
    
    try await repo.saveSnapshot(snap1)
    
    let snap2 = CalculationSnapshot(
        dealID: dealID,
        scenarioID: scenarioID,
        inputHash: "hash_002",
        normalizedInputs: CanonicalDeal(id: dealID, name: "Test 2", address: "", strategy: .longTermRental, property: Property(), scenario: Scenario()),
        metrics: CalculationMetrics(),
        verdict: Verdict(category: .strong, confidence: .high)
    )
    
    try await repo.saveSnapshot(snap2)
    
    let snapshots = try await repo.fetchSnapshots(forDealID: dealID)
    #expect(snapshots.count == 2)
    #expect(snapshots[0].inputHash == "hash_002") // Most recent first
}
#endif
