//
//  UnderwritingEngine.swift
//  PropertyDealRealityChecker
//
//  Stage 3 — Deterministic Calculation Engine
//  Architectural Mandate: Orchestrates CanonicalDeal inputs through CalculationKit to produce an immutable CalculationSnapshot.
//

import Foundation
import CalculationKit

/// The primary domain underwriting orchestrator connecting `DealCore` inputs with `CalculationKit` formulas.
///
/// Implements Blueprint Section 4 ("Underwriting Methodology"):
/// Takes an immutable `CanonicalDeal` and investor `UserDefaultsProfile`, invokes deterministic calculation
/// engines, assigns explainable verdict reason codes, and produces an immutable `CalculationSnapshot`.
public struct UnderwritingEngine: Sendable {
    /// Evaluates an immutable `CanonicalDeal` and returns a completed `CalculationSnapshot`.
    /// - Parameters:
    ///   - deal: Immutable validated deal inputs.
    ///   - profile: Configured investor thresholds and defaults.
    /// - Returns: Complete `CalculationSnapshot` containing unrounded metrics, verdict, and sensitivity matrix.
    public static func evaluate(
        deal: CanonicalDeal,
        profile: UserDefaultsProfile = .conservativeRentalUS
    ) -> CalculationSnapshot {
        let scenario = deal.scenario
        let projectCost = scenario.projectCost
        let purchasePrice = projectCost.purchasePrice.amount
        let totalProjectCost = projectCost.totalProjectCost.amount
        
        // 1. Prepare income lines for OperatingCalculator
        let annualIncomeAmounts = scenario.incomeLines.map { $0.annualizedAmount.amount }
        let gsi = OperatingCalculator.calculateGSI(annualIncomeAmounts: annualIncomeAmounts)
        
        // Extract vacancy rate assumption (default from profile if missing)
        let vacancyRate = scenario.assumptions["vacancyRate"]?.value ?? profile.defaultVacancyRate.fraction
        let creditLossRate = scenario.assumptions["creditLossRate"]?.value ?? 0
        let egi = OperatingCalculator.calculateEGI(gsi: gsi, vacancyRate: vacancyRate, creditLossRate: creditLossRate)
        
        // 2. Prepare expense lines
        let expenseInputLines = scenario.expenseLines.map {
            OperatingInputLine(name: $0.category.rawValue, annualAmount: $0.annualizedAmount.amount, isNOIExpense: $0.inclusionInNOI)
        }
        let operatingExpenses = OperatingCalculator.calculateOperatingExpensesTotal(expenseLines: expenseInputLines)
        let capitalReserves = OperatingCalculator.calculateCapitalReservesTotal(expenseLines: expenseInputLines)
        let noi = OperatingCalculator.calculateNOI(egi: egi, expenseLines: expenseInputLines)
        
        // 3. Prepare debt layers for AmortizationEngine
        let debtInputLayers = scenario.financingPlan.debtLayers.map {
            AmortizationInputLayer(
                name: $0.name,
                principal: $0.principal.amount,
                annualInterestRate: $0.interestRate.fraction,
                amortizationMonths: $0.amortizationMonths,
                contractualTermMonths: $0.contractualTermMonths,
                isInterestOnly: ($0.interestOnlyMonths ?? 0) > 0
            )
        }
        let totalDebtPrincipal = scenario.financingPlan.totalDebtPrincipal.amount
        let annualDebtService = AmortizationEngine.calculateAnnualDebtService(layers: debtInputLayers)
        let balloonBurden = AmortizationEngine.calculateBalloonBurden(layers: debtInputLayers)
        
        let initialCashRequired = projectCost.totalInitialCashRequired(
            totalDebtPrincipal: CurrencyAmount(amount: totalDebtPrincipal, currencyCode: projectCost.purchasePrice.currencyCode)
        ).amount
        
        let ownerCashFlow = OperatingCalculator.calculateOwnerCashFlow(
            noi: noi,
            capitalReserves: capitalReserves,
            annualDebtService: annualDebtService
        )
        
        // 4. Calculate return and valuation ratios
        let capRateFraction = ReturnCalculator.calculateCapRate(
            noi: noi,
            purchasePrice: purchasePrice,
            totalProjectCost: totalProjectCost,
            useProjectCostAsDenominator: (profile.capRateDenominatorRule == .totalProjectCost)
        )
        let cocFraction = ReturnCalculator.calculateCashOnCashReturn(
            ownerCashFlow: ownerCashFlow,
            initialCashRequired: initialCashRequired
        )
        let dscrValue = ReturnCalculator.calculateDSCR(noi: noi, annualDebtService: annualDebtService)
        let beOccFraction = ReturnCalculator.calculateBreakEvenOccupancy(
            operatingExpenses: operatingExpenses,
            annualDebtService: annualDebtService,
            gsi: gsi
        )
        let ltvFraction = ReturnCalculator.calculateLTV(totalDebtPrincipal: totalDebtPrincipal, propertyValue: purchasePrice)
        let ltcFraction = ReturnCalculator.calculateLTC(totalDebtPrincipal: totalDebtPrincipal, totalProjectCost: totalProjectCost)
        let debtYieldFraction = ReturnCalculator.calculateDebtYield(noi: noi, totalDebtPrincipal: totalDebtPrincipal)
        
        let currencyCode = projectCost.purchasePrice.currencyCode
        let metrics = CalculationMetrics(
            grossScheduledIncome: CurrencyAmount(amount: gsi, currencyCode: currencyCode),
            effectiveGrossIncome: CurrencyAmount(amount: egi, currencyCode: currencyCode),
            netOperatingIncome: CurrencyAmount(amount: noi, currencyCode: currencyCode),
            ownerCashFlow: CurrencyAmount(amount: ownerCashFlow, currencyCode: currencyCode),
            capRate: Rate(fraction: capRateFraction),
            cashOnCashReturn: Rate(fraction: cocFraction),
            dscr: dscrValue,
            breakEvenOccupancyRate: Rate(fraction: beOccFraction),
            loanToCost: Rate(fraction: ltcFraction),
            loanToValue: Rate(fraction: ltvFraction),
            debtYield: Rate(fraction: debtYieldFraction),
            initialCashRequired: CurrencyAmount(amount: initialCashRequired, currencyCode: currencyCode),
            annualDebtService: CurrencyAmount(amount: annualDebtService, currencyCode: currencyCode),
            balloonPrincipalBurden: CurrencyAmount(amount: balloonBurden, currencyCode: currencyCode)
        )
        
        // 5. Generate 3x3 sensitivity matrix
        let sensitivityMatrix = SensitivityEngine.generatePriceVsVacancyMatrix(
            basePrice: purchasePrice,
            baseGSI: gsi,
            baseOperatingExpenses: operatingExpenses,
            baseCapitalReserves: capitalReserves,
            annualDebtService: annualDebtService,
            baseInitialCash: initialCashRequired
        )
        let stressResults = StressTestResults(
            summary: "3x3 Purchase Price vs. Vacancy Rate Matrix",
            matrix: sensitivityMatrix
        )
        
        // 6. Build structured reason codes & verdict
        var reasonCodes: [ReasonCode] = []
        
        // Rule DSCR-001
        let dscrSuccess = dscrValue >= profile.minDSCR || scenario.financingPlan.isAllCash
        reasonCodes.append(ReasonCode(
            code: "DSCR-001",
            metricName: "Debt Service Coverage Ratio (DSCR)",
            actualValue: "\(NSDecimalNumber(decimal: RoundingEngine.roundToBankers(amount: dscrValue, places: 2)))x",
            thresholdValue: "\(NSDecimalNumber(decimal: profile.minDSCR))x minimum",
            isSuccess: dscrSuccess,
            plainLanguageExplanation: dscrSuccess
                ? "Property generates sufficient Net Operating Income to comfortably service debt."
                : "Debt service exceeds acceptable risk coverage; property is vulnerable to operating shortfalls."
        ))
        
        // Rule COC-001
        let cocSuccess = cocFraction >= profile.minCoCReturn.fraction
        reasonCodes.append(ReasonCode(
            code: "COC-001",
            metricName: "Cash-on-Cash Return",
            actualValue: "\(NSDecimalNumber(decimal: RoundingEngine.roundRate(rate: cocFraction * 100, places: 2)))%",
            thresholdValue: "\(NSDecimalNumber(decimal: profile.minCoCReturn.percentage))% minimum",
            isSuccess: cocSuccess,
            plainLanguageExplanation: cocSuccess
                ? "Annual pre-tax cash flow meets or exceeds target investor cash yield."
                : "Cash return on equity is below target threshold."
        ))
        
        // Rule LTV-001
        let ltvSuccess = ltvFraction <= profile.maxLTV.fraction
        reasonCodes.append(ReasonCode(
            code: "LTV-001",
            metricName: "Loan-to-Value (LTV)",
            actualValue: "\(NSDecimalNumber(decimal: RoundingEngine.roundRate(rate: ltvFraction * 100, places: 1)))%",
            thresholdValue: "\(NSDecimalNumber(decimal: profile.maxLTV.percentage))% maximum",
            isSuccess: ltvSuccess,
            plainLanguageExplanation: ltvSuccess
                ? "Leverage level is within conservative safety limits."
                : "Loan-to-Value exceeds conservative borrowing limits."
        ))
        
        // Determine Verdict category
        let category: VerdictCategory
        if !dscrSuccess && !scenario.financingPlan.isAllCash {
            category = .highRisk
        } else if !cocSuccess {
            category = .marginal
        } else if dscrSuccess && cocSuccess && ltvSuccess {
            category = .strong
        } else {
            category = .workable
        }
        
        // Determine Confidence level from sources
        let sources = scenario.incomeLines.map { $0.source.confidenceLevel } +
                      scenario.expenseLines.map { $0.source.confidenceLevel }
        let overallConfidence: ConfidenceLevel = sources.contains(.low) ? .low :
                                                 sources.contains(.medium) ? .medium : .high
                                                 
        let verdict = Verdict(
            category: category,
            confidence: overallConfidence,
            reasonCodes: reasonCodes
        )
        
        return CalculationSnapshot(
            dealID: deal.id,
            scenarioID: scenario.id,
            inputHash: deal.inputHash,
            normalizedInputs: deal,
            validationFindings: deal.validationIssues,
            metrics: metrics,
            verdict: verdict,
            stressResults: stressResults
        )
    }
}
