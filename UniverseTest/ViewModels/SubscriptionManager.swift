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
    
    
    private let subscriptionProductID = "com.veronika.UniverseTest.subscription"
    
    
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
        print("🔍 [StoreKit Debug] ===== STOREKIT DEBUG START =====")
        print("🔍 [StoreKit Debug] Product ID: '\(subscriptionProductID)'")
        print("🔍 [StoreKit Debug] Bundle ID: '\(Bundle.main.bundleIdentifier ?? "unknown")'")
        print("🔍 [StoreKit Debug] App Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "unknown")")
        
        // Test if StoreKit is even responding
        let startTime = Date()
        let products = try await Product.products(for: [subscriptionProductID])
        let loadTime = Date().timeIntervalSince(startTime)
        
        print("🔍 [StoreKit Debug] Load time: \(loadTime) seconds")
        print("🔍 [StoreKit Debug] Products found: \(products.count)")
        
        for product in products {
            print("🔍 [StoreKit Debug] - Product: \(product.id) -> \(product.displayName)")
        }
        
        guard let product = products.first else {
            print("❌ [StoreKit Debug] CRITICAL: StoreKit returned ZERO products")
            print("❌ [StoreKit Debug] This means:")
            print("   1. StoreKit.config not loading")
            print("   2. Product ID mismatch")
            print("   3. StoreKit testing not enabled")
            print("🔍 [StoreKit Debug] ===== STOREKIT DEBUG END =====")
            throw SubscriptionError.productNotFound
        }
        
        print("✅ [StoreKit Debug] SUCCESS: Product loaded: \(product.displayName)")
        print("🔍 [StoreKit Debug] ===== STOREKIT DEBUG END =====")
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
