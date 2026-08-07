//
//  UserDefaultsProfile.swift
//  PropertyDealRealityChecker
//
//  Stage 2 — Domain Model & Financial Value Types
//  Architectural Mandate: Configurable investor market defaults, thresholds, and rounding rules.
//

import Foundation

/// Identifies the capitalization rate denominator rule (ADR-002).
public enum CapRateDenominatorRule: String, Sendable, Codable, Hashable {
    /// Purchase price (canonical default for initial acquisition screening).
    case purchasePrice = "Purchase Price"
    /// Total upfront project cost (`Purchase Price + Rehab + Closing Costs`).
    case totalProjectCost = "Total Project Cost"
}

/// Reusable investor profile containing default market rates, safety thresholds, and calculation rules.
///
/// Pre-configured with the **"Conservative Rental (US)"** profile selected in Stage 0:
/// - Target DSCR >= `1.25x`
/// - Target Cash-on-Cash >= `8.0%`
/// - Max LTV <= `75.0%`
/// - Max LTC <= `80.0%`
/// - Default Vacancy = `8.0%`
/// - Default Maintenance = `8.0%`
/// - Default Management = `8.0%`
/// - Default Capital Reserves = `5.0%`
public struct UserDefaultsProfile: Sendable, Codable, Hashable {
    /// Profile display name.
    public var profileName: String
    
    /// Minimum acceptable Debt Service Coverage Ratio threshold (default: `1.25`).
    public var minDSCR: Decimal
    
    /// Minimum acceptable Cash-on-Cash Return rate threshold (`0.08` for 8%).
    public var minCoCReturn: Rate
    
    /// Maximum acceptable Loan-to-Value ratio (`0.75` for 75%).
    public var maxLTV: Rate
    
    /// Maximum acceptable Loan-to-Cost ratio (`0.80` for 80%).
    public var maxLTC: Rate
    
    /// Default residential vacancy rate assumption (`0.08` for 8%).
    public var defaultVacancyRate: Rate
    
    /// Default ongoing maintenance & repair assumption (`0.08` for 8%).
    public var defaultMaintenanceRate: Rate
    
    /// Default property management expense assumption (`0.08` for 8%).
    public var defaultPropertyManagementRate: Rate
    
    /// Default capital replacement reserve assumption (`0.05` for 5%).
    public var defaultCapitalReservesRate: Rate
    
    /// Cap rate denominator policy (default: `.purchasePrice`).
    public var capRateDenominatorRule: CapRateDenominatorRule
    
    /// Initializes an investor defaults profile.
    public init(
        profileName: String = "Conservative Rental (US)",
        minDSCR: Decimal = 1.25,
        minCoCReturn: Rate = Rate(fraction: 0.08),
        maxLTV: Rate = Rate(fraction: 0.75),
        maxLTC: Rate = Rate(fraction: 0.80),
        defaultVacancyRate: Rate = Rate(fraction: 0.08),
        defaultMaintenanceRate: Rate = Rate(fraction: 0.08),
        defaultPropertyManagementRate: Rate = Rate(fraction: 0.08),
        defaultCapitalReservesRate: Rate = Rate(fraction: 0.05),
        capRateDenominatorRule: CapRateDenominatorRule = .purchasePrice
    ) {
        self.profileName = profileName
        self.minDSCR = minDSCR
        self.minCoCReturn = minCoCReturn
        self.maxLTV = maxLTV
        self.maxLTC = maxLTC
        self.defaultVacancyRate = defaultVacancyRate
        self.defaultMaintenanceRate = defaultMaintenanceRate
        self.defaultPropertyManagementRate = defaultPropertyManagementRate
        self.defaultCapitalReservesRate = defaultCapitalReservesRate
        self.capRateDenominatorRule = capRateDenominatorRule
    }
    
    /// Standard conservative US rental investor defaults profile.
    public static let conservativeRentalUS = UserDefaultsProfile()
}
