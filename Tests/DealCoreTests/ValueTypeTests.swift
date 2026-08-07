//
//  ValueTypeTests.swift
//  PropertyDealRealityCheckerTests
//
//  Stage 2 — Financial Value Types Unit Tests
//

import Foundation
import DealCore

#if canImport(Testing)
import Testing

@Test("Verify CurrencyAmount Decimal precision and banker's rounding")
func testCurrencyAmountBankersRounding() {
    let amount = CurrencyAmount(amount: Decimal(string: "125000.555")!)
    #expect(amount.currencyCode == "USD")
    #expect(amount.bankersRoundedAmount == Decimal(string: "125000.56")!)
    
    let halfEvenLow = CurrencyAmount(amount: Decimal(string: "10.125")!)
    #expect(halfEvenLow.bankersRoundedAmount == Decimal(string: "10.12")!) // round half to even
    
    let halfEvenHigh = CurrencyAmount(amount: Decimal(string: "10.135")!)
    #expect(halfEvenHigh.bankersRoundedAmount == Decimal(string: "10.14")!)
}

@Test("Verify Rate canonical fraction and percentage conversions")
func testRateCanonicalConversions() {
    let rate = Rate(percentage: Decimal(string: "7.25")!)
    #expect(rate.fraction == Decimal(string: "0.0725")!)
    #expect(rate.percentage == Decimal(string: "7.25")!)
    #expect(rate.bankersRoundedPercentage == Decimal(string: "7.25")!)
}

@Test("Verify Frequency annualize and deannualize rules")
func testFrequencyConversions() {
    let monthly = Frequency.monthly
    #expect(monthly.annualize(amount: 1500) == 18000)
    #expect(monthly.deannualize(annualAmount: 24000) == 2000)
    
    let annual = Frequency.annual
    #expect(annual.annualize(amount: 5000) == 5000)
}

@Test("Verify ConfidenceLevel ordering hierarchy")
func testConfidenceLevelOrdering() {
    #expect(ConfidenceLevel.high > ConfidenceLevel.medium)
    #expect(ConfidenceLevel.medium > ConfidenceLevel.low)
    #expect(ConfidenceLevel.low > ConfidenceLevel.unverified)
}

@Test("Verify SourceRecord default confidence mappings")
func testSourceRecordDefaults() {
    let verified = SourceRecord(sourceType: .verified)
    #expect(verified.confidenceLevel == .high)
    
    let listing = SourceRecord(sourceType: .listing)
    #expect(listing.confidenceLevel == .medium)
    
    let manual = SourceRecord.defaultManual
    #expect(manual.confidenceLevel == .low)
}
#endif
