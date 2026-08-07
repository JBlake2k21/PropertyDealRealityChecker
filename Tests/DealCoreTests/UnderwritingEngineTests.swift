//
//  UnderwritingEngineTests.swift
//  PropertyDealRealityCheckerTests
//
//  Stage 3 — End-to-End Underwriting Engine Integration Tests
//

import Foundation
import DealCore
import CalculationKit

#if canImport(Testing)
import Testing

@Test("Verify end-to-end UnderwritingEngine evaluation producing immutable CalculationSnapshot")
func testUnderwritingEngineEvaluation() throws {
    var draft = DraftDeal(name: "Duplex Investment Deal")
    
    // Set $300,000 purchase price & $10,000 closing costs
    draft.baseScenario.projectCost = ProjectCost(
        purchasePrice: CurrencyAmount(amount: 300_000),
        closingCosts: CurrencyAmount(amount: 10_000)
    )
    
    // Set $3,000 / mo contractual rent ($36,000/yr)
    draft.baseScenario.incomeLines = [
        IncomeLine(category: .contractualRent, amount: CurrencyAmount(amount: 3000), frequency: .monthly)
    ]
    
    // Set $6,000 property tax, $2,000 insurance, $1,500 roof reserve
    draft.baseScenario.expenseLines = [
        ExpenseLine(category: .propertyTax, amount: CurrencyAmount(amount: 6000), frequency: .annual),
        ExpenseLine(category: .insurance, amount: CurrencyAmount(amount: 2000), frequency: .annual),
        ExpenseLine(category: .capitalReserves, amount: CurrencyAmount(amount: 1500), frequency: .annual)
    ]
    
    // Set $240,000 mortgage at 6.0% over 30 yrs ($1,438.92/mo -> $17,267.04/yr)
    draft.baseScenario.financingPlan = FinancingPlan(debtLayers: [
        DebtLayer(
            name: "First Mortgage",
            principal: CurrencyAmount(amount: 240_000),
            interestRate: Rate(fraction: 0.06),
            amortizationMonths: 360,
            contractualTermMonths: 360
        )
    ])
    
    let canonical = try draft.toCanonical()
    let snapshot = UnderwritingEngine.evaluate(deal: canonical, profile: .conservativeRentalUS)
    
    #expect(snapshot.dealID == canonical.id)
    #expect(snapshot.inputHash == canonical.inputHash)
    #expect(snapshot.engineVersion == CalculationKitModule.engineVersion)
    #expect(snapshot.ruleSetVersion == "Rental-US-1.0")
    
    // EGI = 36000 * (1 - 0.08 default vacancy) = 33120
    #expect(snapshot.metrics.effectiveGrossIncome.amount == 33_120)
    
    // NOI = 33120 - 8000 (tax + ins) = 25120
    #expect(snapshot.metrics.netOperatingIncome.amount == 25_120)
    
    // Check DSCR (> 1.25 -> DSCR-001 passes)
    #expect(snapshot.verdict.reasonCodes.contains(where: { $0.code == "DSCR-001" }))
    #expect(snapshot.stressResults?.matrix?.cells.count == 3)
}
#endif
