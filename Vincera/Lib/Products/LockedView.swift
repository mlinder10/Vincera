//
//  LockedView.swift
//  Vincera
//
//  Created by Matt Linder on 4/17/26.
//

import SwiftUI
import StoreKit

// Subscription is called Vincera Membership

struct LockedView: View {
    @EnvironmentObject private var productManager: ProductManager
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
    @EnvironmentObject private var productManager: ProductManager
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
                VStack(spacing: 16) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(.tint)
                    
                    VStack(spacing: 4) {
                        Text(title)
                            .font(.title3).bold()
                        
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    if let monthlySub = productManager.monthlySubProduct,
                       let yearlySub = productManager.yearlySubProduct {
                        priceView2(monthlySub: monthlySub, yearlySub: yearlySub)
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
    
    private var infoView: some View {
        VStack(spacing: 4) {
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
    }
    
    private func priceView(monthlySub: Product, yearlySub: Product) -> some View {
        VStack(spacing: 16) {
            VStack(spacing: 4) {
                BrandButton("Subscribe \(monthlySub.displayPrice)/mo") {
                    handleSubscribe(plan: .monthly)
                }
                .primary
                
                Text(isTrialEligible ?
                     "Monthly Subscription 7 days free, then \(monthlySub.displayPrice)/mo" :
                        "Monthly Subscription \(monthlySub.displayPrice)/mo"
                )
                .font(.footnote).bold()
                .multilineTextAlignment(.center)
            }
            
            infoView
        }
    }
    
    private func priceView2(monthlySub: Product, yearlySub: Product) -> some View {
        // 1. Calculate savings percentage
        let totalMonthly = monthlySub.price * 12
        let diff = totalMonthly - yearlySub.price
        let rawPercentage = (diff / totalMonthly) * 100
        
        var rounded = Decimal()
        var mutablePercentage = rawPercentage
        let _ = NSDecimalRound(&rounded, &mutablePercentage, 0, .plain)
        let percentage = NSDecimalNumber(decimal: rounded).intValue

        return VStack(spacing: 24) {
            VStack(spacing: 12) {
                VStack(spacing: 0) {
                    Text("SAVE \(percentage)%")
                        .font(.caption2).bold()
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.accent)
                        .foregroundStyle(.white)
                        .cornerRadius(8)
                        .offset(y: 10)
                        .zIndex(1)
                    
                    BrandButton("Yearly • \(yearlySub.displayPrice)/yr") {
                        handleSubscribe(plan: .yearly)
                    }
                    .primary
                }
                BrandButton("Monthly • \(monthlySub.displayPrice)/mo") {
                    handleSubscribe(plan: .monthly)
                }
                .outline
                
                if isTrialEligible {
                    Text("Includes 7-day free trial")
                        .font(.caption)
                        .fontWeight(.semibold)
//                        .foregroundStyle(.secondary)
                }
            }
            
            infoView
        }
    }
    
    private func handleSubscribe(plan: Subscription) {
        Task {
            do {
                try await productManager.subscribe(plan: plan)
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
