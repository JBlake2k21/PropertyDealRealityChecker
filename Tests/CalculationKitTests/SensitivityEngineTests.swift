//
//  SensitivityEngineTests.swift
//  PropertyDealRealityCheckerTests
//
//  Stage 3 — Sensitivity & Stress-Test Matrix Unit Tests
//

import Foundation
import CalculationKit

#if canImport(Testing)
import Testing

@Test("Verify 3x3 Purchase Price vs Vacancy Rate sensitivity matrix generation")
func test3x3SensitivityMatrix() {
    let matrix = SensitivityEngine.generatePriceVsVacancyMatrix(
        basePrice: 300_000,
        baseGSI: 40_000,
        baseOperatingExpenses: 10_000,
        baseCapitalReserves: 2_000,
        annualDebtService: 18_000,
        baseInitialCash: 80_000
    )
    
    #expect(matrix.cells.count == 3) // 3 price rows (-5%, 0%, +5%)
    #expect(matrix.cells[0].count == 3) // 3 vacancy columns (5%, 8%, 10%)
    
    // Check that higher vacancy reduces NOI and DSCR
    let cellLowVac = matrix.cells[1][0] // 0% price change ($300,000), 5% Vacancy
    let cellHighVac = matrix.cells[1][2] // 0% price change ($300,000), 10% Vacancy
    
    #expect(cellLowVac.noi > cellHighVac.noi)
    #expect(cellLowVac.dscr > cellHighVac.dscr)
    #expect(cellLowVac.cashOnCashReturn > cellHighVac.cashOnCashReturn)
}
#endif
