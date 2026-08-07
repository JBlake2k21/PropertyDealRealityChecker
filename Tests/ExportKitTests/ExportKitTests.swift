//
//  ExportKitTests.swift
//  PropertyDealRealityCheckerTests
//
//  Stage 1 Scaffolding — ExportKit Unit Tests
//

import Foundation
import ExportKit
import DealCore

#if canImport(Testing)
import Testing

@Test("Verify ExportKit generator version and DealCore binding")
func testExportKitVersionBinding() {
    #expect(ExportKitModule.generatorVersion == "1.0.0")
    #expect(ExportKitModule.activeEngineVersion == "1.0.0")
}
#endif
