//
//  TokenTests.swift
//  PropertyDealRealityCheckerTests
//
//  Stage 5 — Design System Token Unit Tests
//

import Foundation
import DesignSystem

#if canImport(Testing)
import Testing

@Test("Verify semantic status colors in ColorTokens and ThemeEngine")
func testVerdictColorTokens() {
    let strong = ThemeEngine.verdictColor(forCategoryRawValue: "Strong")
    #expect(strong == ColorTokens.strong)
    
    let workable = ThemeEngine.verdictColor(forCategoryRawValue: "Workable")
    #expect(workable == ColorTokens.workable)
    
    let marginal = ThemeEngine.verdictColor(forCategoryRawValue: "Marginal")
    #expect(marginal == ColorTokens.marginal)
    
    let highRisk = ThemeEngine.verdictColor(forCategoryRawValue: "High Risk")
    #expect(highRisk == ColorTokens.highRisk)
}

@Test("Verify tabular number alignment flag on financial typography tokens")
func testTabularNumberTypography() {
    #expect(TypographyTokens.financialHero.isTabularNumbers == true)
    #expect(TypographyTokens.financialHero.size == 32)
    #expect(TypographyTokens.financialHero.weight == .bold)
    
    #expect(TypographyTokens.financialMonospaced.isTabularNumbers == true)
    #expect(TypographyTokens.financialMonospaced.size == 17)
    
    #expect(TypographyTokens.titleLarge.isTabularNumbers == false)
}
#endif
