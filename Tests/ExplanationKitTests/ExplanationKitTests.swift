//
//  ExplanationKitTests.swift
//  PropertyDealRealityCheckerTests
//
//  Stage 1 Scaffolding — ExplanationKit Unit Tests
//

import Foundation
import ExplanationKit
import DealCore

#if canImport(Testing)
import Testing

@Test("Verify ExplanationKit template version and rule-set binding")
func testExplanationKitVersionBinding() {
    #expect(ExplanationKitModule.templateVersion == "1.0.0")
    #expect(ExplanationKitModule.activeRuleSetVersion == "Rental-US-1.0")
}
#endif
