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
    
    @Published var isLoading: Bool = false
    @Published var isSubscribed: Bool = false
    
    private(set) var product: Product?
    private var updatesTask: Task<Void, Never>?
    
    
    private let subscriptionProductID = "com.UniverseTest.subscription"
    
    
    init() {
        updatesTask = observeTransactionUpdates()
        Task {
            await checkSubscriptionStatus()
        }
    }
    
    
    deinit {
        updatesTask?.cancel()
    }
    
    
//    func loadSubscriptionProduct() async throws -> Product {
//        
//        let products = try await Product.products(for: [subscriptionProductID])
//        
//        guard let product = products.first else {
//            throw SubscriptionError.productNotFound
//        }
//        
//        self.product = product
//        return product
//        
//    }
    
    func loadSubscriptionProduct() async throws -> Product {
        print("🔍 [StoreKit Debug] Starting product load...")
        print("🔍 [StoreKit Debug] Product ID: '\(subscriptionProductID)'")
        print("🔍 [StoreKit Debug] Bundle ID: '\(Bundle.main.bundleIdentifier ?? "unknown")'")
        
        let products = try await Product.products(for: [subscriptionProductID])
        
        print("🔍 [StoreKit Debug] Found \(products.count) products")
        
        for (index, product) in products.enumerated() {
            print("🔍 [StoreKit Debug] Product \(index):")
            print("   - ID: '\(product.id)'")
            print("   - Name: '\(product.displayName)'")
            print("   - Price: '\(product.displayPrice)'")
            print("   - Type: '\(product.type)'")
        }
        
        guard let product = products.first else {
            print("❌ [StoreKit Debug] ERROR: No product found!")
            print("❌ Possible causes:")
            print("   1. StoreKit.config not in scheme")
            print("   2. Wrong product ID")
            print("   3. StoreKit file not in target")
            print("   4. Need to clean/restart Xcode")
            throw SubscriptionError.productNotFound
        }
        
        print("✅ [StoreKit Debug] SUCCESS: Product loaded!")
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
            
                await MainActor.run {
                    self.isSubscribed = true
                }
            
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
                    let isActive = transaction.revocationDate == nil && !transaction.isUpgraded
                    
                    await MainActor.run {
                        self.isSubscribed = isActive
                    }
                    
                    return isActive
                }
            }
            
            
        }
        
        await MainActor.run {
            self.isSubscribed = false
        }
        
        return false
        
    }
    
    
    func restorePurchases() async throws {
        
        try await AppStore.sync()
        await checkSubscriptionStatus()
        
    }
    
    
    private func observeTransactionUpdates() -> Task<Void, Never> {
        
        Task(priority: .background) {
            
            for await update in Transaction.updates {
                
                if case .verified(let transaction) = update {
                    
                    await self.checkSubscriptionStatus()
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
