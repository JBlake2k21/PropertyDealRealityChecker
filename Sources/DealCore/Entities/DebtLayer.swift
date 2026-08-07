//
//  DebtLayer.swift
//  PropertyDealRealityChecker
//
//  Stage 2 — Domain Model & Financial Value Types
//  Architectural Mandate: Multi-tier financing support (first mortgage, seller finance, second lien).
//

import Foundation

/// Identifies the structural financing type of a debt layer.
public enum FinancingType: String, Sendable, Codable, Hashable, CaseIterable {
    /// Fully amortizing fixed or adjustable rate loan.
    case amortizing = "Fully Amortizing"
    /// Interest-only loan (no principal reduction during I/O period).
    case interestOnly = "Interest-Only"
    /// Amortizing or interest-only loan with a lump-sum balloon payment at contractual maturity.
    case balloon = "Balloon Mortgage"
    /// Seller financing or private mortgage note.
    case sellerFinance = "Seller Financing"
    /// Subordinate second lien, mezzanine, or HELOC.
    case subordinate = "Subordinate / Second Lien"
}

/// Governs how debt service payments are collected or accrued.
public enum PaymentRule: String, Sendable, Codable, Hashable {
    /// Payments are due monthly.
    case monthlyPaid = "Monthly Paid"
    /// Payments are deferred for a specified period.
    case deferred = "Deferred"
    /// Interest accrues and is paid at maturity.
    case accruedToMaturity = "Accrued to Maturity"
}

/// Represents an individual loan or debt layer within a financing plan.
public struct DebtLayer: Sendable, Codable, Hashable, Identifiable {
    /// Unique identifier for this debt layer.
    public let id: UUID
    
    /// User-friendly label (e.g., `"First Mortgage"`, `"Seller Second Lien"`).
    public var name: String
    
    /// The structural financing type.
    public var financingType: FinancingType
    
    /// Lien priority position (`1` for first mortgage, `2` for second lien, etc.).
    public var lienPosition: Int
    
    /// Original loan principal amount.
    public var principal: CurrencyAmount
    
    /// Contractual annual interest rate fraction (`0.07` for 7%).
    public var interestRate: Rate
    
    /// Total amortization schedule length in months (`360` for 30 years).
    public var amortizationMonths: Int
    
    /// Contractual loan maturity term in months (`60` for a 5-year balloon).
    public var contractualTermMonths: Int
    
    /// Payment collection rule.
    public var paymentRule: PaymentRule
    
    /// Optional number of interest-only months at loan start.
    public var interestOnlyMonths: Int?
    
    /// Upfront lender fees or origination points.
    public var fees: CurrencyAmount
    
    /// Initializes a debt layer entity.
    public init(
        id: UUID = UUID(),
        name: String = "First Mortgage",
        financingType: FinancingType = .amortizing,
        lienPosition: Int = 1,
        principal: CurrencyAmount,
        interestRate: Rate,
        amortizationMonths: Int = 360,
        contractualTermMonths: Int = 360,
        paymentRule: PaymentRule = .monthlyPaid,
        interestOnlyMonths: Int? = nil,
        fees: CurrencyAmount = .zero
    ) {
        self.id = id
        self.name = name
        self.financingType = financingType
        self.lienPosition = max(1, lienPosition)
        self.principal = principal
        self.interestRate = interestRate
        self.amortizationMonths = max(1, amortizationMonths)
        self.contractualTermMonths = max(1, contractualTermMonths)
        self.paymentRule = paymentRule
        self.interestOnlyMonths = interestOnlyMonths
        self.fees = fees
    }
    
    /// Returns whether this debt layer has a balloon maturity before full amortization.
    public var hasBalloon: Bool {
        financingType == .balloon || contractualTermMonths < amortizationMonths
    }
}
