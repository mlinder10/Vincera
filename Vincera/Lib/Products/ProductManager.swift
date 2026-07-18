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

enum Subscription: String, CaseIterable {
    case monthly = "com.mattlinder.vincera.monthly_subscription"
    case yearly = "com.mattlinder.vincera.yearly_subscription"
    
    static func ids() -> [String] {
        Subscription.allCases.map(\.rawValue)
    }
    
    static func contains(id: String) -> Bool {
        Subscription.ids().contains(id)
    }
    
    func toStatus() -> SubscriptionStatus {
        switch self {
        case .monthly: .monthly
        case .yearly: .yearly
        }
    }
}

enum SubscriptionStatus {
    case none, monthly, yearly
}

@MainActor
final class ProductManager: ObservableObject {    
    @Published var monthlySubProduct: Product?
    @Published var yearlySubProduct: Product?
    @Published var isTrialEligible: Bool?
    @Published var currentSubscription: SubscriptionStatus?
    
    private var transactionListener: Task<Void, Error>?
    
    init() {
        transactionListener = listenForTransactions()
        if hasAdminStatus() {
            currentSubscription = .yearly
        }
        
        Task {
            await loadProducts()
            await updateSubscriptionStatus()
        }
    }
    
    deinit {
        transactionListener?.cancel()
    }
    
    private func loadProducts() async {
        do {
            let subscriptions = try await Product.products(for: Subscription.ids())
            for product in subscriptions {
                if product.id == Subscription.monthly.rawValue {
                    self.monthlySubProduct = product
                    self.isTrialEligible = await product.subscription?.isEligibleForIntroOffer
                } else if product.id == Subscription.yearly.rawValue {
                    self.yearlySubProduct = product
                }
            }
        } catch {
            print("StoreKit: Failed to load products: \(error)")
        }
    }
    
    func checkAdminStatus() {
        if hasAdminStatus() {
            self.currentSubscription = .yearly
        }
    }
    
    private func updateSubscriptionStatus() async {
        if hasAdminStatus() {
            self.currentSubscription = .yearly
            return
        }
        
        self.currentSubscription = SubscriptionStatus.none
        
        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result) {
                if transaction.productID == Subscription.monthly.rawValue {
                    self.currentSubscription = .monthly
                } else if transaction.productID == Subscription.yearly.rawValue {
                    self.currentSubscription = .yearly
                }
            }
        }
    }
    
    private func listenForTransactions() -> Task<Void, Error> {
        Task.detached(priority: .background) {
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await self.updateSubscriptionStatus()
                    await transaction.finish()
                }
            }
        }
    }
    
    // public
    
    func subscribe(plan: Subscription) async throws {
        guard let monthlySubProduct, let yearlySubProduct else { return }
        let product = switch plan {
        case .monthly: monthlySubProduct
        case .yearly: yearlySubProduct
        }
        
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            // Check if the transaction is legitimate
            if case .verified(let transaction) = verification {
                self.currentSubscription = plan.toStatus()
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
        await updateSubscriptionStatus()
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
