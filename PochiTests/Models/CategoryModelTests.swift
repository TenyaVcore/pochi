//
//  CategoryModelTests.swift
//  PochiTests
//
//  Created by Claude Code on 2025/06/28.
//

import Testing
import Foundation
@testable import Pochi

/// TDD Red Phase: Categoryドメインモデルのテスト
///
/// このテストは意図的に失敗するように作成されています。
/// Category列挙型が実装されるまでコンパイルエラーになります。
@Suite("Category Domain Model Tests")
struct CategoryModelTests {
    
    @Test("Category全ケース確認")
    func categoryAllCases() async throws {
        // ❌ Category列挙型がまだ存在しないためコンパイルエラー
        let allCategories = Category.allCases
        
        #expect(allCategories.count == 7)
        #expect(allCategories.contains(.refrigerated))
        #expect(allCategories.contains(.frozen))
        #expect(allCategories.contains(.pantry))
        #expect(allCategories.contains(.beverages))
        #expect(allCategories.contains(.snacks))
        #expect(allCategories.contains(.seasonings))
        #expect(allCategories.contains(.other))
    }
    
    @Test("CategoryのrawValue確認")
    func categoryRawValues() async throws {
        // ❌ Category列挙型のrawValueが存在しない
        #expect(Category.refrigerated.rawValue == "冷蔵")
        #expect(Category.frozen.rawValue == "冷凍")
        #expect(Category.pantry.rawValue == "常温")
        #expect(Category.beverages.rawValue == "飲み物")
        #expect(Category.snacks.rawValue == "お菓子")
        #expect(Category.seasonings.rawValue == "調味料")
        #expect(Category.other.rawValue == "その他")
    }
    
    @Test("CategoryのdisplayName確認")
    func categoryDisplayName() async throws {
        // ❌ Category列挙型のdisplayNameプロパティが存在しない
        #expect(Category.refrigerated.displayName == "冷蔵")
        #expect(Category.frozen.displayName == "冷凍")
        #expect(Category.pantry.displayName == "常温")
        #expect(Category.beverages.displayName == "飲み物")
        #expect(Category.snacks.displayName == "お菓子")
        #expect(Category.seasonings.displayName == "調味料")
        #expect(Category.other.displayName == "その他")
    }
    
    @Test("Category Sendable準拠確認")
    func categorySendable() async throws {
        // ❌ Category列挙型がSendableに準拠していない（Swift 6.0 Concurrency）
        let category = Category.refrigerated
        
        // Sendable準拠の確認（コンパイル時チェック）
        await withCheckedContinuation { continuation in
            Task {
                let copiedCategory = category // Sendableでないとここでエラー
                #expect(copiedCategory == .refrigerated)
                continuation.resume()
            }
        }
    }
    
    @Test("CategoryのCaseIterable準拠確認")
    func categoryCaseIterable() async throws {
        // ❌ Category列挙型がCaseIterableに準拠していない
        let categories = Category.allCases
        
        #expect(categories.first == .refrigerated)
        #expect(categories.last == .other)
        #expect(categories.count == 7)
    }
    
    @Test("Categoryの初期化テスト")
    func categoryInitFromRawValue() async throws {
        // ❌ Category列挙型のrawValue初期化が存在しない
        let refrigerated = Category(rawValue: "冷蔵")
        let frozen = Category(rawValue: "冷凍")
        let invalid = Category(rawValue: "存在しない")
        
        #expect(refrigerated == .refrigerated)
        #expect(frozen == .frozen)
        #expect(invalid == nil)
    }
}