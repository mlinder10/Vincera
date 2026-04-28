//
//  SettingsPage.swift
//  Vincera
//
//  Created by Matt Linder on 4/18/26.
//

import SwiftUI

struct AccountScreen: View {
    @ObservedObject private var productManager = ProductManager.shared
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                SectionTitle("Our Platform")
                BrandButton("Privacy Policy & Terms of Service") {
                    if let url = URL(string: "https://www.vinceratraining.com/privacy") {
                        openURL(url)
                    }
                }
                .secondary
                
                BrandButton("Contact Support") {
                    if let url = URL(string: "https://www.vinceratraining.com/#contact") {
                        openURL(url)
                    }
                }
                .secondary
            }
            
            VStack {
                SectionTitle("In App Purchases")
                BrandButton(
                    "Restore Purchases",
                    action: handleRestorePurchases
                )
                .secondary
            }
            
            if productManager.isSubscribed ?? false {
                VStack {
                    SectionTitle("Subscription")
                    BrandButton(
                        "Cancel Subscription",
                        role: .destructive,
                        action: handleCancelSubscription
                    )
                    .secondary
                }
            }
            
            Spacer()
        }
        .padding(.top, PADDING_TOP)
        .padding(.horizontal, PADDING_INLINE)
        .navigationTitle("Account Management")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func handleRestorePurchases() {
        Task {
            do {
                try await productManager.restorePurchases()
                Router.shared.toast("Purchases restored", type: .success)
            } catch {
                Router.shared.toast(
                    "Failed to restore purchases",
                    subtitle: "Please contact support.",
                    type: .error
                )
            }
        }
    }
    
    private func handleCancelSubscription() {
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
