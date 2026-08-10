//
//  ExplanationEngine.swift
//  PropertyDealRealityChecker
//
//  Stage 7 — Explanation & Reports
//  Architectural Mandate: Plain-language deterministic explanation generator.
//

import Foundation
import DealCore

/// A stateless service that translates `Verdict` and `ReasonCode` arrays into human-readable text.
public struct ExplanationEngine: Sendable {
    
    public init() {}
    
    /// Generates an executive summary based on the verdict category and confidence level.
    public func generateExecutiveSummary(for verdict: Verdict) -> String {
        let confidenceText = text(for: verdict.confidence)
        
        switch verdict.category {
        case .strong:
            return "This deal is classified as a Strong Deal. It meets or exceeds the required safety and return thresholds. The data supporting this evaluation has a \(confidenceText) confidence level."
        case .workable:
            return "This deal is Workable. It meets primary targets but may have marginal performance in some areas. The data supporting this evaluation has a \(confidenceText) confidence level."
        case .marginal:
            return "This deal is Marginal. It fails to meet one or more primary targets or shows vulnerability to stress. Proceed with caution. The data supporting this evaluation has a \(confidenceText) confidence level."
        case .highRisk:
            return "This deal is High Risk or Speculative. It severely underperforms or fails critical safety checks. The data supporting this evaluation has a \(confidenceText) confidence level."
        case .incomplete:
            return "This deal evaluation is Incomplete or Unverified. Please provide missing critical inputs to generate a full verdict."
        }
    }
    
    /// Generates a bulleted plain-text explanation of the reasons a deal passed or failed.
    public func generateDetailedExplanation(for verdict: Verdict) -> String {
        var explanation = "Detailed Explanation:\n"
        
        let failing = verdict.failingReasons
        let passing = verdict.passingReasons
        
        if !failing.isEmpty {
            explanation += "\nAreas of Concern:\n"
            for reason in failing {
                explanation += "- \(reason.metricName): \(reason.plainLanguageExplanation)\n"
            }
        }
        
        if !passing.isEmpty {
            explanation += "\nStrengths:\n"
            for reason in passing {
                explanation += "- \(reason.metricName): \(reason.plainLanguageExplanation)\n"
            }
        }
        
        return explanation
    }
    
    private func text(for confidence: ConfidenceLevel) -> String {
        switch confidence {
        case .high:
            return "High"
        case .medium:
            return "Medium"
        case .low:
            return "Low"
        case .unverified:
            return "Unverified"
        }
    }
}
