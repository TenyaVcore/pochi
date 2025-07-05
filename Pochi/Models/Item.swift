//
//  Item.swift
//  Pochi
//
//  Created by Pochi Team on 2025/06/21.
//

import Foundation

struct Item: Equatable, Identifiable, Sendable {
  let id: UUID
  var name: String
  var category: Category
  var quantity: Int
  var expiryDate: Date?
  var imageData: Data?
  var memo: String?
  var createdAt: Date
  var updatedAt: Date
  
  init(
    id: UUID = UUID(),
    name: String,
    category: Category,
    quantity: Int,
    expiryDate: Date? = nil,
    imageData: Data? = nil,
    memo: String? = nil,
    createdAt: Date = Date(),
    updatedAt: Date = Date()
  ) {
    self.id = id
    self.name = name
    self.category = category
    self.quantity = quantity
    self.expiryDate = expiryDate
    self.imageData = imageData
    self.memo = memo
    self.createdAt = createdAt
    self.updatedAt = updatedAt
  }
}

// MARK: - Category

enum Category: String, CaseIterable, Sendable {
  case refrigerated = "冷蔵"
  case frozen = "冷凍"
  case pantry = "常温"
  case beverages = "飲み物"
  case snacks = "お菓子"
  case seasonings = "調味料"
  case other = "その他"
}
