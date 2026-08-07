//
//  DashboardView.swift
//  PropertyDealRealityChecker
//
//  Stage 6 — Feature Modules: Deal Entry, Underwriting Dashboard & Scenario Comparison
//  Architectural Mandate: Executive underwriting dashboard view rendering DesignSystem components.
//

import Foundation
import DealCore
import DesignSystem
#if canImport(SwiftUI)
import SwiftUI
#endif

#if canImport(SwiftUI)
/// Executive underwriting summary dashboard for evaluating deal viability.
public struct DashboardView: View {
    public let viewModel: DashboardViewModel
    
    public init(viewModel: DashboardViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 1. Hero Verdict Badge Header
                HStack {
                    Text("Underwriting Verdict")
                        .font(.designTitleLarge)
                        .foregroundColor(.designTextPrimary)
                    Spacer()
                    VerdictBadgeView(model: viewModel.verdictBadgeModel)
                }
                
                // 2. Financial Metrics Grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(viewModel.metricCards, id: \.title) { cardModel in
                        FinancialMetricCard(model: cardModel)
                    }
                }
                
                // 3. Cash Flow Waterfall Chart
                CashFlowWaterfallChartView(model: viewModel.waterfallModel)
                
                // 4. Stress-Test Grid
                SensitivityMatrixGridView(model: viewModel.stressGridModel)
                
                // 5. Underwriting Reason Codes
                VStack(alignment: .leading, spacing: 10) {
                    Text("Underwriting Reasons & Alerts")
                        .font(.designTitleMedium)
                        .foregroundColor(.designTextPrimary)
                    
                    ForEach(viewModel.reasonRows, id: \.code) { reasonModel in
                        ReasonCodeRowView(model: reasonModel)
                    }
                }
            }
            .padding()
        }
        .background(Color.designSurface)
        .navigationTitle("Reality Checker Dashboard")
    }
}
#endif
