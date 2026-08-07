//
//  CurrencyTextFieldView.swift
//  PropertyDealRealityChecker
//
//  Stage 5 — Shared Design System, Theme Engine & Component Library
//  Architectural Mandate: Accessible currency text field with monospaced financial digit alignment.
//

import Foundation
#if canImport(SwiftUI)
import SwiftUI
#endif

/// Data model and accessibility descriptor for a `CurrencyTextFieldView`.
public struct CurrencyTextFieldModel: Sendable, Hashable, Codable {
    public let label: String
    public let placeholder: String
    public let currencyCode: String
    
    public init(
        label: String,
        placeholder: String = "$0",
        currencyCode: String = "USD"
    ) {
        self.label = label
        self.placeholder = placeholder
        self.currencyCode = currencyCode
    }
    
    /// Complete VoiceOver accessibility label for screen readers.
    public var accessibilityDescription: String {
        "\(label), Currency input in \(currencyCode)"
    }
}

#if canImport(SwiftUI)
/// A styled, accessible currency text field with tabular financial number alignment.
public struct CurrencyTextFieldView: View {
    public let model: CurrencyTextFieldModel
    @Binding public var text: String
    
    public init(model: CurrencyTextFieldModel, text: Binding<String>) {
        self.model = model
        self._text = text
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(model.label)
                .font(.designBodyMedium)
                .foregroundColor(.designTextSecondary)
            
            TextField(model.placeholder, text: $text)
                .font(.designFinancialMonospaced)
                .foregroundColor(.designTextPrimary)
                .keyboardType(.decimalPad)
                .padding()
                .background(Color.designSurface)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.designBorder, lineWidth: 1)
                )
                .accessibilityLabel(model.accessibilityDescription)
                .accessibilityHint("Enter numeric amount without currency symbols")
        }
    }
}
#endif
