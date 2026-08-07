//
//  DealMapperTests.swift
//  PropertyDealRealityCheckerTests
//
//  Stage 4 — DealMapper Bidirectional DTO Unit Tests
//

import Foundation
import DealCore
import PersistenceKit

#if canImport(Testing)
import Testing

@Test("Verify bidirectional DealMapper toPersistence and toDomain without precision loss")
func testDealMapperRoundTrip() throws {
    var deal = Deal(name: "Round-Trip Duplex", address: "456 Oak Lane", strategy: .brrrr)
    deal.property = Property(propertyType: .multiFamily, numberOfUnits: 2, squareFeet: 2400)
    
    // Add income & expense line
    deal.scenarios[0].incomeLines = [
        IncomeLine(category: .contractualRent, amount: CurrencyAmount(amount: 2200), frequency: .monthly)
    ]
    deal.scenarios[0].expenseLines = [
        ExpenseLine(category: .propertyTax, amount: CurrencyAmount(amount: 4000), frequency: .annual)
    ]
    deal.scenarios[0].financingPlan = FinancingPlan(debtLayers: [
        DebtLayer(name: "BRRRR First Lien", principal: CurrencyAmount(amount: 180_000), interestRate: Rate(fraction: 0.065))
    ])
    
    // Convert Domain -> Persistence
    let persisted = try DealMapper.toPersistence(from: deal)
    #expect(persisted.id == deal.id)
    #expect(persisted.name == "Round-Trip Duplex")
    #expect(persisted.strategyRawValue == "BRRRR")
    #expect(!persisted.propertyJSON.isEmpty)
    #expect(!persisted.scenariosJSON.isEmpty)
    
    // Convert Persistence -> Domain
    let roundTrip = try DealMapper.toDomain(from: persisted)
    #expect(roundTrip.id == deal.id)
    #expect(roundTrip.name == deal.name)
    #expect(roundTrip.strategy == .brrrr)
    #expect(roundTrip.property.numberOfUnits == 2)
    #expect(roundTrip.scenarios[0].incomeLines[0].amount.amount == 2200)
    #expect(roundTrip.scenarios[0].financingPlan.firstMortgage?.interestRate.fraction == Decimal(string: "0.065")!)
}

@Test("Verify bidirectional CalculationSnapshot persistence mapping")
func testSnapshotMapperRoundTrip() throws {
    let deal = Deal(name: "Snapshot Test")
    let snapshot = CalculationSnapshot(
        dealID: deal.id,
        scenarioID: deal.scenarios[0].id,
        inputHash: "c0ffeebabe000001",
        normalizedInputs: CanonicalDeal(
            id: deal.id,
            name: deal.name,
            address: deal.address,
            strategy: deal.strategy,
            property: deal.property,
            scenario: deal.scenarios[0]
        ),
        metrics: CalculationMetrics(capRate: Rate(fraction: 0.075)),
        verdict: Verdict(category: .strong, confidence: .high)
    )
    
    let persistedSnap = try DealMapper.toPersistence(from: snapshot)
    let restoredSnap = try DealMapper.toDomain(from: persistedSnap)
    
    #expect(restoredSnap.id == snapshot.id)
    #expect(restoredSnap.inputHash == "c0ffeebabe000001")
    #expect(restoredSnap.verdict.category == .strong)
    #expect(restoredSnap.metrics.capRate.percentage == 7.5)
}
#endif
