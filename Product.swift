//
//  Product.swift
//  online grocery store
//
//  Created by Sayaka Alam on 7/4/26.
//

import Foundation

struct Product: Identifiable, Codable {
    var id: String
    var name: String
    var category: String
    var price: Double
    var imageURL: String
    var description: String
    var unit: String        // e.g. "kg", "piece", "pack"
    var isAvailable: Bool
    var stock: Int
}
