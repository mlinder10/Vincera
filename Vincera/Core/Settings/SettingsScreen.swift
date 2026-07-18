//
//  SettingsScreen.swift
//  Vincera
//
//  Created by Matt Linder on 4/18/26.
//

import SwiftUI

struct SettingsScreen: View {
    @EnvironmentObject private var productManager: ProductManager
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        ScrollView {
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
                
                VStack(spacing: 16) {
                    SectionTitle("In App Purchases")
                    BrandButton(
                        "Restore Purchases",
                        action: handleRestorePurchases
                    )
                    .secondary
                    
                    BrandButton("Manage Subscription") {
                        Router.shared.push(ManageSubscriptionRoute())
                    }
                    .secondary
                }
                
                VStack(spacing: 16) {
                    SectionTitle("Your Data") {
                        DetailView(
                            icon: "cylinder.split.1x2",
                            title: "Managing Your Data",
                            description:
                                "Vinceara stores all of your data locally on your device--meaning that no one else has access to it." +
                            " Because of this, if you ever switch devices or delete the app, you will lose all of your data." +
                            
                            "\n\nTo avoid this, you can export your data to a .json file which can then be imported on another device. " +
                            
                            "\n\nYou can also delete all of your data at any time."
                        ) {
                            Label("Important", systemImage: "info.circle.fill")
                        }
                    }
                    ImportButton()
                    ExportButton()
                    DeleteButton()
                }
                
                Spacer()
            }
            .padding(.top, PADDING_TOP)
            .padding(.horizontal, PADDING_INLINE)
        }
        .navigationTitle("Settings")
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
}
