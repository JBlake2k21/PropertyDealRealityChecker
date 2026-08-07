//
//  ExportKit.swift
//  PropertyDealRealityChecker
//
//  Stage 1 Scaffolding — ExportKit Module Marker
//  Architectural Mandate: Branded PDF summary reports and CSV data encoders.
//  Must consume ONLY immutable CalculationSnapshot values from DealCore.
//

import Foundation
import DealCore

/// The `ExportKit` module namespace and export engine marker.
///
/// Converts immutable `CalculationSnapshot` structs into shareable PDF and CSV documents.
public struct ExportKitModule: Sendable {
    /// Identifies the export generator version.
    public static let generatorVersion: String = "1.0.0"
    
    /// Initializes the ExportKit module marker.
    public init() {}
    
    /// Verifies that ExportKit is bound to the active calculation engine version in DealCore.
    public static var activeEngineVersion: String {
        DealCoreModule.engineVersion
    }
}
