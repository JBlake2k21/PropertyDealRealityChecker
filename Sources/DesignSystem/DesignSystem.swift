//
//  DesignSystem.swift
//  PropertyDealRealityChecker
//
//  Stage 1 Scaffolding — DesignSystem Module Marker
//  Architectural Mandate: Shared UI tokens, typography, colors, accessible cards, and VoiceOver helpers.
//  No domain or calculation dependencies.
//

import Foundation
#if canImport(SwiftUI)
import SwiftUI
#endif

/// The `DesignSystem` module namespace and accessibility marker.
public struct DesignSystemModule: Sendable {
    /// Identifies the design system version.
    public static let version: String = "1.0.0"
    
    /// Initializes the DesignSystem module marker.
    public init() {}
}
