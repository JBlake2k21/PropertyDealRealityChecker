//
//  VerdictBadgeView.swift
//  PropertyDealRealityChecker
//
//  Stage 5 — Shared Design System, Theme Engine & Component Library
//  Architectural Mandate: Styled capsule badge displaying Verdict Category with accessibility traits.
//

import Foundation
#if canImport(SwiftUI)
import SwiftUI
#endif

/// Data model and accessibility descriptor for a `VerdictBadgeView`.
public struct VerdictBadgeModel: Sendable, Hashable, Codable {
    public let categoryName: String
    
    public init(categoryName: String) {
        self.categoryName = categoryName
    }
    
    /// Complete VoiceOver accessibility label for screen readers.
    public var accessibilityDescription: String {
        "Verdict Category: \(categoryName)"
    }
}

#if canImport(SwiftUI)
/// A capsule-styled status badge displaying the underwriting profitability verdict category.
public struct VerdictBadgeView: View {
    public let model: VerdictBadgeModel
    
    public init(model: VerdictBadgeModel) {
        self.model = model
    }
    
    public var body: some View {
        Text(model.categoryName.uppercased())
            .font(.designCaption)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(badgeColor.opacity(0.15))
            .foregroundColor(badgeColor)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(badgeColor, lineWidth: 1)
            )
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(model.accessibilityDescription)
    }
    
    private var badgeColor: Color {
        let rgb = ThemeEngine.verdictColor(forCategoryRawValue: model.categoryName)
        return Color(red: rgb.red, green: rgb.green, blue: rgb.blue)
    }
}
#endif
