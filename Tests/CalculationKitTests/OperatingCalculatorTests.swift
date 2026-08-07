//
//  OperatingCalculatorTests.swift
//  PropertyDealRealityCheckerTests
//
//  Stage 3 — Operating Calculator Unit Tests
//

import Foundation
import CalculationKit

#if canImport(Testing)
import Testing

@Test("Verify GSI sum from annualized revenue streams")
func testGSICalculation() {
    let incomeLines: [Decimal] = [24_000, 3_600, 1_200]
    let gsi = OperatingCalculator.calculateGSI(annualIncomeAmounts: incomeLines)
    #expect(gsi == 28_800)
}

@Test("Verify EGI vacancy and credit loss deduction")
func testEGICalculation() {
    let gsi: Decimal = 100_000
    let egi = OperatingCalculator.calculateEGI(
        gsi: gsi,
        vacancyRate: Decimal(string: "0.08")!,
        creditLossRate: Decimal(string: "0.02")!
    )
    #expect(egi == 90_000) // 100000 * (1 - 0.10)
}

@Test("Verify Accounting NOI excludes capital replacement reserves")
func testAccountingNOIExclusion() {
    let egi: Decimal = 90_000
    let expenses = [
        OperatingInputLine(name: "Property Tax", annualAmount: 10_000, isNOIExpense: true),
        OperatingInputLine(name: "Insurance", annualAmount: 5_000, isNOIExpense: true),
        OperatingInputLine(name: "Roof Reserve", annualAmount: 3_000, isNOIExpense: false)
    ]
    
    let noi = OperatingCalculator.calculateNOI(egi: egi, expenseLines: expenses)
    #expect(noi == 75_000) // 90000 - 15000 (3000 reserve excluded from NOI)
    
    let reserves = OperatingCalculator.calculateCapitalReservesTotal(expenseLines: expenses)
    #expect(reserves == 3_000)
}

@Test("Verify Owner Pre-Tax Cash Flow formula")
func testOwnerCashFlow() {
    let noi: Decimal = 75_000
    let reserves: Decimal = 3_000
    let debtService: Decimal = 50_000
    
    let cashFlow = OperatingCalculator.calculateOwnerCashFlow(
        noi: noi,
        capitalReserves: reserves,
        annualDebtService: debtService
    )
    #expect(cashFlow == 22_000) // 75000 - 3000 - 50000
}
#endif
