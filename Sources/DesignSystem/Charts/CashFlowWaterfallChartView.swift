//
//  CashFlowWaterfallChartView.swift
//  PropertyDealRealityChecker
//
//  Stage 5 — Shared Design System, Theme Engine & Chart Library
//  Architectural Mandate: Accessible visual waterfall chart for income and debt service deductions.
//

import Foundation
#if canImport(SwiftUI)
import SwiftUI
#endif

/// Data model and accessibility descriptor for a `CashFlowWaterfallChartView`.
public struct CashFlowWaterfallChartModel: Sendable, Hashable, Codable {
    public let gsiText: String
    public let egiText: String
    public let noiText: String
    public let debtServiceText: String
    public let ownerCashFlowText: String
    public let isCashFlowPositive: Bool
    
    public init(
        gsiText: String,
        egiText: String,
        noiText: String,
        debtServiceText: String,
        ownerCashFlowText: String,
        isCashFlowPositive: Bool
    ) {
        self.gsiText = gsiText
        self.egiText = egiText
        self.noiText = noiText
        self.debtServiceText = debtServiceText
        self.ownerCashFlowText = ownerCashFlowText
        self.isCashFlowPositive = isCashFlowPositive
    }
    
    /// Comprehensive accessibility description summarizing waterfall deductions for screen readers.
    public var accessibilityDescription: String {
        let status = isCashFlowPositive ? "Positive Cash Flow" : "Negative Cash Flow Alert"
        return "Cash Flow Waterfall: Gross Income \(gsiText), Effective Income \(egiText), Net Operating Income \(noiText), less Debt Service \(debtServiceText) leaves Owner Pre-Tax Cash Flow of \(ownerCashFlowText). (\(status))"
    }
}

#if canImport(SwiftUI)
/// A visual waterfall bar chart component illustrating revenue step-down to net owner cash flow.
public struct CashFlowWaterfallChartView: View {
    public let model: CashFlowWaterfallChartModel
    
    public init(model: CashFlowWaterfallChartModel) {
        self.model = model
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Cash Flow Waterfall")
                .font(.designTitleMedium)
                .foregroundColor(.designTextPrimary)
            
            VStack(spacing: 8) {
                barRow(title: "Gross Scheduled Income", valueText: model.gsiText, color: .designWorkable)
                barRow(title: "Effective Gross Income", valueText: model.egiText, color: .designWorkable)
                barRow(title: "Net Operating Income", valueText: model.noiText, color: .designWorkable)
                barRow(title: "Annual Debt Service", valueText: model.debtServiceText, color: .designTextSecondary)
                barRow(
                    title: "Owner Pre-Tax Cash Flow",
                    valueText: model.ownerCashFlowText,
                    color: model.isCashFlowPositive ? .designStrong : .designHighRisk
                )
            }
        }
        .padding()
        .background(Color.designSurface)
        .cornerRadius(12)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(model.accessibilityDescription)
    }
    
    private func barRow(title: String, valueText: String, color: Color) -> some View {
        HStack {
            Text(title)
                .font(.designBodyMedium)
                .foregroundColor(.designTextSecondary)
            Spacer()
            Text(valueText)
                .font(.designFinancialMonospaced)
                .foregroundColor(color)
        }
        .padding(.vertical, 4)
    }
}
#endif
