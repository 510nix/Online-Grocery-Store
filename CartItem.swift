//
//  CartItem.swift
//  online grocery store
//
//  Created by Sayaka Alam on 7/4/26.
//

import Foundation

struct CartItem: Identifiable, Codable {
    var id: String
    var product: Product
    var quantity: Int
    
    var totalPrice: Double {
        return product.price * Double(quantity)
    }
}
