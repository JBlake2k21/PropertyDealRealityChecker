//
//  RealityCheckerAppTests.swift
//  PropertyDealRealityCheckerTests
//
//  Stage 1 Scaffolding — RealityCheckerApp Unit Tests
//

import Foundation
import RealityCheckerApp
import TestFixtures

#if canImport(Testing)
import Testing

@Test("Verify RealityCheckerApp dependency container versions")
func testRealityCheckerAppVersionBinding() {
    #expect(RealityCheckerAppModule.appVersion == "1.0.0")
    #expect(RealityCheckerAppModule.activeEngineVersion == "1.0.0")
    #expect(RealityCheckerAppModule.activeRuleSetVersion == "Rental-US-1.0")
}
#endif
