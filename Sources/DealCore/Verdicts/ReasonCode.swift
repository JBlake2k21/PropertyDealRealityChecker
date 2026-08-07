//
//  ReasonCode.swift
//  PropertyDealRealityChecker
//
//  Stage 2 — Domain Model & Financial Value Types
//  Architectural Mandate: Structured reason code explaining why a metric passed or failed a threshold.
//

import Foundation

/// A structured reason code explaining why an evaluation metric passed or failed an investor threshold.
///
/// Implements Blueprint Section 4.3 ("Structured Reason Codes"):
/// Every verdict is accompanied by a list of reason codes containing metric name, actual value,
/// target threshold, success flag, corrective delta, and plain-language explanation.
public struct ReasonCode: Sendable, Codable, Hashable, Identifiable {
    /// Unique identifier for this reason code instance.
    public let id: UUID
    
    /// Canonical rule code (e.g., `"DSCR-001"`, `"COC-002"`, `"LTV-001"`).
    public let code: String
    
    /// User-facing metric name (e.g., `"Debt Service Coverage Ratio (DSCR)"`).
    public let metricName: String
    
    /// Formatted presentation string of the actual calculated value (e.g., `"1.18x"`).
    public let actualValue: String
    
    /// Formatted presentation string of the target threshold (e.g., `"1.25x"`).
    public let thresholdValue: String
    
    /// Whether the actual value satisfied the safety or return threshold.
    public let isSuccess: Bool
    
    /// Optional formatted delta showing what adjustment would be needed to meet the target (e.g., `"- $15,000 Purchase Price"`).
    public let correctiveDelta: String?
    
    /// Plain-language explanation suitable for display on cards or in PDF reports.
    public let plainLanguageExplanation: String
    
    /// Initializes a structured reason code.
    public init(
        id: UUID = UUID(),
        code: String,
        metricName: String,
        actualValue: String,
        thresholdValue: String,
        isSuccess: Bool,
        correctiveDelta: String? = nil,
        plainLanguageExplanation: String
    ) {
        self.id = id
        self.code = code
        self.metricName = metricName
        self.actualValue = actualValue
        self.thresholdValue = thresholdValue
        self.isSuccess = isSuccess
        self.correctiveDelta = correctiveDelta
        self.plainLanguageExplanation = plainLanguageExplanation
    }
}
