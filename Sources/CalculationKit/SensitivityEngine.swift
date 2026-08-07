//
//  SensitivityEngine.swift
//  PropertyDealRealityChecker
//
//  Stage 3 — Deterministic Calculation Engine
//  Architectural Mandate: 3x3 and 5x5 sensitivity and stress-test matrices across key assumptions.
//  May import ONLY Foundation. Never Double.
//

import Foundation

/// Represents an individual cell within a sensitivity or stress-test matrix.
public struct SensitivityCell: Sendable, Hashable, Codable {
    /// Row parameter value label (e.g., `"$400,000"` or `"7.0%"`).
    public let rowLabel: String
    /// Column parameter value label (e.g., `"8.0% Vacancy"`).
    public let colLabel: String
    /// Calculated Accounting Net Operating Income (`NOI`) at this intersection.
    public let noi: Decimal
    /// Calculated Owner Pre-Tax Cash Flow at this intersection.
    public let ownerCashFlow: Decimal
    /// Calculated Cap Rate fraction at this intersection.
    public let capRate: Decimal
    /// Calculated Cash-on-Cash Return fraction at this intersection.
    public let cashOnCashReturn: Decimal
    /// Calculated Debt Service Coverage Ratio (`DSCR`) at this intersection.
    public let dscr: Decimal
    
    /// Initializes a sensitivity matrix cell.
    public init(
        rowLabel: String,
        colLabel: String,
        noi: Decimal,
        ownerCashFlow: Decimal,
        capRate: Decimal,
        cashOnCashReturn: Decimal,
        dscr: Decimal
    ) {
        self.rowLabel = rowLabel
        self.colLabel = colLabel
        self.noi = noi
        self.ownerCashFlow = ownerCashFlow
        self.capRate = capRate
        self.cashOnCashReturn = cashOnCashReturn
        self.dscr = dscr
    }
}

/// A structured multi-dimensional sensitivity and stress-test matrix.
public struct SensitivityMatrix: Sendable, Hashable, Codable {
    /// Descriptive name of the stress matrix (e.g., `"Purchase Price vs. Vacancy Rate"`).
    public let matrixName: String
    /// Row axis title (e.g., `"Purchase Price"`).
    public let rowHeaderName: String
    /// Column axis title (e.g., `"Vacancy Rate"`).
    public let colHeaderName: String
    /// Ordered row parameter values.
    public let rowValues: [Decimal]
    /// Ordered column parameter values.
    public let colValues: [Decimal]
    /// 2D grid of calculated sensitivity cells (`cells[row][col]`).
    public let cells: [[SensitivityCell]]
    
    /// Initializes a sensitivity matrix.
    public init(
        matrixName: String,
        rowHeaderName: String,
        colHeaderName: String,
        rowValues: [Decimal],
        colValues: [Decimal],
        cells: [[SensitivityCell]]
    ) {
        self.matrixName = matrixName
        self.rowHeaderName = rowHeaderName
        self.colHeaderName = colHeaderName
        self.rowValues = rowValues
        self.colValues = colValues
        self.cells = cells
    }
}

/// Pure deterministic generator for 3x3 and 5x5 sensitivity and stress-test matrices.
public struct SensitivityEngine: Sendable {
    /// Generates a 3x3 sensitivity matrix evaluating **Purchase Price** (`-5%`, `0%`, `+5%`) against **Vacancy Rate** (`5%`, `8%`, `10%`).
    /// - Parameters:
    ///   - basePrice: Current purchase price.
    ///   - baseGSI: Total Gross Scheduled Income.
    ///   - baseOperatingExpenses: Mandatory annual operating expenses.
    ///   - baseCapitalReserves: Annual capital replacement reserves.
    ///   - annualDebtService: Total annual contractual debt service.
    ///   - baseInitialCash: Upfront equity cash required at base price.
    /// - Returns: A 3x3 `SensitivityMatrix` with evaluated return metrics at every grid cell.
    public static func generatePriceVsVacancyMatrix(
        basePrice: Decimal,
        baseGSI: Decimal,
        baseOperatingExpenses: Decimal,
        baseCapitalReserves: Decimal,
        annualDebtService: Decimal,
        baseInitialCash: Decimal
    ) -> SensitivityMatrix {
        let priceMultipliers: [Decimal] = [0.95, 1.00, 1.05]
        let vacancyRates: [Decimal] = [0.05, 0.08, 0.10]
        
        let rowValues = priceMultipliers.map { $0 * basePrice }
        let colValues = vacancyRates
        
        var grid: [[SensitivityCell]] = []
        
        for price in rowValues {
            var rowCells: [SensitivityCell] = []
            let priceDelta = price - basePrice
            let initialCash = max(0, baseInitialCash + priceDelta)
            
            for vacancy in colValues {
                let egi = OperatingCalculator.calculateEGI(gsi: baseGSI, vacancyRate: vacancy)
                let noi = egi - baseOperatingExpenses
                let cashFlow = noi - baseCapitalReserves - annualDebtService
                let capRate = ReturnCalculator.calculateCapRate(
                    noi: noi,
                    purchasePrice: price,
                    totalProjectCost: price
                )
                let coc = ReturnCalculator.calculateCashOnCashReturn(
                    ownerCashFlow: cashFlow,
                    initialCashRequired: initialCash
                )
                let dscr = ReturnCalculator.calculateDSCR(noi: noi, annualDebtService: annualDebtService)
                
                let rowLabel = "$\(NSDecimalNumber(decimal: RoundingEngine.roundToBankers(amount: price, places: 0)))"
                let colLabel = "\(NSDecimalNumber(decimal: vacancy * 100))% Vac"
                
                rowCells.append(SensitivityCell(
                    rowLabel: rowLabel,
                    colLabel: colLabel,
                    noi: noi,
                    ownerCashFlow: cashFlow,
                    capRate: capRate,
                    cashOnCashReturn: coc,
                    dscr: dscr
                ))
            }
            grid.append(rowCells)
        }
        
        return SensitivityMatrix(
            matrixName: "Purchase Price vs. Vacancy Rate (3x3)",
            rowHeaderName: "Purchase Price",
            colHeaderName: "Vacancy Rate",
            rowValues: rowValues,
            colValues: colValues,
            cells: grid
        )
    }
}
