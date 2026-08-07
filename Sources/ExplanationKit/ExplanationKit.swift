//
//  ExplanationKit.swift
//  PropertyDealRealityChecker
//
//  Stage 1 Scaffolding — ExplanationKit Module Marker
//  Architectural Mandate: Plain-language deterministic explanation templates and structured reason renderer.
//  May import ONLY Foundation and DealCore. Must NEVER mutate deal state or perform calculations.
//

import Foundation
import DealCore

/// The `ExplanationKit` module namespace and template engine marker.
///
/// Converts structured reason codes from `DealCore` into clear, deterministic explanations.
/// Future Apple Foundation Models integration is isolated behind availability checks (`#available(iOS 26.0, *)`).
public struct ExplanationKitModule: Sendable {
    /// Identifies the explanation template version.
    public static let templateVersion: String = "1.0.0"
    
    /// Initializes the ExplanationKit module marker.
    public init() {}
    
    /// Verifies that ExplanationKit is bound to the correct rule-set version in DealCore.
    public static var activeRuleSetVersion: String {
        DealCoreModule.ruleSetVersion
    }
}
