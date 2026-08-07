//
//  ReasonCodeRowView.swift
//  PropertyDealRealityChecker
//
//  Stage 5 — Shared Design System, Theme Engine & Component Library
//  Architectural Mandate: Explainable underwriting reason code row component.
//

import Foundation
#if canImport(SwiftUI)
import SwiftUI
#endif

/// Data model and accessibility descriptor for a `ReasonCodeRowView`.
public struct ReasonCodeRowModel: Sendable, Hashable, Codable {
    public let code: String
    public let metricName: String
    public let actualValue: String
    public let thresholdValue: String
    public let isSuccess: Bool
    public let explanation: String
    
    public init(
        code: String,
        metricName: String,
        actualValue: String,
        thresholdValue: String,
        isSuccess: Bool,
        explanation: String
    ) {
        self.code = code
        self.metricName = metricName
        self.actualValue = actualValue
        self.thresholdValue = thresholdValue
        self.isSuccess = isSuccess
        self.explanation = explanation
    }
    
    /// Complete VoiceOver accessibility label for screen readers.
    public var accessibilityDescription: String {
        let statusText = isSuccess ? "Pass" : "Fail"
        return "\(code) (\(statusText)): \(metricName). Actual \(actualValue), threshold \(thresholdValue). \(explanation)"
    }
}

#if canImport(SwiftUI)
/// An explainable row component displaying an underwriting reason code and plain-language explanation.
public struct ReasonCodeRowView: View {
    public let model: ReasonCodeRowModel
    
    public init(model: ReasonCodeRowModel) {
        self.model = model
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(model.code)
                    .font(.designCaption)
                    .foregroundColor(statusColor)
                Spacer()
                Text(model.isSuccess ? "PASS" : "ALERT")
                    .font(.designCaption)
                    .foregroundColor(statusColor)
            }
            
            HStack {
                Text(model.metricName)
                    .font(.designTitleMedium)
                    .foregroundColor(.designTextPrimary)
                Spacer()
                Text(model.actualValue)
                    .font(.designFinancialMonospaced)
                    .foregroundColor(.designTextPrimary)
            }
            
            Text("Threshold: \(model.thresholdValue)")
                .font(.designCaption)
                .foregroundColor(.designTextSecondary)
            
            Text(model.explanation)
                .font(.designBodyMedium)
                .foregroundColor(.designTextSecondary)
                .padding(.top, 2)
        }
        .padding()
        .background(Color.designSurface)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.designBorder, lineWidth: 1)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(model.accessibilityDescription)
    }
    
    private var statusColor: Color {
        if model.isSuccess {
            return Color.designStrong
        } else {
            return Color.designHighRisk
        }
    }
}
#endif
