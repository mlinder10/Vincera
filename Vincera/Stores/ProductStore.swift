//
//  ProductStore.swift
//  Vincera
//
//  Created by Matt Linder on 2/22/25.
//

import Foundation

final class ProductStore: ObservableObject {
    @Published var products: [Product]
    
    init() {
        let products: [Product]? = try? StorageManager.shared.read(.products)
        self.products = products ?? []
    }
    
    func purchase(_ productId: String) throws {
        if products.contains(where: { $0.id == productId }) { return }
        let newProduct = Product(id: productId, date: Date())
        products.append(newProduct)
        try StorageManager.shared.write(.products, products)
    }
    
    func hasPurchased(_ productId: String) -> Bool {
        return products.contains(where: { $0.id == productId })
    }
}

struct Product: Codable & Identifiable {
    let id: String
    let date: Date
}
