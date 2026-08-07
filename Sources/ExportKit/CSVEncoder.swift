//
//  CSVEncoder.swift
//  PropertyDealRealityChecker
//
//  Stage 7 — Explanation & Reports
//  Architectural Mandate: CSV data encoders.
//

import Foundation
import DealCore

/// Encodes a `CalculationSnapshot` into a CSV string.
public struct CSVEncoder: Sendable {
    
    public init() {}
    
    /// Encodes the main metrics of a calculation snapshot to CSV format.
    public func encode(snapshot: CalculationSnapshot) -> String {
        var csv = "Metric,Value\n"
        
        let m = snapshot.metrics
        
        csv += "Gross Scheduled Income,\(m.grossScheduledIncome.amount)\n"
        csv += "Effective Gross Income,\(m.effectiveGrossIncome.amount)\n"
        csv += "Net Operating Income,\(m.netOperatingIncome.amount)\n"
        csv += "Owner Cash Flow,\(m.ownerCashFlow.amount)\n"
        csv += "Cap Rate,\(m.capRate.fraction)\n"
        csv += "Cash on Cash Return,\(m.cashOnCashReturn.fraction)\n"
        csv += "DSCR,\(m.dscr)\n"
        csv += "Break-Even Occupancy,\(m.breakEvenOccupancyRate.fraction)\n"
        csv += "Loan to Cost,\(m.loanToCost.fraction)\n"
        csv += "Loan to Value,\(m.loanToValue.fraction)\n"
        csv += "Debt Yield,\(m.debtYield.fraction)\n"
        csv += "Initial Cash Required,\(m.initialCashRequired.amount)\n"
        csv += "Annual Debt Service,\(m.annualDebtService.amount)\n"
        csv += "Balloon Principal Burden,\(m.balloonPrincipalBurden.amount)\n"
        
        return csv
    }
}
