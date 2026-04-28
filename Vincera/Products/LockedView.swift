//
//  LockedView.swift
//  Vincera
//
//  Created by Matt Linder on 4/17/26.
//

import SwiftUI
import StoreKit

struct LockedView: View {
    @ObservedObject private var productManager = ProductManager.shared
    var title = "Vincera - Full Access"
    var subtitle = "Join today to access exclusive training tools."
    
    var body: some View {
        Group {
            if let isTrialEligible = productManager.isTrialEligible {
                CoreView(
                    isTrialEligible: isTrialEligible,
                    title: title,
                    subtitle: subtitle
                )
            } else {
                LoadingView()
            }
        }
    }
}

private struct CoreView: View {
    @ObservedObject private var productManager = ProductManager.shared
    @State private var isAccountPresented = false
    let isTrialEligible: Bool
    let title: String
    let subtitle: String
    
    var body: some View {
            ZStack {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .opacity(0.8)
                    .ignoresSafeArea()
                
                Card {
                    VStack(spacing: 24) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(.tint)
                        
                        VStack(spacing: 8) {
                            Text(title)
                                .font(.title3).bold()
                            
                            Text(subtitle)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        
                        if let product = productManager.subscriptionProduct {
                            VStack(spacing: 16) {
                                VStack(spacing: 4) {
                                    BrandButton(
                                        "Subscribe \(product.displayPrice)/mo",
                                        action: handleSubscribe
                                    )
                                    .primary
                                    
                                    Text(isTrialEligible ?
                                        "Monthly Subscription 7 days free, then \(product.displayPrice)/mo" :
                                        "Monthly Subscription \(product.displayPrice)/mo"
                                    )
                                    .font(.footnote).bold()
                                    .multilineTextAlignment(.center)
                                }
                                
                                HStack(spacing: 12) {
                                    Link("Terms of Use", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                                    Text("•")
                                    Link("Privacy Policy", destination: URL(string: "https://www.vinceratraining.com/privacy")!)
                                    Text("•")
                                    Button("Restore") {
                                        Task { try? await productManager.restorePurchases() }
                                    }
                                }
                                .font(.caption2)
                                .foregroundStyle(.tint)
                                
                                Text("Payment will be charged to your iTunes Account at confirmation of purchase. Subscription automatically renews unless auto-renew is turned off at least 24-hours before the end of the current period.")
                                    .font(.system(size: 10))
                                    .foregroundStyle(.tertiary)
                                    .multilineTextAlignment(.center)
                            }
                        } else {
                            ProgressView()
                        }
                    }
                    .padding(.vertical, 8)
                }
                .padding(.horizontal, PADDING_INLINE)
            }
            .sheet(isPresented: $isAccountPresented) {
                NavigationStack {
                    AccountScreen()
                }
            }
        }
    
    private func handleSubscribe() {
        Task {
            do {
                try await productManager.subscribe()
            } catch {
                if let skError = error as? SKError, skError.code == .paymentCancelled {
                    return // Do nothing if they just hit 'Cancel'
                }
                Router.shared.toast(
                    "Error occurred while subscribing",
                    subtitle: "Please contact support.",
                    type: .error
                )
            }
        }
    }
}

private struct LoadingView: View {
    var body: some View {
        Color.background.ignoresSafeArea()
    }
}

#Preview {
    LockedView()
//    SubscriptionStoreView(productIDs: [SUBSCRIPTION_ID])
}
