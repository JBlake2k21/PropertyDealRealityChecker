//
//  PersistenceKit.swift
//  PropertyDealRealityChecker
//
//  Stage 1 Scaffolding — PersistenceKit Module Marker
//  Architectural Mandate: SwiftData persistence layer, repository protocol abstractions, and migrations.
//  May import ONLY SwiftData and DealCore. Must NEVER import UI frameworks or formula implementations.
//

import Foundation
import DealCore
#if canImport(SwiftData)
import SwiftData
#endif

/// The `PersistenceKit` module namespace and schema version marker.
///
/// Encapsulates SwiftData `@Model` classes, `DealRepositoryProtocol`, and schema migration plans.
public struct PersistenceKitModule: Sendable {
    /// Identifies the persistent schema version.
    public static let schemaVersion: String = "1.0.0"
    
    /// Initializes the PersistenceKit module marker.
    public init() {}
    
    /// Returns the active domain rule-set version from `DealCore`.
    public static var activeRuleSetVersion: String {
        DealCoreModule.ruleSetVersion
    }
}
