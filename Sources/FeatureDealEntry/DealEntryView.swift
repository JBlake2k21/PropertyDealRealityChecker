//
//  DealEntryView.swift
//  PropertyDealRealityChecker
//
//  Stage 6 — Feature Modules: Deal Entry, Underwriting Dashboard & Scenario Comparison
//  Architectural Mandate: Guided investment deal entry form view using DesignSystem components.
//

import Foundation
import DealCore
import DesignSystem
#if canImport(SwiftUI)
import SwiftUI
#endif

#if canImport(SwiftUI)
/// A structured, guided input form view for capturing real-estate acquisition parameters.
public struct DealEntryView: View {
    @State private var viewModel: DealEntryViewModel
    public var onCommit: ((CanonicalDeal) -> Void)?
    
    public init(viewModel: DealEntryViewModel = DealEntryViewModel(), onCommit: ((CanonicalDeal) -> Void)? = nil) {
        self._viewModel = State(initialValue: viewModel)
        self.onCommit = onCommit
    }
    
    public var body: some View {
        Form {
            Section(header: Text("Property Acquisition").font(.designTitleMedium)) {
                CurrencyTextFieldView(
                    model: CurrencyTextFieldModel(label: "Purchase Price", placeholder: "$300,000"),
                    text: $viewModel.purchasePriceString
                )
                CurrencyTextFieldView(
                    model: CurrencyTextFieldModel(label: "Closing Costs", placeholder: "$8,000"),
                    text: $viewModel.closingCostsString
                )
            }
            
            Section(header: Text("Operating Income & Expenses").font(.designTitleMedium)) {
                CurrencyTextFieldView(
                    model: CurrencyTextFieldModel(label: "Monthly Rent", placeholder: "$2,800"),
                    text: $viewModel.monthlyRentString
                )
                CurrencyTextFieldView(
                    model: CurrencyTextFieldModel(label: "Annual Property Tax", placeholder: "$4,500"),
                    text: $viewModel.annualTaxString
                )
                CurrencyTextFieldView(
                    model: CurrencyTextFieldModel(label: "Annual Insurance", placeholder: "$1,800"),
                    text: $viewModel.annualInsuranceString
                )
            }
            
            Section(header: Text("Debt Financing").font(.designTitleMedium)) {
                CurrencyTextFieldView(
                    model: CurrencyTextFieldModel(label: "Mortgage Principal", placeholder: "$240,000"),
                    text: $viewModel.mortgagePrincipalString
                )
                CurrencyTextFieldView(
                    model: CurrencyTextFieldModel(label: "Interest Rate (%)", placeholder: "6.5"),
                    text: $viewModel.interestRatePercentageString
                )
            }
            
            if !viewModel.validationIssues.isEmpty {
                Section(header: Text("Validation Notice").font(.designCaption)) {
                    ForEach(viewModel.validationIssues, id: \.message) { issue in
                        Text(issue.message)
                            .font(.designBodyMedium)
                            .foregroundColor(.designHighRisk)
                    }
                }
            }
            
            Section {
                Button(action: commitDeal) {
                    Text("Evaluate Deal")
                        .font(.designTitleMedium)
                        .foregroundColor(.designStrong)
                }
            }
        }
        .navigationTitle("Property Deal Entry")
    }
    
    private func commitDeal() {
        do {
            let canonical = try viewModel.commitToCanonical()
            onCommit?(canonical)
        } catch {
            viewModel.validationIssues.append(
                ValidationIssue(severity: .error, field: "Form", message: "Failed to commit deal: \(error)")
            )
        }
    }
}
#endif
