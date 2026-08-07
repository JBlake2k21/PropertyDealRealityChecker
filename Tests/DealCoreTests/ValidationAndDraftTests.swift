//
//  ValidationAndDraftTests.swift
//  PropertyDealRealityCheckerTests
//
//  Stage 2 — Draft Buffer, Validation & Canonical Deal Unit Tests
//

import Foundation
import DealCore

#if canImport(Testing)
import Testing

@Test("Verify DraftDeal continuous validation feedback without crashing")
func testDraftDealContinuousValidation() {
    var draft = DraftDeal()
    draft.name = ""
    draft.baseScenario.projectCost.purchasePrice = .zero
    draft.baseScenario.incomeLines = []
    
    let issues = draft.validate()
    #expect(issues.count >= 2)
    #expect(draft.canBecomeCanonical == false)
    #expect(issues.contains(where: { $0.code == "VAL-001" && $0.severity == .warning })) // blank name
    #expect(issues.contains(where: { $0.code == "VAL-101" && $0.severity == .error })) // purchase price <= 0
}

@Test("Verify DraftDeal to CanonicalDeal conversion throws on blocking errors")
func testDraftToCanonicalThrows() {
    let draft = DraftDeal()
    do {
        _ = try draft.toCanonical()
        #expect(Bool(false), "Should have thrown DraftDealValidationError")
    } catch {
        #expect(true)
    }
}

@Test("Verify CanonicalDeal inputHash determinism and CalculationSnapshot audit properties")
func testCanonicalDealAndSnapshot() throws {
    var draft = DraftDeal(name: "Test Rental")
    draft.baseScenario.projectCost.purchasePrice = CurrencyAmount(amount: 300_000)
    draft.baseScenario.incomeLines.append(IncomeLine(
        category: .contractualRent,
        amount: CurrencyAmount(amount: 2500),
        frequency: .monthly
    ))
    
    let canonical = try draft.toCanonical()
    #expect(!canonical.inputHash.isEmpty)
    
    let snapshot = CalculationSnapshot(
        dealID: canonical.id,
        scenarioID: canonical.scenario.id,
        inputHash: canonical.inputHash,
        normalizedInputs: canonical,
        metrics: CalculationMetrics(capRate: Rate(fraction: 0.075)),
        verdict: Verdict(category: .workable, confidence: .medium)
    )
    #expect(snapshot.ruleSetVersion == "Rental-US-1.0")
    #expect(snapshot.metrics.capRate.percentage == 7.5)
}

@Test("Verify UserDefaultsProfile conservative default thresholds")
func testUserDefaultsProfileDefaults() {
    let profile = UserDefaultsProfile.conservativeRentalUS
    #expect(profile.minDSCR == 1.25)
    #expect(profile.minCoCReturn.percentage == 8.0)
    #expect(profile.maxLTV.percentage == 75.0)
    #expect(profile.capRateDenominatorRule == .purchasePrice)
}
#endif
