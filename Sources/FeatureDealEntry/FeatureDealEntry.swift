//
//  FeatureDealEntry.swift
//  PropertyDealRealityChecker
//
//  Stage 1 Scaffolding — FeatureDealEntry Module Marker
//  Architectural Mandate: Guided input workflows, edit buffers (`DraftDeal`), and field components.
//  Imports DealCore and DesignSystem.
//

import Foundation
import DealCore
import DesignSystem
#if canImport(SwiftUI)
import SwiftUI
#endif

/// The `FeatureDealEntry` module namespace and workflow marker.
public struct FeatureDealEntryModule: Sendable {
    /// Identifies the deal intake feature module version.
    public static let version: String = "1.0.0"
    
    /// Initializes the FeatureDealEntry module marker.
    public init() {}
}
