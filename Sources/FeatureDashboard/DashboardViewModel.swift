//
//  DashboardViewModel.swift
//  PropertyDealRealityChecker
//
//  Stage 6 — Feature Modules: Deal Entry, Underwriting Dashboard & Scenario Comparison
//  Architectural Mandate: Executive dashboard state and DTO projection for CalculationSnapshot.
//  Zero imports of CalculationKit or PersistenceKit.
//

import Foundation
import DealCore
import DesignSystem
#if canImport(SwiftUI)
import SwiftUI
#endif

/// Executive underwriting dashboard state model.
///
/// Implements Blueprint Section 12 ("Feature Modules and UI Architecture"):
/// Transforms an immutable `CalculationSnapshot` into UI-ready `DesignSystem` presentation descriptors.
#if canImport(SwiftUI)
@Observable
#endif
public final class DashboardViewModel: @unchecked Sendable {
    public let snapshot: CalculationSnapshot
    public let verdictBadgeModel: VerdictBadgeModel
    public let metricCards: [FinancialMetricCardModel]
    public let reasonRows: [ReasonCodeRowModel]
    public let waterfallModel: CashFlowWaterfallChartModel
    public let stressGridModel: SensitivityMatrixGridModel
    
    public init(snapshot: CalculationSnapshot) {
        self.snapshot = snapshot
        self.verdictBadgeModel = VerdictBadgeModel(categoryName: snapshot.verdict.category.rawValue)
        
        // 1. Metric Cards
        let capRateText = String(format: "%.2f%%", NSDecimalNumber(decimal: snapshot.metrics.capRate.percentage).doubleValue)
        let cocText = String(format: "%.2f%%", NSDecimalNumber(decimal: snapshot.metrics.cashOnCashReturn.percentage).doubleValue)
        let dscrText = String(format: "%.2fx", NSDecimalNumber(decimal: snapshot.metrics.dscr).doubleValue)
        let beText = String(format: "%.1f%%", NSDecimalNumber(decimal: snapshot.metrics.breakEvenOccupancyRate.percentage).doubleValue)
        
        let categoryRaw = snapshot.verdict.category.rawValue
        
        self.metricCards = [
            FinancialMetricCardModel(
                title: "Cap Rate",
                value: capRateText,
                subtitle: "Target >= 7.00%",
                trendRawValue: "up",
                statusCategoryRawValue: categoryRaw
            ),
            FinancialMetricCardModel(
                title: "CoC Return",
                value: cocText,
                subtitle: "Target >= 8.00%",
                trendRawValue: "up",
                statusCategoryRawValue: categoryRaw
            ),
            FinancialMetricCardModel(
                title: "DSCR",
                value: dscrText,
                subtitle: "Minimum 1.25x",
                trendRawValue: "up",
                statusCategoryRawValue: categoryRaw
            ),
            FinancialMetricCardModel(
                title: "Break-Even Occupancy",
                value: beText,
                subtitle: "Max 85.0%",
                trendRawValue: "down",
                statusCategoryRawValue: categoryRaw
            )
        ]
        
        // 2. Reason Rows
        self.reasonRows = snapshot.verdict.reasonCodes.map { reason in
            let isPass = reason.code.hasPrefix("DSCR") ? (snapshot.metrics.dscr >= Decimal(string: "1.25")!) : true
            return ReasonCodeRowModel(
                code: reason.code,
                metricName: reason.code,
                actualValue: "Observed",
                thresholdValue: "Required",
                isSuccess: isPass,
                explanation: reason.plainLanguageExplanation
            )
        }
        
        // 3. Cash Flow Waterfall Chart
        let gsiText = "$\(NSDecimalNumber(decimal: snapshot.metrics.grossScheduledIncome.amount))"
        let egiText = "$\(NSDecimalNumber(decimal: snapshot.metrics.effectiveGrossIncome.amount))"
        let noiText = "$\(NSDecimalNumber(decimal: snapshot.metrics.netOperatingIncome.amount))"
        let dsText = "$\(NSDecimalNumber(decimal: snapshot.metrics.annualDebtService.amount))"
        let cfText = "$\(NSDecimalNumber(decimal: snapshot.metrics.ownerCashFlow.amount))"
        let positiveCF = snapshot.metrics.ownerCashFlow.amount >= 0
        
        self.waterfallModel = CashFlowWaterfallChartModel(
            gsiText: gsiText,
            egiText: egiText,
            noiText: noiText,
            debtServiceText: dsText,
            ownerCashFlowText: cfText,
            isCashFlowPositive: positiveCF
        )
        
        // 4. Stress-Test Grid
        let cell = SensitivityGridCellModel(
            rowLabel: "Base",
            colLabel: "Base",
            primaryMetricText: "NOI: \(noiText)",
            secondaryMetricText: "DSCR: \(dscrText)",
            isPassing: snapshot.metrics.dscr >= Decimal(string: "1.25")!
        )
        self.stressGridModel = SensitivityMatrixGridModel(
            matrixTitle: "Price vs Vacancy Stress Grid",
            rowHeaderName: "Price",
            colHeaderName: "Vacancy",
            cells: [[cell]]
        )
    }
}
