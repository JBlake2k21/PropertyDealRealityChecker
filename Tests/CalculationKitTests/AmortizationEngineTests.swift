//
//  AmortizationEngineTests.swift
//  PropertyDealRealityCheckerTests
//
//  Stage 3 — Amortization Engine Unit Tests
//

import Foundation
import CalculationKit

#if canImport(Testing)
import Testing

@Test("Verify 30-year amortizing mortgage payment PMT accuracy")
func testAmortizingMonthlyPayment() {
    let mortgage = AmortizationInputLayer(
        name: "First Mortgage",
        principal: 300_000,
        annualInterestRate: Decimal(string: "0.07")!, // 7.0%
        amortizationMonths: 360,
        contractualTermMonths: 360,
        isInterestOnly: false
    )
    
    let pmt = AmortizationEngine.calculateMonthlyPayment(layer: mortgage)
    let roundedPMT = RoundingEngine.roundToBankers(amount: pmt, places: 2)
    
    // Standard 30-yr 7.0% mortgage on $300,000 is $1,995.91
    #expect(roundedPMT == Decimal(string: "1995.91")!)
}

@Test("Verify interest-only mortgage payment calculation")
func testInterestOnlyMonthlyPayment() {
    let ioMortgage = AmortizationInputLayer(
        name: "IO Loan",
        principal: 400_000,
        annualInterestRate: Decimal(string: "0.06")!, // 6.0%
        amortizationMonths: 360,
        contractualTermMonths: 60,
        isInterestOnly: true
    )
    
    let pmt = AmortizationEngine.calculateMonthlyPayment(layer: ioMortgage)
    #expect(pmt == 2000) // 400000 * 0.06 / 12 = 2000
}

@Test("Verify balloon principal burden remaining balance at contractual maturity")
func testBalloonBurden() {
    let balloon = AmortizationInputLayer(
        name: "5-Year Balloon",
        principal: 200_000,
        annualInterestRate: Decimal(string: "0.07")!,
        amortizationMonths: 360,
        contractualTermMonths: 60, // 5 years
        isInterestOnly: false
    )
    
    let burden = AmortizationEngine.calculateBalloonBurden(layers: [balloon])
    let roundedBurden = RoundingEngine.roundToBankers(amount: burden, places: 2)
    
    // After 60 months on $200k at 7% amortized over 30 yrs, balance is approx $188,719.53
    #expect(roundedBurden > 188_000 && roundedBurden < 189_000)
}
#endif
