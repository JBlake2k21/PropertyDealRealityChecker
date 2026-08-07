//
//  PersistenceKitTests.swift
//  PropertyDealRealityCheckerTests
//
//  Stage 1 Scaffolding — PersistenceKit Unit Tests
//

import Foundation
import PersistenceKit
import DealCore

#if canImport(Testing)
import Testing

@Test("Verify PersistenceKit schema version and DealCore binding")
func testPersistenceKitVersionBinding() {
    #expect(PersistenceKitModule.schemaVersion == "1.0.0")
    #expect(PersistenceKitModule.activeRuleSetVersion == "Rental-US-1.0")
}
#endif
