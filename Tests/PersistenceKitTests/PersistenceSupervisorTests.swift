//
//  PersistenceSupervisorTests.swift
//  PropertyDealRealityCheckerTests
//
//  Stage 4 — PersistenceSupervisor Migration & Health Unit Tests
//

import Foundation
import PersistenceKit

#if canImport(Testing)
import Testing

@Test("Verify SchemaVersion initial version and ordering")
func testSchemaVersion() {
    #expect(SchemaVersion.current == .v1_0_0)
    #expect(SchemaVersion.current.rawValue == "v1.0.0")
}

@Test("Verify PersistenceSupervisor health check without crashing")
func testPersistenceSupervisorHealthCheck() {
    let status = PersistenceSupervisor.checkAndRecoverStoreHealth()
    #expect(status == .healthy || status == .recoveredFromCorruption)
}
#endif
