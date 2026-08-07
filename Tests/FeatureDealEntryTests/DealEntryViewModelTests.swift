//
//  DealEntryViewModelTests.swift
//  PropertyDealRealityCheckerTests
//
//  Stage 6 — DealEntryViewModel Unit Tests
//

import Foundation
import DealCore
import FeatureDealEntry

#if canImport(Testing)
import Testing

@Test("Verify DealEntryViewModel string binding to Decimal parsing without Double")
func testDealEntryViewModelStringParsing() throws {
    let vm = DealEntryViewModel()
    vm.purchasePriceString = "350000"
    vm.monthlyRentString = "3200"
    vm.mortgagePrincipalString = "280000"
    vm.interestRatePercentageString = "6.75"
    
    vm.updateDraftFromStrings()
    
    #expect(vm.draftDeal.baseScenario.projectCost.purchasePrice.amount == 350_000)
    #expect(vm.draftDeal.baseScenario.incomeLines[0].amount.amount == 3200)
    #expect(vm.draftDeal.baseScenario.financingPlan.firstMortgage?.interestRate.percentage == Decimal(string: "6.75")!)
}

@Test("Verify DealEntryViewModel commitToCanonical produces valid CanonicalDeal")
func testDealEntryViewModelCommit() throws {
    let vm = DealEntryViewModel()
    vm.purchasePriceString = "300000"
    vm.closingCostsString = "5000"
    vm.monthlyRentString = "2800"
    vm.annualTaxString = "3600"
    vm.annualInsuranceString = "1200"
    
    let canonical = try vm.commitToCanonical()
    #expect(canonical.property.numberOfUnits == 1)
    #expect(canonical.scenario.projectCost.purchasePrice.amount == 300_000)
}
#endif
