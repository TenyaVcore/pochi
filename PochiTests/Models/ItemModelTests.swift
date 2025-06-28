//
//  ItemModelTests.swift
//  PochiTests
//
//  Created by Claude Code on 2025/06/28.
//

import Testing
import Foundation
@testable import Pochi

/// TDD Red Phase: Itemドメインモデルのテスト
///
/// このテストは意図的に失敗するように作成されています。
/// Item構造体が実装されるまでコンパイルエラーになります。
@Suite("Item Domain Model Tests")
struct ItemModelTests {
    
    @Test("Item初期化テスト")
    func itemInitialization() async throws {
        // ❌ Item構造体がまだ存在しないためコンパイルエラー
        let item = Item(
            id: UUID(),
            name: "牛乳",
            category: .refrigerated,  // ❌ Category列挙型も存在しない
            quantity: 1,
            expiryDate: Date().addingTimeInterval(86400 * 7), // 1週間後
            createdAt: Date(),
            updatedAt: Date(),
            imageData: nil
        )
        
        #expect(item.name == "牛乳")
        #expect(item.category == .refrigerated)
        #expect(item.quantity == 1)
        #expect(item.expiryDate != nil)
    }
    
    @Test("Itemのデフォルト値テスト")
    func itemDefaultValues() async throws {
        // ❌ Item構造体の便利イニシャライザが存在しない
        let item = Item(
            name: "テスト商品",
            category: .pantry,
            quantity: 2
        )
        
        #expect(item.name == "テスト商品")
        #expect(item.category == .pantry)
        #expect(item.quantity == 2)
        let anotherItem = Item(
            name: "別の商品",
            category: .pantry,
            quantity: 1
        )
        
        #expect(item.id != anotherItem.id) // ユニークなIDが生成される
        #expect(item.createdAt <= Date()) // 現在時刻以前
        #expect(item.updatedAt <= Date()) // 現在時刻以前
        #expect(item.expiryDate == nil) // デフォルトはnil
        #expect(item.imageData == nil) // デフォルトはnil
    }
    
    @Test("Item Equatable テスト")
    func itemEquatable() async throws {
        let id = UUID()
        let date = Date()
        
        // ❌ Item構造体がEquatableに準拠していない
        let item1 = Item(
            id: id,
            name: "同じ商品",
            category: .refrigerated,
            quantity: 1,
            expiryDate: nil,
            createdAt: date,
            updatedAt: date,
            imageData: nil
        )
        
        let item2 = Item(
            id: id,
            name: "同じ商品",
            category: .refrigerated,
            quantity: 1,
            expiryDate: nil,
            createdAt: date,
            updatedAt: date,
            imageData: nil
        )
        
        #expect(item1 == item2)
    }
    
    @Test("Item Identifiable テスト")
    func itemIdentifiable() async throws {
        // ❌ Item構造体がIdentifiableに準拠していない
        let item = Item(
            name: "ID確認商品",
            category: .other,
            quantity: 1
        )
        
        #expect(item.id is UUID)
    }
    
    @Test("Item Sendable テスト")
    func itemSendable() async throws {
        // ❌ Item構造体がSendableに準拠していない（Swift 6.0 Concurrency）
        let item = Item(
            name: "並行処理テスト商品",
            category: .frozen,
            quantity: 5
        )
        
        // Sendable準拠の確認（コンパイル時チェック）
        await withCheckedContinuation { continuation in
            Task {
                let copiedItem = item // Sendableでないとここでエラー
                #expect(copiedItem.name == "並行処理テスト商品")
                continuation.resume()
            }
        }
    }
}