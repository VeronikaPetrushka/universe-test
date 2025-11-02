//
//  SubscriptionManager.swift
//  UniverseTest
//
//  Created by Veronika Petrushka on 02/11/2025.
//

import Foundation
import StoreKit


@MainActor
class SubscriptionManager: ObservableObject {
    
    private var product: Product?
    private var updatesTask: Task<Void, Never>?
    
    
    private let subscriptionProductID = "com.UniverseTest.subscription"
    
    
    init() {
        updatesTask = observeTransactionUpdates()
    }
    
    
    deinit {
        updatesTask?.cancel()
    }
    
    
    func loadSubscriptionProduct() async throws -> Product {
        
        let products = try await Product.products(for: [subscriptionProductID])
        
        guard let product = products.first else {
            throw SubscriptionError.productNotFound
        }
        
        self.product = product
        return product
        
    }
    
    
    func purchaseSubscription() async throws -> Transaction {
        
        guard let product = product else {
            throw SubscriptionError.productNotLoaded
        }
        
        let result = try await product.purchase()
        
        switch result {
            
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                return transaction
                
            case .userCancelled:
                throw SubscriptionError.userCancelled
                
            case .pending:
                throw SubscriptionError.pending
                
            @unknown default:
                throw SubscriptionError.unknown
            
        }
        
    }
    
    
    func checkSubscriptionStatus() async -> Bool {
        
        for await entitlement in Transaction.currentEntitlements {
            
            
            if case .verified(let transaction) = entitlement {
                if transaction.productID == subscriptionProductID {
                    return transaction.revocationDate == nil && !transaction.isUpgraded
                }
            }
            
            
        }
        
        return false
        
    }
    
    
    func restorePurchases() async throws {
        try await AppStore.sync()
    }
    
    
    private func observeTransactionUpdates() -> Task<Void, Never> {
        
        Task(priority: .background) {
            
            for await update in Transaction.updates {
                
                if case .verified(let transaction) = update {
                    await transaction.finish()
                }
                
            }
            
        }
        
    }
    
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        
        switch result{
            
        case .unverified:
            throw SubscriptionError.verificationFailed
        case .verified(let safe):
            return safe

        }
        
    }
    
    
}



enum SubscriptionError: LocalizedError {
    
    case productNotFound
    case productNotLoaded
    case userCancelled
    case pending
    case verificationFailed
    case unknown
    
    
    var errorDescription: String? {
        switch self {
            
        case.productNotFound:
            return "Subscription product not found"
        case.productNotLoaded:
            return "Product not loaded"
        case .userCancelled:
            return "Purchase cancelled"
        case .pending:
            return "Purchase is pending approval"
        case .verificationFailed:
            return "Transaction verification failed"
        case .unknown:
            return "Unknown error occurred"
            
        }
    }
    
}
