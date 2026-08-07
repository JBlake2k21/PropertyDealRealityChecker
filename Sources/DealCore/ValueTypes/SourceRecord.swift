//
//  SourceRecord.swift
//  PropertyDealRealityChecker
//
//  Stage 2 — Financial Value Types
//  Architectural Mandate: Evidence metadata tracking source provenance without storing raw documents by default.
//

import Foundation

/// Identifies the provenance and verification status of a financial assumption.
public enum SourceType: String, Sendable, Codable, Hashable {
    /// Entered manually by the investor without external citation.
    case manual
    /// Copied from a publicly advertised property listing or MLS description.
    case listing
    /// Extracted or transcribed from an audited closing package, lease, or tax bill.
    case document
    /// Proactive placeholder or market-default estimate applied with user consent.
    case estimate
    /// Verified against historical operating statements or official records.
    case verified
}

/// Metadata describing the evidence supporting an assumption or input line.
public struct SourceRecord: Sendable, Codable, Hashable {
    /// The provenance classification of the assumption.
    public let sourceType: SourceType
    
    /// The date the evidence was observed or recorded.
    public let observedDate: Date
    
    /// The derived confidence level of this source record.
    public let confidenceLevel: ConfidenceLevel
    
    /// Optional user or system note explaining the assumption's origin.
    public let note: String?
    
    /// Initializes an evidence source record.
    public init(
        sourceType: SourceType,
        observedDate: Date = Date(),
        confidenceLevel: ConfidenceLevel? = nil,
        note: String? = nil
    ) {
        self.sourceType = sourceType
        self.observedDate = observedDate
        self.note = note
        
        if let confidenceLevel = confidenceLevel {
            self.confidenceLevel = confidenceLevel
        } else {
            switch sourceType {
            case .verified, .document:
                self.confidenceLevel = .high
            case .listing:
                self.confidenceLevel = .medium
            case .manual:
                self.confidenceLevel = .low
            case .estimate:
                self.confidenceLevel = .low
            }
        }
    }
    
    /// Standard default manual source record for new user inputs.
    public static let defaultManual = SourceRecord(sourceType: .manual, confidenceLevel: .low)
    
    /// Standard unverified placeholder estimate source record.
    public static let estimatePlaceholder = SourceRecord(sourceType: .estimate, confidenceLevel: .low, note: "Unverified market estimate applied with consent")
}
