//
//  DealCoreTests.swift
//  PropertyDealRealityCheckerTests
//
//  Stage 1 Scaffolding — DealCore Unit Tests
//

import Foundation
import DealCore

#if canImport(Testing)
import Testing

@Test("Verify DealCore rule-set and calculation engine version binding")
func testDealCoreVersionMarkers() {
    #expect(DealCoreModule.ruleSetVersion == "Rental-US-1.0")
    #expect(DealCoreModule.engineVersion == "1.0.0")
}
#endif
