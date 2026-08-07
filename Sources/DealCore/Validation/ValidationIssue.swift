//
//  ValidationIssue.swift
//  PropertyDealRealityChecker
//
//  Stage 2 — Domain Model & Financial Value Types
//  Architectural Mandate: Continuous validation feedback without crashing on incomplete input.
//

import Foundation

/// Identifies the severity of a validation issue.
public enum ValidationSeverity: String, Sendable, Codable, Hashable {
    /// Blocking error: minimum required inputs are missing or mathematically invalid (e.g., negative purchase price).
    case error
    /// Informational warning: assumption relies on an unverified default or falls outside typical market norms.
    case warning
}

/// A structured validation finding generated when inspecting a `DraftDeal` or scenario.
public struct ValidationIssue: Sendable, Codable, Hashable, Identifiable {
    /// Unique identifier for this finding.
    public let id: UUID
    
    /// Unique error or warning code (e.g., `"VAL-001"`).
    public let code: String
    
    /// Severity classification (`error` blocks calculation; `warning` reduces confidence).
    public let severity: ValidationSeverity
    
    /// The name of the property or assumption field responsible for the finding.
    public let field: String
    
    /// Plain-language description of the issue.
    public let message: String
    
    /// Optional actionable guidance for resolving the issue.
    public let suggestedRemedy: String?
    
    /// Initializes a validation issue.
    public init(
        id: UUID = UUID(),
        code: String,
        severity: ValidationSeverity,
        field: String,
        message: String,
        suggestedRemedy: String? = nil
    ) {
        self.id = id
        self.code = code
        self.severity = severity
        self.field = field
        self.message = message
        self.suggestedRemedy = suggestedRemedy
    }
}
