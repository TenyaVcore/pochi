//
//  ShoppingItem.swift
//  Pochi
//
//  Created by Pochi Team on 2025/06/21.
//

import Foundation

// MARK: - Shopping Item

struct ShoppingItem: Equatable, Identifiable, Sendable {
  let id: UUID
  var name: String
  var category: Category
  var quantity: Int
  var memo: String?
  var isChecked: Bool
  var addedFrom: AddedFrom
  var createdAt: Date
  var updatedAt: Date
  
  init(
    id: UUID = UUID(),
    name: String,
    category: Category = .other,
    quantity: Int = 1,
    memo: String? = nil,
    isChecked: Bool = false,
    addedFrom: AddedFrom = .manual,
    createdAt: Date = Date(),
    updatedAt: Date = Date()
  ) {
    self.id = id
    self.name = name
    self.category = category
    self.quantity = quantity
    self.memo = memo
    self.isChecked = isChecked
    self.addedFrom = addedFrom
    self.createdAt = createdAt
    self.updatedAt = updatedAt
  }
}

// MARK: - Added From

enum AddedFrom: String, CaseIterable, Sendable {
  case manual = "manual"       // 手動追加
  case automatic = "automatic" // 自動追加（在庫切れ時）
  case scan = "scan"          // スキャンから追加
  
  var displayName: String {
    switch self {
    case .manual: return "手動追加"
    case .automatic: return "自動追加"
    case .scan: return "スキャン追加"
    }
  }
  
  var icon: String {
    switch self {
    case .manual: return "plus.circle"
    case .automatic: return "arrow.clockwise.circle"
    case .scan: return "camera.circle"
    }
  }
}

// MARK: - Extensions

extension ShoppingItem {
  var displayQuantity: String {
    "\(quantity)個"
  }
  
  mutating func check() {
    isChecked = true
    updatedAt = Date()
  }
  
  mutating func uncheck() {
    isChecked = false
    updatedAt = Date()
  }
  
  mutating func updateQuantity(_ newQuantity: Int) {
    quantity = max(1, newQuantity)
    updatedAt = Date()
  }
}

// MARK: - Shopping List Statistics

struct ShoppingListStatistics: Equatable, Sendable {
  let totalItems: Int
  let checkedItems: Int
  let pendingItems: Int
  
  var completionPercentage: Double {
    guard totalItems > 0 else { return 0 }
    return Double(checkedItems) / Double(totalItems)
  }
  
  var displayText: String {
    "\(totalItems)個のアイテム（\(checkedItems)個完了）"
  }
  
  init(items: [ShoppingItem]) {
    self.totalItems = items.count
    self.checkedItems = items.filter(\.isChecked).count
    self.pendingItems = totalItems - checkedItems
  }
}