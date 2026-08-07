//
//  SchemaVersion.swift
//  PropertyDealRealityChecker
//
//  Stage 4 — Persistence, Offline-First Repository & Migration Layer
//  Architectural Mandate: Versioned persistence schema tracking for migration plans.
//

import Foundation

/// Identifies the schema version of the local database.
///
/// Implements Blueprint Section 9 ("Data Migration and Versioning"):
/// Supports staged lightweight migrations and quarantine recovery if schema corruption is detected.
public enum SchemaVersion: String, Sendable, Codable, CaseIterable, Comparable {
    /// Initial MVP release schema (`v1.0.0`).
    case v1_0_0 = "v1.0.0"
    
    /// Compares two schema versions for migration ordering.
    public static func < (lhs: SchemaVersion, rhs: SchemaVersion) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    
    /// The current active schema version of the application.
    public static let current: SchemaVersion = .v1_0_0
}
