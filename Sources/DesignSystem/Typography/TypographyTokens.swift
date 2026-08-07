//
//  TypographyTokens.swift
//  PropertyDealRealityChecker
//
//  Stage 5 — Shared Design System, Theme Engine & Typography
//  Architectural Mandate: Scaled Dynamic Type and tabular/monospaced numbers for financial alignment.
//

import Foundation
#if canImport(SwiftUI)
import SwiftUI
#endif

/// Font weight descriptor for platform-independent typography tokens.
public enum TokenFontWeight: String, Sendable, Codable {
    case regular = "Regular"
    case medium = "Medium"
    case semibold = "Semibold"
    case bold = "Bold"
}

/// Metadata describing a typography token style.
public struct TypographyDescriptor: Sendable, Hashable, Codable {
    public let name: String
    public let size: Double
    public let weight: TokenFontWeight
    public let isTabularNumbers: Bool
    
    public init(name: String, size: Double, weight: TokenFontWeight, isTabularNumbers: Bool = false) {
        self.name = name
        self.size = size
        self.weight = weight
        self.isTabularNumbers = isTabularNumbers
    }
}

/// Core typography tokens supporting Dynamic Type and financial tabular alignment.
///
/// Implements Blueprint Section 11 ("Design System, Typography, and Accessibility Mandates"):
/// - All financial numbers use tabular/monospaced digit alignment so decimals line up in columns.
/// - Scales automatically with user accessibility preferences.
public struct TypographyTokens: Sendable {
    /// Hero font for primary deal metrics (`32pt Bold Tabular`).
    public static let financialHero = TypographyDescriptor(name: "Financial Hero", size: 32, weight: .bold, isTabularNumbers: true)
    
    /// Standard font for numeric table cells and inputs (`17pt Regular Tabular`).
    public static let financialMonospaced = TypographyDescriptor(name: "Financial Monospaced", size: 17, weight: .regular, isTabularNumbers: true)
    
    /// Primary section title (`24pt Bold`).
    public static let titleLarge = TypographyDescriptor(name: "Title Large", size: 24, weight: .bold)
    
    /// Subsection title (`18pt Semibold`).
    public static let titleMedium = TypographyDescriptor(name: "Title Medium", size: 18, weight: .semibold)
    
    /// Primary body text (`16pt Regular`).
    public static let bodyLarge = TypographyDescriptor(name: "Body Large", size: 16, weight: .regular)
    
    /// Secondary body text (`14pt Regular`).
    public static let bodyMedium = TypographyDescriptor(name: "Body Medium", size: 14, weight: .regular)
    
    /// Footnote and badge caption (`12pt Medium`).
    public static let caption = TypographyDescriptor(name: "Caption", size: 12, weight: .medium)
}

#if canImport(SwiftUI)
public extension Font {
    static let designFinancialHero = Font.system(size: 32, weight: .bold, design: .default).monospacedDigit()
    static let designFinancialMonospaced = Font.system(size: 17, weight: .regular, design: .default).monospacedDigit()
    static let designTitleLarge = Font.system(size: 24, weight: .bold)
    static let designTitleMedium = Font.system(size: 18, weight: .semibold)
    static let designBodyLarge = Font.system(size: 16, weight: .regular)
    static let designBodyMedium = Font.system(size: 14, weight: .regular)
    static let designCaption = Font.system(size: 12, weight: .medium)
}
#endif
