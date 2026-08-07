//
//  DraftDeal.swift
//  PropertyDealRealityChecker
//
//  Stage 2 — Domain Model & Financial Value Types
//  Architectural Mandate: Draft Buffer pattern (ADR-004). UI edits DraftDeal rather than mutating saved objects.
//  Validation runs continuously without crashing on incomplete input.
//

import Foundation

/// Errors thrown when attempting to convert an invalid `DraftDeal` to a `CanonicalDeal`.
public enum DraftDealValidationError: Error, Sendable {
    case missingRequiredFields(issues: [ValidationIssue])
    case invalidNegativeValues(issues: [ValidationIssue])
}

/// An unconstrained, editable representation of a deal used by user interface input forms.
///
/// Implements the **Draft Buffer** pattern (ADR-004):
/// "The UI edits a `DraftDeal` value rather than mutating the saved object field-by-field.
/// Validation runs continuously but calculations execute only when minimum required inputs are valid."
public struct DraftDeal: Sendable, Codable, Hashable {
    public var id: UUID
    public var name: String
    public var address: String
    public var strategy: DealStrategy
    public var property: Property
    public var baseScenario: Scenario
    
    /// Initializes a draft deal buffer.
    public init(
        id: UUID = UUID(),
        name: String = "",
        address: String = "",
        strategy: DealStrategy = .longTermRental,
        property: Property = Property(),
        baseScenario: Scenario = Scenario(name: "Base Case", isBase: true)
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.strategy = strategy
        self.property = property
        self.baseScenario = baseScenario
    }
    
    /// Initializes a draft deal from an existing domain aggregate `Deal`.
    public init(from deal: Deal) {
        self.id = deal.id
        self.name = deal.name
        self.address = deal.address
        self.strategy = deal.strategy
        self.property = deal.property
        self.baseScenario = deal.activeScenario
    }
    
    /// Evaluates the current state of the draft buffer and returns all validation errors and warnings.
    public func validate() -> [ValidationIssue] {
        var issues: [ValidationIssue] = []
        
        // 1. Check deal name
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            issues.append(ValidationIssue(
                code: "VAL-001",
                severity: .warning,
                field: "name",
                message: "Deal name is blank. A default name will be assigned.",
                suggestedRemedy: "Enter a descriptive property name."
            ))
        }
        
        // 2. Check Purchase Price (> 0)
        let price = baseScenario.projectCost.purchasePrice.amount
        if price <= 0 {
            issues.append(ValidationIssue(
                code: "VAL-101",
                severity: .error,
                field: "purchasePrice",
                message: "Purchase price must be greater than zero.",
                suggestedRemedy: "Enter the contractual purchase price of the property."
            ))
        }
        
        // 3. Check Scheduled Rent (> 0)
        let totalRent = baseScenario.incomeLines.reduce(Decimal(0)) { $0 + $1.annualizedAmount.amount }
        if totalRent <= 0 {
            issues.append(ValidationIssue(
                code: "VAL-102",
                severity: .error,
                field: "incomeLines",
                message: "Total scheduled rental income must be greater than zero.",
                suggestedRemedy: "Add at least one monthly or annual rental income line."
            ))
        }
        
        // 4. Check Number of Units (1 to 20)
        if property.numberOfUnits < 1 || property.numberOfUnits > 20 {
            issues.append(ValidationIssue(
                code: "VAL-103",
                severity: .error,
                field: "numberOfUnits",
                message: "Number of units must be between 1 and 20 for residential small-investor underwriting.",
                suggestedRemedy: "Adjust the number of units to a value between 1 and 20."
            ))
        }
        
        // 5. Check Debt Layer invariants
        for layer in baseScenario.financingPlan.debtLayers {
            if layer.principal.amount < 0 {
                issues.append(ValidationIssue(
                    code: "VAL-201",
                    severity: .error,
                    field: "debtLayer.principal",
                    message: "Loan principal cannot be negative for '\(layer.name)'.",
                    suggestedRemedy: "Enter a positive principal amount or remove the loan layer."
                ))
            }
            if layer.interestRate.fraction < 0 {
                issues.append(ValidationIssue(
                    code: "VAL-202",
                    severity: .error,
                    field: "debtLayer.interestRate",
                    message: "Interest rate cannot be negative for '\(layer.name)'.",
                    suggestedRemedy: "Enter a non-negative interest rate."
                ))
            }
        }
        
        return issues
    }
    
    /// Returns true if the draft deal has zero blocking errors and is ready for calculation.
    public var canBecomeCanonical: Bool {
        !validate().contains { $0.severity == .error }
    }
    
    /// Converts this draft buffer into an immutable `CanonicalDeal` ready for deterministic calculation.
    /// - Throws: `DraftDealValidationError` if blocking validation errors are present.
    public func toCanonical() throws -> CanonicalDeal {
        let issues = validate()
        let errors = issues.filter { $0.severity == .error }
        guard errors.isEmpty else {
            throw DraftDealValidationError.missingRequiredFields(issues: errors)
        }
        
        let normalizedName = name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? "Untitled Property (\(property.propertyType.rawValue))"
            : name.trimmingCharacters(in: .whitespacesAndNewlines)
            
        return CanonicalDeal(
            id: id,
            name: normalizedName,
            address: address,
            strategy: strategy,
            property: property,
            scenario: baseScenario,
            validationIssues: issues
        )
    }
}
