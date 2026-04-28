//
//  PremiumSplitCell.swift
//  Vincera
//
//  Created by Matt Linder on 8/1/25.
//

import SwiftUI
import StoreKit

struct PremiumSplitCell: View {
    @ObservedObject private var productManager = ProductManager.shared
    let split: PremiumSplit
    private var product: Product? {
        ProductManager.shared.getProduct(id: split.productId)
    }
    
    var body: some View {
        Group {
            if productManager.hasPurchased(split.productId) {
                SplitCell(split: split.split)
            } else if let product {
                LockedOverlay(split: split, product: product)
            } else {
                EmptyView()
            }
        }
    }
}

fileprivate struct LockedOverlay: View {
    let split: PremiumSplit
    let product: Product
    @State private var isPurchasing = false
    
    var body: some View {
        Card {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text(split.split.name)
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text(split.split.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                BrandButton(
                    isPurchasing ? "Processing..." : product.displayPrice,
                    action: handlePurchase
                )
                .primary
                .disabled(isPurchasing)
                .buttonBorderShape(.capsule)
            }
            .padding()
        }
    }
    
    private func handlePurchase() {
        isPurchasing = true
        Task {
            defer { isPurchasing = false }
            do {
                if let tx = try await ProductManager.shared.purchase(split.productId) {
                    await tx.finish()
                }
            } catch {
                // You should ideally trigger a toast/alert here
                print("Purchase failed: \(error)")
            }
        }
    }
}
