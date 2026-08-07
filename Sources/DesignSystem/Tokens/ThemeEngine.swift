//
//  ThemeEngine.swift
//  PropertyDealRealityChecker
//
//  Stage 5 — Shared Design System, Theme Engine & Typography
//  Architectural Mandate: Central theme management and appearance mode switching.
//

import Foundation

/// Appearance mode options supported by the application.
public enum AppearanceMode: String, Sendable, Codable, CaseIterable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
}

/// Central theme engine managing appearance modes and semantic token lookups.
public struct ThemeEngine: Sendable {
    /// Returns the semantic color token corresponding to a verdict category string.
    ///
    /// Keeps `DesignSystem` 100% decoupled from `DealCore` domain types.
    /// - Parameter categoryRawValue: Lowercase or display string of the category (e.g., `"strong"`, `"highRisk"`).
    /// - Returns: Corresponding `RGBColor` status token.
    public static func verdictColor(forCategoryRawValue categoryRawValue: String) -> RGBColor {
        let normalized = categoryRawValue.lowercased().replacingOccurrences(of: " ", with: "")
        switch normalized {
        case "strong":
            return ColorTokens.strong
        case "workable":
            return ColorTokens.workable
        case "marginal":
            return ColorTokens.marginal
        case "highrisk", "high_risk", "high-risk":
            return ColorTokens.highRisk
        default:
            return ColorTokens.workable
        }
    }
}
