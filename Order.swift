//
//  Order.swift
//  online grocery store
//
//  Created by Sayaka Alam on 7/4/26.
//

import Foundation

struct Order: Identifiable, Codable {
    var id: String
    var userId: String
    var items: [CartItem]
    var totalAmount: Double
    var status: String      // "pending", "confirmed", "delivered"
    var createdAt: Date
    var address: String
    var phone: String
    var note: String
}
