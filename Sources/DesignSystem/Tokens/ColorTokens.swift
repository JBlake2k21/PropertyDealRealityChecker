//
//  ColorTokens.swift
//  PropertyDealRealityChecker
//
//  Stage 5 — Shared Design System, Theme Engine & Typography
//  Architectural Mandate: Semantic color tokens and verdict category status colors.
//  Zero domain dependencies.
//

import Foundation
#if canImport(SwiftUI)
import SwiftUI
#endif

/// Platform-independent RGB color representation for semantic design tokens.
public struct RGBColor: Sendable, Hashable, Codable {
    public let red: Double
    public let green: Double
    public let blue: Double
    public let alpha: Double
    
    public init(red: Double, green: Double, blue: Double, alpha: Double = 1.0) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
}

/// Core semantic color tokens for the Property Deal Reality Checker design system.
///
/// Implements Blueprint Section 11 ("Design System, Typography, and Accessibility Mandates"):
/// Provides curated, accessible color palettes for financial metrics, risk status, and verdict classification.
public struct ColorTokens: Sendable {
    // MARK: - Verdict Status Colors
    
    /// Emerald Green (`#10B981`) — Used for **Strong** profitability category and passing thresholds.
    public static let strong = RGBColor(red: 0.063, green: 0.725, blue: 0.506)
    
    /// Blue Indigo (`#3B82F6`) — Used for **Workable** profitability category and standard metrics.
    public static let workable = RGBColor(red: 0.231, green: 0.510, blue: 0.965)
    
    /// Amber Orange (`#F59E0B`) — Used for **Marginal** profitability category and warning alerts.
    public static let marginal = RGBColor(red: 0.961, green: 0.620, blue: 0.043)
    
    /// Rose Red (`#EF4444`) — Used for **High Risk** profitability category and failing thresholds.
    public static let highRisk = RGBColor(red: 0.937, green: 0.267, blue: 0.267)
    
    // MARK: - Core UI Tokens
    
    /// Slate 900 (`#0F172A`) — Primary dark background or high-contrast foreground.
    public static let textPrimary = RGBColor(red: 0.059, green: 0.090, blue: 0.165)
    
    /// Slate 500 (`#64748B`) — Secondary subtitle or muted text.
    public static let textSecondary = RGBColor(red: 0.392, green: 0.455, blue: 0.545)
    
    /// Card Surface Background (`#F8FAFC`).
    public static let surface = RGBColor(red: 0.973, green: 0.980, blue: 0.988)
    
    /// Card Border Color (`#E2E8F0`).
    public static let border = RGBColor(red: 0.886, green: 0.910, blue: 0.941)
}

#if canImport(SwiftUI)
public extension Color {
    static let designStrong = Color(red: ColorTokens.strong.red, green: ColorTokens.strong.green, blue: ColorTokens.strong.blue)
    static let designWorkable = Color(red: ColorTokens.workable.red, green: ColorTokens.workable.green, blue: ColorTokens.workable.blue)
    static let designMarginal = Color(red: ColorTokens.marginal.red, green: ColorTokens.marginal.green, blue: ColorTokens.marginal.blue)
    static let designHighRisk = Color(red: ColorTokens.highRisk.red, green: ColorTokens.highRisk.green, blue: ColorTokens.highRisk.blue)
    static let designTextPrimary = Color(red: ColorTokens.textPrimary.red, green: ColorTokens.textPrimary.green, blue: ColorTokens.textPrimary.blue)
    static let designTextSecondary = Color(red: ColorTokens.textSecondary.red, green: ColorTokens.textSecondary.green, blue: ColorTokens.textSecondary.blue)
    static let designSurface = Color(red: ColorTokens.surface.red, green: ColorTokens.surface.green, blue: ColorTokens.surface.blue)
    static let designBorder = Color(red: ColorTokens.border.red, green: ColorTokens.border.green, blue: ColorTokens.border.blue)
}
#endif
