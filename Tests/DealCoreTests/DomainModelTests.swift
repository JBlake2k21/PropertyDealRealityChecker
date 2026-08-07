//
//  DomainModelTests.swift
//  PropertyDealRealityCheckerTests
//
//  Stage 2 — Domain Model Entities Unit Tests
//

import Foundation
import DealCore

#if canImport(Testing)
import Testing

@Test("Verify Property residential unit limits")
func testPropertyUnitLimits() {
    let prop = Property(propertyType: .multiFamily, numberOfUnits: 4)
    #expect(prop.numberOfUnits == 4)
    
    let clamped = Property(numberOfUnits: -5)
    #expect(clamped.numberOfUnits == 1) // Clamped to min 1
}

@Test("Verify IncomeLine annualized rental calculation and collection factor")
func testIncomeLineAnnualizedAmount() {
    let rent = IncomeLine(
        category: .contractualRent,
        amount: CurrencyAmount(amount: 2000),
        frequency: .monthly,
        collectionFactor: Rate(fraction: 0.95) // 5% vacancy/credit loss
    )
    #expect(rent.annualizedAmount.amount == 22800) // 2000 * 12 * 0.95
}

@Test("Verify ExpenseLine default NOI inclusion policy")
func testExpenseLineNOIInclusion() {
    let tax = ExpenseLine(category: .propertyTax, amount: CurrencyAmount(amount: 3000), frequency: .annual)
    #expect(tax.inclusionInNOI == true)
    
    let reserves = ExpenseLine(category: .capitalReserves, amount: CurrencyAmount(amount: 1500), frequency: .annual)
    #expect(reserves.inclusionInNOI == false) // Excluded from Accounting NOI by default
}

@Test("Verify ProjectCost total project cost and initial cash required")
func testProjectCostCalculations() {
    let cost = ProjectCost(
        purchasePrice: CurrencyAmount(amount: 400_000),
        closingCosts: CurrencyAmount(amount: 10_000),
        rehabBudget: CurrencyAmount(amount: 25_000),
        rehabContingency: CurrencyAmount(amount: 2_500),
        financingFees: CurrencyAmount(amount: 4_000),
        sellerCredits: CurrencyAmount(amount: 5_000)
    )
    #expect(cost.totalProjectCost.amount == 441_500)
    
    let totalDebt = CurrencyAmount(amount: 300_000)
    #expect(cost.totalInitialCashRequired(totalDebtPrincipal: totalDebt).amount == 136_500) // 441500 - 300000 - 5000
}

@Test("Verify FinancingPlan all-cash and debt layer sorting")
func testFinancingPlanDebtLayers() {
    #expect(FinancingPlan.allCash.isAllCash == true)
    
    let second = DebtLayer(
        name: "Seller Second",
        financingType: .sellerFinance,
        lienPosition: 2,
        principal: CurrencyAmount(amount: 40_000),
        interestRate: Rate(fraction: 0.06)
    )
    let first = DebtLayer(
        name: "Bank Mortgage",
        financingType: .amortizing,
        lienPosition: 1,
        principal: CurrencyAmount(amount: 280_000),
        interestRate: Rate(fraction: 0.07)
    )
    
    let plan = FinancingPlan(debtLayers: [second, first])
    #expect(plan.isAllCash == false)
    #expect(plan.debtLayers[0].lienPosition == 1) // Sorted by lien position
    #expect(plan.firstMortgage?.name == "Bank Mortgage")
    #expect(plan.subordinateLayers.count == 1)
    #expect(plan.totalDebtPrincipal.amount == 320_000)
}

@Test("Verify Deal aggregate root scenario management")
func testDealAggregateScenarios() {
    let deal = Deal(name: "Duplex Test")
    #expect(deal.scenarios.count == 1)
    #expect(deal.activeScenario.isBase == true)
}
#endif
