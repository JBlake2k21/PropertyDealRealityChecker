//
//  ScenarioComparisonTests.swift
//  PropertyDealRealityCheckerTests
//
//  Stage 6 — ScenarioComparisonViewModel Unit Tests
//

import Foundation
import DealCore
import DesignSystem
import FeatureScenarios

#if canImport(Testing)
import Testing

@Test("Verify ScenarioComparisonViewModel side-by-side scenario addition and formatting")
func testScenarioComparisonViewModel() {
    let vm = ScenarioComparisonViewModel()
    
    vm.addScenario(
        name: "Base Case",
        noi: CurrencyAmount(amount: 24_000),
        capRate: Rate(fraction: 0.08),
        coc: Rate(fraction: 0.09),
        dscr: Decimal(string: "1.30")!,
        isPassing: true
    )
    
    vm.addScenario(
        name: "Conservative",
        noi: CurrencyAmount(amount: 20_000),
        capRate: Rate(fraction: 0.065),
        coc: Rate(fraction: 0.05),
        dscr: Decimal(string: "1.10")!,
        isPassing: false
    )
    
    #expect(vm.columns.count == 2)
    #expect(vm.columns[0].scenarioName == "Base Case")
    #expect(vm.columns[0].isPassing == true)
    #expect(vm.columns[1].scenarioName == "Conservative")
    #expect(vm.columns[1].isPassing == false)
    #expect(vm.columns[1].dscrText == "1.10x")
}
#endif
