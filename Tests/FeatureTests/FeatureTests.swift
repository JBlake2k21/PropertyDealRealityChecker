//
//  FeatureTests.swift
//  PropertyDealRealityCheckerTests
//
//  Stage 1 Scaffolding — Feature Modules Unit Tests
//

import Foundation
import FeatureDealEntry
import FeatureDashboard
import FeatureScenarios

#if canImport(Testing)
import Testing

@Test("Verify feature module versions")
func testFeatureModuleVersions() {
    #expect(FeatureDealEntryModule.version == "1.0.0")
    #expect(FeatureDashboardModule.version == "1.0.0")
    #expect(FeatureScenariosModule.version == "1.0.0")
}
#endif
