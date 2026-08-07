//
//  MarkdownRenderer.swift
//  PropertyDealRealityChecker
//
//  Stage 7 — Explanation & Reports
//  Architectural Mandate: Markdown document generation for verdicts.
//

import Foundation
import DealCore

/// Renders a `Verdict` and `CalculationSnapshot` into a structured Markdown document.
public struct MarkdownRenderer: Sendable {
    
    private let engine = ExplanationEngine()
    
    public init() {}
    
    /// Renders a full markdown document for the given verdict.
    public func renderMarkdown(for verdict: Verdict) -> String {
        var markdown = "# Deal Evaluation Verdict\n\n"
        
        // Category Header
        markdown += "## \(verdict.category.rawValue)\n\n"
        
        // Executive Summary
        markdown += engine.generateExecutiveSummary(for: verdict) + "\n\n"
        
        // Reason Codes
        let failing = verdict.failingReasons
        let passing = verdict.passingReasons
        
        if !failing.isEmpty {
            markdown += "### Areas of Concern\n\n"
            for reason in failing {
                markdown += "- **\(reason.metricName)** (Failed): \(reason.plainLanguageExplanation)\n"
                markdown += "  - Actual: `\(reason.actualValue)` | Target: `\(reason.thresholdValue)`\n"
                if let delta = reason.correctiveDelta {
                    markdown += "  - Correction: *\(delta)*\n"
                }
            }
            markdown += "\n"
        }
        
        if !passing.isEmpty {
            markdown += "### Strengths\n\n"
            for reason in passing {
                markdown += "- **\(reason.metricName)** (Passed): \(reason.plainLanguageExplanation)\n"
                markdown += "  - Actual: `\(reason.actualValue)` | Target: `\(reason.thresholdValue)`\n"
            }
            markdown += "\n"
        }
        
        return markdown
    }
}
