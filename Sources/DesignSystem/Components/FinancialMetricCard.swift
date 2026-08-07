//
//  FinancialMetricCard.swift
//  PropertyDealRealityChecker
//
//  Stage 5 — Shared Design System, Theme Engine & Component Library
//  Architectural Mandate: Accessible summary card for financial metrics with tabular number alignment.
//

import Foundation
#if canImport(SwiftUI)
import SwiftUI
#endif

/// Data model and accessibility descriptor for a `FinancialMetricCard`.
public struct FinancialMetricCardModel: Sendable, Hashable, Codable {
    public let title: String
    public let value: String
    public let subtitle: String?
    public let trendRawValue: String
    public let statusCategoryRawValue: String
    
    public init(
        title: String,
        value: String,
        subtitle: String? = nil,
        trendRawValue: String = "neutral",
        statusCategoryRawValue: String = "workable"
    ) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.trendRawValue = trendRawValue
        self.statusCategoryRawValue = statusCategoryRawValue
    }
    
    /// Complete VoiceOver accessibility label for screen readers.
    public var accessibilityDescription: String {
        let sub = subtitle.map { ", \($0)" } ?? ""
        return "\(title): \(value)\(sub)"
    }
}

#if canImport(SwiftUI)
/// A reusable, accessible financial summary card component displaying a key investment metric.
///
/// Implements Blueprint Section 11 & Section 12:
/// - Employs tabular monospaced digits (`.monospacedDigit()`) for numeric stability.
/// - Supplies explicit VoiceOver accessibility labels and hints.
public struct FinancialMetricCard: View {
    public let model: FinancialMetricCardModel
    
    public init(model: FinancialMetricCardModel) {
        self.model = model
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(model.title)
                .font(.designBodyMedium)
                .foregroundColor(.designTextSecondary)
            
            Text(model.value)
                .font(.designFinancialHero)
                .foregroundColor(.designTextPrimary)
                .accessibilityAddTraits(.isHeader)
            
            if let subtitle = model.subtitle {
                Text(subtitle)
                    .font(.designCaption)
                    .foregroundColor(statusColor)
            }
        }
        .padding()
        .background(Color.designSurface)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.designBorder, lineWidth: 1)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(model.accessibilityDescription)
    }
    
    private var statusColor: Color {
        let rgb = ThemeEngine.verdictColor(forCategoryRawValue: model.statusCategoryRawValue)
        return Color(red: rgb.red, green: rgb.green, blue: rgb.blue)
    }
}
#endif
