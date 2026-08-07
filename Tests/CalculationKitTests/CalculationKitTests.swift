//
//  CalculationKitTests.swift
//  PropertyDealRealityCheckerTests
//
//  Stage 1 Scaffolding — CalculationKit Unit Tests
//

import Foundation
import CalculationKit

#if canImport(Testing)
import Testing

@Test("Verify CalculationKit engine version marker")
func testCalculationKitEngineVersion() {
    #expect(CalculationKitModule.engineVersion == "1.0.0")
}
#endif
