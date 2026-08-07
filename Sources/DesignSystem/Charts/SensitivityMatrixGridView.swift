//
//  SensitivityMatrixGridView.swift
//  PropertyDealRealityChecker
//
//  Stage 5 — Shared Design System, Theme Engine & Chart Library
//  Architectural Mandate: Accessible visual 3x3 stress-test matrix grid. Zero domain dependencies.
//

import Foundation
#if canImport(SwiftUI)
import SwiftUI
#endif

/// Data model for an individual cell inside a `SensitivityMatrixGridView`.
public struct SensitivityGridCellModel: Sendable, Hashable, Codable {
    public let rowLabel: String
    public let colLabel: String
    public let primaryMetricText: String
    public let secondaryMetricText: String
    public let isPassing: Bool
    
    public init(
        rowLabel: String,
        colLabel: String,
        primaryMetricText: String,
        secondaryMetricText: String,
        isPassing: Bool
    ) {
        self.rowLabel = rowLabel
        self.colLabel = colLabel
        self.primaryMetricText = primaryMetricText
        self.secondaryMetricText = secondaryMetricText
        self.isPassing = isPassing
    }
    
    public var accessibilityDescription: String {
        let statusText = isPassing ? "Pass" : "Alert"
        return "\(rowLabel) at \(colLabel): \(primaryMetricText), \(secondaryMetricText). Status: \(statusText)"
    }
}

/// Data model and accessibility descriptor for a `SensitivityMatrixGridView`.
public struct SensitivityMatrixGridModel: Sendable, Hashable, Codable {
    public let matrixTitle: String
    public let rowHeaderName: String
    public let colHeaderName: String
    public let cells: [[SensitivityGridCellModel]]
    
    public init(
        matrixTitle: String,
        rowHeaderName: String,
        colHeaderName: String,
        cells: [[SensitivityGridCellModel]]
    ) {
        self.matrixTitle = matrixTitle
        self.rowHeaderName = rowHeaderName
        self.colHeaderName = colHeaderName
        self.cells = cells
    }
    
    /// Comprehensive accessibility description summarizing matrix dimensions and passing count.
    public var accessibilityDescription: String {
        let totalCells = cells.reduce(0) { $0 + $1.count }
        let passingCount = cells.flatMap { $0 }.filter { $0.isPassing }.count
        return "\(matrixTitle): \(rowHeaderName) versus \(colHeaderName) stress grid with \(totalCells) scenarios. \(passingCount) passing."
    }
}

#if canImport(SwiftUI)
/// A visual 3x3 stress-test matrix grid component displaying sensitivity return cells with color coding.
public struct SensitivityMatrixGridView: View {
    public let model: SensitivityMatrixGridModel
    
    public init(model: SensitivityMatrixGridModel) {
        self.model = model
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(model.matrixTitle)
                .font(.designTitleMedium)
                .foregroundColor(.designTextPrimary)
            
            VStack(spacing: 6) {
                ForEach(0..<model.cells.count, id: \.self) { rowIdx in
                    HStack(spacing: 6) {
                        ForEach(0..<model.cells[rowIdx].count, id: \.self) { colIdx in
                            cellView(for: model.cells[rowIdx][colIdx])
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.designSurface)
        .cornerRadius(12)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(model.accessibilityDescription)
    }
    
    @ViewBuilder
    private func cellView(for cell: SensitivityGridCellModel) -> some View {
        VStack(alignment: .center, spacing: 2) {
            Text(cell.primaryMetricText)
                .font(.designFinancialMonospaced)
                .foregroundColor(.designTextPrimary)
            
            Text(cell.secondaryMetricText)
                .font(.designCaption)
                .foregroundColor(cell.isPassing ? .designStrong : .designHighRisk)
        }
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(
            cell.isPassing ? Color.designStrong.opacity(0.1) : Color.designHighRisk.opacity(0.15)
        )
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(cell.isPassing ? Color.designStrong : Color.designHighRisk, lineWidth: 1)
        )
    }
}
#endif
