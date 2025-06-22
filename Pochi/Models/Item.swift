//
//  Item.swift
//  Pochi
//
//  Created by Pochi Team on 2025/06/21.
//

import Foundation

// MARK: - Core Domain Models

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
  case refrigerated = "refrigerated"    // 冷蔵
  case frozen = "frozen"               // 冷凍
  case pantry = "pantry"               // 常温
  case beverages = "beverages"         // 飲料
  case snacks = "snacks"              // お菓子
  case seasonings = "seasonings"       // 調味料
  case other = "other"                // その他
  
  var displayName: String {
    switch self {
    case .refrigerated: return "冷蔵"
    case .frozen: return "冷凍"
    case .pantry: return "常温"
    case .beverages: return "飲料"
    case .snacks: return "お菓子"
    case .seasonings: return "調味料"
    case .other: return "その他"
    }
  }
  
  var icon: String {
    switch self {
    case .refrigerated: return "refrigerator"
    case .frozen: return "snowflake"
    case .pantry: return "cabinet"
    case .beverages: return "cup.and.saucer"
    case .snacks: return "birthday.cake"
    case .seasonings: return "drop"
    case .other: return "questionmark.circle"
    }
  }
}

// MARK: - Expiry Status

enum ExpiryStatus: Equatable, Sendable {
  case fresh
  case expiringSoon(days: Int)
  case expired(days: Int)
  case noExpiry
  
  var displayText: String {
    switch self {
    case .fresh:
      return "新鮮"
    case .expiringSoon(let days):
      return "\(days)日後期限切れ"
    case .expired(let days):
      return "\(days)日前に期限切れ"
    case .noExpiry:
      return "期限なし"
    }
  }
  
  var color: String {
    switch self {
    case .fresh, .noExpiry:
      return "systemGreen"
    case .expiringSoon:
      return "systemOrange"
    case .expired:
      return "systemRed"
    }
  }
  
  var icon: String {
    switch self {
    case .fresh, .noExpiry:
      return "checkmark.circle"
    case .expiringSoon:
      return "exclamationmark.triangle"
    case .expired:
      return "xmark.circle"
    }
  }
}

// MARK: - Sort Order

enum SortOrder: String, CaseIterable, Sendable {
  case name = "name"
  case createdAt = "createdAt"
  case updatedAt = "updatedAt"
  case expiryDate = "expiryDate"
  case quantity = "quantity"
  case category = "category"
  
  var displayName: String {
    switch self {
    case .name: return "商品名"
    case .createdAt: return "作成日"
    case .updatedAt: return "更新日"
    case .expiryDate: return "賞味期限"
    case .quantity: return "在庫数"
    case .category: return "カテゴリー"
    }
  }
  
  var comparator: (Item, Item) -> Bool {
    switch self {
    case .name:
      return { $0.name < $1.name }
    case .createdAt:
      return { $0.createdAt > $1.createdAt }
    case .updatedAt:
      return { $0.updatedAt > $1.updatedAt }
    case .expiryDate:
      return { lhs, rhs in
        switch (lhs.expiryDate, rhs.expiryDate) {
        case (nil, nil): return false
        case (nil, _): return false
        case (_, nil): return true
        case let (lhsDate?, rhsDate?): return lhsDate < rhsDate
        }
      }
    case .quantity:
      return { $0.quantity < $1.quantity }
    case .category:
      return { $0.category.displayName < $1.category.displayName }
    }
  }
}

// MARK: - Extensions

extension Item {
  var expiryStatus: ExpiryStatus {
    ExpiryCalculator.status(for: expiryDate)
  }
  
  var isOutOfStock: Bool {
    quantity <= 0
  }
  
  var isExpiringSoon: Bool {
    if case .expiringSoon = expiryStatus {
      return true
    }
    return false
  }
  
  var isExpired: Bool {
    if case .expired = expiryStatus {
      return true
    }
    return false
  }
}

// MARK: - Expiry Calculator

struct ExpiryCalculator: Sendable {
  static func status(for expiryDate: Date?) -> ExpiryStatus {
    guard let expiryDate = expiryDate else {
      return .noExpiry
    }
    
    let daysUntilExpiry = daysUntilExpiry(expiryDate)
    
    if daysUntilExpiry < 0 {
      return .expired(days: abs(daysUntilExpiry))
    } else if daysUntilExpiry <= 3 {
      return .expiringSoon(days: daysUntilExpiry)
    } else {
      return .fresh
    }
  }
  
  static func daysUntilExpiry(_ date: Date) -> Int {
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    let expiryDay = calendar.startOfDay(for: date)
    
    let components = calendar.dateComponents([.day], from: today, to: expiryDay)
    return components.day ?? 0
  }
  
  static func isExpiringSoon(_ date: Date, threshold: Int = 3) -> Bool {
    daysUntilExpiry(date) <= threshold && daysUntilExpiry(date) >= 0
  }
  
  static func isExpired(_ date: Date) -> Bool {
    daysUntilExpiry(date) < 0
  }
}