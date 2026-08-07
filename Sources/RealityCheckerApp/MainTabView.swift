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
    @State private var dashboardViewModel = DashboardViewModel()
    @State private var scenarioViewModel = ScenarioComparisonViewModel()
    
    public init() {}
    
    public var body: some View {
        TabView {
            NavigationView {
                DealEntryView(viewModel: DealEntryViewModel()) { deal in
                    // Handle deal commit here
                    print("Deal committed: \(deal.property.address)")
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
