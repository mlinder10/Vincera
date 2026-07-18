//
//  ManageSubscriptionScreen.swift
//  Vincera
//
//  Created by Matt Linder on 6/24/26.
//

import SwiftUI
import StoreKit

struct ManageSubscriptionScreen: View {
    @EnvironmentObject private var productManager: ProductManager
    
    var body: some View {
        Group {
            
            if let subscription = productManager.currentSubscription,
               let monthly = productManager.monthlySubProduct,
               let yearly = productManager.yearlySubProduct {
                VStack(spacing: 24) {
                    Card {
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Monthly Subscription")
                                    .fontWeight(.semibold)
                                Spacer()
                                Badge(monthly.displayPrice, color: .accent)
                            }
                            
                            BrandButton(
                                subscription == .monthly ? "Current Plan" : "Switch to Monthly",
                                action: { handleSubscribe(to: .monthly) }
                            )
                            .primary
                            .disabled(subscription == .monthly)
                        }
                    }
                    
                    Card {
                        VStack {
                            HStack {
                                Text("Yearly Subscription")
                                    .fontWeight(.semibold)
                                Spacer()
                                Badge(yearly.displayPrice, color: .accent)
                            }
                            
                            BrandButton(
                                subscription == .yearly ? "Current Plan" : "Upgrade to Yearly",
                                action: { handleSubscribe(to: .yearly) }
                            )
                            .primary
                            .disabled(subscription == .yearly)
                        }
                    }
                    
                    Spacer()
                    
                    BrandButton(
                        "Cancel Subscription",
                        role: .destructive,
                        action: handleCancel
                    )
                    .primary
                }
                .padding(.vertical, PADDING_TOP)
            } else {
                VStack(spacing: 24) {
                    ProgressView()
                    Text("Loading Subscription Details...")
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.horizontal, PADDING_INLINE)
        .navigationTitle("Manage Subscription")
    }
    
    private func handleSubscribe(to plan: Subscription) {
        Task {
            do {
                try await productManager.subscribe(plan: plan)
            } catch {
                Router.shared.toast(
                    "Failed to upgrade subscription",
                    subtitle: "Please contact support.",
                    type: .error
                )
            }
        }
    }
    
    private func handleCancel() {
        Task {
            do {
                try await productManager.cancelSubscription()
            } catch {
                Router.shared.toast(
                    "Failed to cancel subscription",
                    subtitle: "Please contact support.",
                    type: .error
                )
            }
        }
    }
}

#Preview {
    NavigationStack {
        ManageSubscriptionScreen()
            .environmentObject(ProductManager())
    }
}
