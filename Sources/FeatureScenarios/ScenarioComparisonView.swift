//
//  ScenarioComparisonView.swift
//  PropertyDealRealityChecker
//
//  Stage 6 — Feature Modules: Deal Entry, Underwriting Dashboard & Scenario Comparison
//  Architectural Mandate: Side-by-side scenario comparison view table using DesignSystem tokens.
//

import Foundation
import DealCore
import DesignSystem
#if canImport(SwiftUI)
import SwiftUI
#endif

#if canImport(SwiftUI)
/// A side-by-side scenario comparison table view for evaluating investment sensitivity.
public struct ScenarioComparisonView: View {
    public let viewModel: ScenarioComparisonViewModel
    
    public init(viewModel: ScenarioComparisonViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            HStack(alignment: .top, spacing: 16) {
                ForEach(viewModel.columns) { column in
                    VStack(alignment: .leading, spacing: 12) {
                        Text(column.scenarioName)
                            .font(.designTitleMedium)
                            .foregroundColor(.designTextPrimary)
                        
                        Divider()
                        
                        metricRow(title: "NOI", value: column.noiText)
                        metricRow(title: "Cap Rate", value: column.capRateText)
                        metricRow(title: "CoC Return", value: column.cocText)
                        metricRow(title: "DSCR", value: column.dscrText)
                        
                        Divider()
                        
                        HStack {
                            Text("Status")
                                .font(.designCaption)
                                .foregroundColor(.designTextSecondary)
                            Spacer()
                            Text(column.isPassing ? "PASS" : "ALERT")
                                .font(.designCaption)
                                .foregroundColor(column.isPassing ? .designStrong : .designHighRisk)
                        }
                    }
                    .padding()
                    .frame(width: 220)
                    .background(Color.designSurface)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(column.isPassing ? Color.designStrong : Color.designBorder, lineWidth: 1)
                    )
                }
            }
            .padding()
        }
        .background(Color.designSurface)
        .navigationTitle("Scenario Comparison")
    }
    
    private func metricRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.designBodyMedium)
                .foregroundColor(.designTextSecondary)
            Spacer()
            Text(value)
                .font(.designFinancialMonospaced)
                .foregroundColor(.designTextPrimary)
        }
    }
}
#endif
