//
//  MainTabView.swift
//  PropertyDealRealityChecker
//
//  Stage 8 — Application Shell
//  Architectural Mandate: Main navigation routing for the feature modules.
//

import Foundation
#if canImport(SwiftUI)
import SwiftUI
import FeatureDealEntry
import FeatureDashboard
import FeatureScenarios
import DealCore
import DesignSystem

/// The main application navigation tab view.
public struct MainTabView: View {
    @State private var dashboardViewModel: DashboardViewModel
    @State private var scenarioViewModel = ScenarioComparisonViewModel()
    
    public init() {
        let sampleDeal = Deal(name: "Sample Property", address: "123 Main St")
        let canonical = CanonicalDeal(
            id: sampleDeal.id,
            name: sampleDeal.name,
            address: sampleDeal.address,
            strategy: sampleDeal.strategy,
            property: sampleDeal.property,
            scenario: sampleDeal.activeScenario
        )
        let snapshot = CalculationSnapshot(
            dealID: sampleDeal.id,
            scenarioID: sampleDeal.activeScenario.id,
            inputHash: canonical.inputHash,
            normalizedInputs: canonical,
            metrics: CalculationMetrics(),
            verdict: Verdict(category: .workable, confidence: .high)
        )
        _dashboardViewModel = State(initialValue: DashboardViewModel(snapshot: snapshot))
    }
    
    public var body: some View {
        TabView {
            NavigationView {
                DealEntryView(viewModel: DealEntryViewModel()) { deal in
                    // Handle deal commit here
                    print("Deal committed: \(deal.address)")
                }
            }
            .tabItem {
                Label("Entry", systemImage: "doc.badge.plus")
            }
            
            NavigationView {
                DashboardView(viewModel: dashboardViewModel)
            }
            .tabItem {
                Label("Dashboard", systemImage: "chart.bar.xaxis")
            }
            
            NavigationView {
                ScenarioComparisonView(viewModel: scenarioViewModel)
            }
            .tabItem {
                Label("Scenarios", systemImage: "arrow.left.arrow.right")
            }
        }
        .accentColor(.designStrong)
    }
}
#endif
