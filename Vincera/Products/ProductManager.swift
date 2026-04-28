//
//  ProductManager.swift
//  Vincera
//
//  Created by Matt Linder on 3/30/26.
//

import Foundation
import StoreKit

enum ProductError: Error {
    case productNotFound, nonePurchased, transactionVerificationFailed
}

let SUBSCRIPTION_ID = "com.mattlinder.vincera.monthly_subscription"

@MainActor
final class ProductManager: ObservableObject {
    static let shared = ProductManager()
    
    @Published private(set) var purchasedIds = Set<String>()
    @Published var skProducts = [Product]()
    
    @Published var subscriptionProduct: Product?
    @Published var isTrialEligible: Bool?
    @Published var isSubscribed: Bool?
    
    private var transactionListener: Task<Void, Error>?
    
    private init() {
        transactionListener = listenForTransactions()
        isSubscribed = hasAdminStatus()
        
        Task {
            await loadProducts()
            await updatePurchaseStatus()
            await updateSubscriptionStatus()
        }
    }
    
    deinit {
        transactionListener?.cancel()
    }
    
    private func loadProducts() async {
        do {
            let allIds = NON_CONSUMABLE_PRODUCT_IDS
            self.skProducts = try await Product.products(for: allIds)
            
            let subscription = try await Product.products(for: [SUBSCRIPTION_ID])
            self.subscriptionProduct = subscription.first
            self.isTrialEligible = await self.subscriptionProduct?.subscription?.isEligibleForIntroOffer
        } catch {
            print("StoreKit: Failed to load products: \(error)")
        }
    }
    
    private func updatePurchaseStatus() async {
        var purchasedIds = Set<String>()
        
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                purchasedIds.insert(transaction.productID)
            }
        }
        self.purchasedIds = purchasedIds
    }
    
    private func updateSubscriptionStatus() async {
        if hasAdminStatus() {
            self.isSubscribed = true
            return
        }
        
        for await result in Transaction.currentEntitlements {
            if case .verified(_) = result {
                self.isSubscribed = true
                return
            }
        }
        self.isSubscribed = false
    }
    
    private func listenForTransactions() -> Task<Void, Error> {
        Task.detached(priority: .background) {
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await self.updatePurchaseStatus()
                    await transaction.finish()
                }
            }
        }
    }
    
    // public
    
    func getProduct(id: String) -> Product? {
        skProducts.first(where: { $0.id == id })
    }
    
    func hasPurchased(_ productId: String) -> Bool {
        purchasedIds.contains(productId)
    }
    
    func purchase(_ productId: String) async throws -> Transaction? {
        guard let product = getProduct(id: productId) else {
            throw ProductError.productNotFound
        }
        
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await updatePurchaseStatus()
            return transaction
        case .userCancelled, .pending:
            return nil
        @unknown default:
            return nil
        }
    }
    
    func subscribe() async throws {
        guard let product = subscriptionProduct else { return }
        
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            // Check if the transaction is legitimate
            if case .verified(let transaction) = verification {
                self.isSubscribed = true
                await transaction.finish()
            }
        case .userCancelled, .pending:
            break
        @unknown default:
            break
        }
    }
    
    func cancelSubscription() async throws {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        try await AppStore.showManageSubscriptions(in: windowScene)
    }
    
    func restorePurchases() async throws {
        try await AppStore.sync()
        await updatePurchaseStatus()
    }
    
    // helpers
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw ProductError.transactionVerificationFailed
        case .verified(let safe):
            return safe
        }
    }
}
