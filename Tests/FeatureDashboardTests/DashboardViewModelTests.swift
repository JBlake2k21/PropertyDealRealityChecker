//
//  DashboardViewModelTests.swift
//  PropertyDealRealityCheckerTests
//
//  Stage 6 — DashboardViewModel Unit Tests
//

import Foundation
import DealCore
import DesignSystem
import FeatureDashboard

#if canImport(Testing)
import Testing

@Test("Verify DashboardViewModel projection from CalculationSnapshot")
func testDashboardViewModelProjection() {
    let deal = Deal(name: "Dashboard Test Deal")
    let metrics = CalculationMetrics(
        netOperatingIncome: CurrencyAmount(amount: 24_000),
        annualDebtService: CurrencyAmount(amount: 18_000),
        preTaxCashFlow: CurrencyAmount(amount: 6_000),
        capRate: Rate(fraction: 0.08),
        cashOnCashReturn: Rate(fraction: 0.10),
        debtServiceCoverageRatio: Decimal(string: "1.33")!,
        breakEvenOccupancy: Rate(fraction: 0.75)
    )
    let snapshot = CalculationSnapshot(
        dealID: deal.id,
        scenarioID: deal.scenarios[0].id,
        inputHash: "hash_001",
        normalizedInputs: CanonicalDeal(id: deal.id, name: deal.name, address: "", strategy: .longTermRental, property: Property(), scenario: Scenario()),
        metrics: metrics,
        verdict: Verdict(category: .strong, confidence: .high)
    )
    
    let vm = DashboardViewModel(snapshot: snapshot)
    
    #expect(vm.verdictBadgeModel.categoryName == "Strong")
    #expect(vm.metricCards.count == 4)
    #expect(vm.metricCards[0].title == "Cap Rate")
    #expect(vm.metricCards[0].value == "8.00%")
    #expect(vm.metricCards[2].title == "DSCR")
    #expect(vm.metricCards[2].value == "1.33x")
    #expect(vm.waterfallModel.isCashFlowPositive == true)
}
#endif
