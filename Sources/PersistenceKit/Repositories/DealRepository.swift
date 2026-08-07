//
//  DealRepository.swift
//  PropertyDealRealityChecker
//
//  Stage 4 — Persistence, Offline-First Repository & Migration Layer
//  Architectural Mandate: Offline-first repository pattern isolating features from persistence technology.
//

import Foundation
import DealCore

/// Defines the contract for an offline-first repository managing investment property deals and audit snapshots.
///
/// Implements Blueprint Section 8 ("Persistence, Storage, and Lifecycle"):
/// Local storage is the system of record. Feature packages consume this protocol
/// without knowing whether data is backed by SwiftData, CoreData, or in-memory stores.
public protocol DealRepository: Sendable {
    /// Fetches all persisted underwriting deals ordered by last modification timestamp.
    func fetchAllDeals() async throws -> [Deal]
    
    /// Fetches a specific deal by its unique ID.
    /// - Parameter id: The unique UUID of the deal.
    /// - Returns: The domain `Deal` entity if found, or `nil`.
    func fetchDeal(id: UUID) async throws -> Deal?
    
    /// Inserts or updates an underwriting deal in local storage.
    /// - Parameter deal: The domain deal entity to persist.
    func saveDeal(_ deal: Deal) async throws
    
    /// Removes a deal and its associated calculation snapshots from local storage.
    /// - Parameter id: The UUID of the deal to delete.
    func deleteDeal(id: UUID) async throws
    
    /// Fetches all immutable audit calculation snapshots generated for a deal.
    /// - Parameter dealID: The parent deal UUID.
    /// - Returns: Ordered array of calculation snapshots (most recent first).
    func fetchSnapshots(forDealID dealID: UUID) async throws -> [CalculationSnapshot]
    
    /// Persists a new immutable calculation audit snapshot.
    /// - Parameter snapshot: The completed calculation audit record.
    func saveSnapshot(_ snapshot: CalculationSnapshot) async throws
}
