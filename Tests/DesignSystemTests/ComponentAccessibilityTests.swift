//
//  ComponentAccessibilityTests.swift
//  PropertyDealRealityCheckerTests
//
//  Stage 5 — Component Accessibility Label Unit Tests
//

import Foundation
import DesignSystem

#if canImport(Testing)
import Testing

@Test("Verify FinancialMetricCardModel VoiceOver accessibility description formatting")
func testFinancialMetricCardAccessibility() {
    let card = FinancialMetricCardModel(
        title: "Cap Rate",
        value: "7.25%",
        subtitle: "Target >= 7.00%",
        trendRawValue: "up",
        statusCategoryRawValue: "strong"
    )
    
    let desc = card.accessibilityDescription
    #expect(desc.contains("Cap Rate: 7.25%"))
    #expect(desc.contains("Target >= 7.00%"))
}

@Test("Verify VerdictBadgeModel and ReasonCodeRowModel VoiceOver descriptions")
func testVerdictAndReasonAccessibility() {
    let badge = VerdictBadgeModel(categoryName: "Strong")
    #expect(badge.accessibilityDescription == "Verdict Category: Strong")
    
    let reason = ReasonCodeRowModel(
        code: "DSCR-001",
        metricName: "Debt Service Coverage Ratio",
        actualValue: "1.30x",
        thresholdValue: "1.25x minimum",
        isSuccess: true,
        explanation: "Sufficient income to cover debt service."
    )
    
    let reasonDesc = reason.accessibilityDescription
    #expect(reasonDesc.contains("DSCR-001 (Pass)"))
    #expect(reasonDesc.contains("Actual 1.30x"))
}

@Test("Verify chart and grid accessibility descriptions")
func testChartAccessibility() {
    let cell1 = SensitivityGridCellModel(
        rowLabel: "$300,000",
        colLabel: "5% Vac",
        primaryMetricText: "NOI: $25,000",
        secondaryMetricText: "DSCR: 1.35x",
        isPassing: true
    )
    #expect(cell1.accessibilityDescription.contains("$300,000 at 5% Vac"))
    
    let grid = SensitivityMatrixGridModel(
        matrixTitle: "Price vs Vacancy",
        rowHeaderName: "Purchase Price",
        colHeaderName: "Vacancy Rate",
        cells: [[cell1]]
    )
    #expect(grid.accessibilityDescription.contains("1 scenarios. 1 passing."))
    
    let waterfall = CashFlowWaterfallChartModel(
        gsiText: "$40,000",
        egiText: "$36,800",
        noiText: "$28,000",
        debtServiceText: "$18,000",
        ownerCashFlowText: "$10,000",
        isCashFlowPositive: true
    )
    #expect(waterfall.accessibilityDescription.contains("Positive Cash Flow"))
}
#endif
