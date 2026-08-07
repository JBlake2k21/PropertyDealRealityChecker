//
//  ReturnCalculatorTests.swift
//  PropertyDealRealityCheckerTests
//
//  Stage 3 — Return Calculator Unit Tests
//

import Foundation
import CalculationKit

#if canImport(Testing)
import Testing

@Test("Verify Cap Rate denominator policy (Purchase Price vs Total Project Cost)")
func testCapRateDenominatorPolicy() {
    let noi: Decimal = 30_000
    let price: Decimal = 400_000
    let totalCost: Decimal = 440_000 // includes 40k rehab/closing
    
    let capPrice = ReturnCalculator.calculateCapRate(
        noi: noi,
        purchasePrice: price,
        totalProjectCost: totalCost,
        useProjectCostAsDenominator: false
    )
    #expect(capPrice == Decimal(string: "0.075")!) // 30000 / 400000 = 7.5%
    
    let capCost = ReturnCalculator.calculateCapRate(
        noi: noi,
        purchasePrice: price,
        totalProjectCost: totalCost,
        useProjectCostAsDenominator: true
    )
    #expect(RoundingEngine.roundRate(rate: capCost, places: 4) == Decimal(string: "0.0682")!) // 6.82%
}

@Test("Verify Cash-on-Cash return formula and zero cash required handling")
func testCashOnCashReturn() {
    let coc = ReturnCalculator.calculateCashOnCashReturn(ownerCashFlow: 10_000, initialCashRequired: 100_000)
    #expect(coc == Decimal(string: "0.10")!) // 10.0%
    
    let zeroCash = ReturnCalculator.calculateCashOnCashReturn(ownerCashFlow: 5_000, initialCashRequired: 0)
    #expect(zeroCash == 9.99) // Clamped infinite return
}

@Test("Verify DSCR and all-cash deal 99.99 handling")
func testDSCRAllCash() {
    let normalDSCR = ReturnCalculator.calculateDSCR(noi: 30_000, annualDebtService: 24_000)
    #expect(normalDSCR == Decimal(string: "1.25")!)
    
    let allCashDSCR = ReturnCalculator.calculateDSCR(noi: 30_000, annualDebtService: 0)
    #expect(allCashDSCR == Decimal(string: "99.99")!)
}

@Test("Verify Break-Even Occupancy, LTV, LTC, and Debt Yield ratios")
func testLeverageAndBreakEvenRatios() {
    let beOcc = ReturnCalculator.calculateBreakEvenOccupancy(
        operatingExpenses: 15_000,
        annualDebtService: 20_000,
        gsi: 50_000
    )
    #expect(beOcc == Decimal(string: "0.70")!) // (15000+20000)/50000 = 70%
    
    let ltv = ReturnCalculator.calculateLTV(totalDebtPrincipal: 300_000, propertyValue: 400_000)
    #expect(ltv == Decimal(string: "0.75")!) // 75%
    
    let ltc = ReturnCalculator.calculateLTC(totalDebtPrincipal: 300_000, totalProjectCost: 375_000)
    #expect(ltc == Decimal(string: "0.80")!) // 80%
    
    let debtYield = ReturnCalculator.calculateDebtYield(noi: 30_000, totalDebtPrincipal: 300_000)
    #expect(debtYield == Decimal(string: "0.10")!) // 10%
}
#endif
