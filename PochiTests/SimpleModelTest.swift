//
//  SimpleModelTest.swift
//  PochiTests
//
//  Created by Claude Code on 2025/06/28.
//

import Testing
import Foundation
@testable import Pochi

@Suite("Simple Model Tests")
struct SimpleModelTest {
    
    @Test("Category enum basic test")
    func categoryBasicTest() async throws {
        let category = Category.refrigerated
        #expect(category.rawValue == "冷蔵")
        // displayNameは後で実装予定
    }
    
    @Test("Item basic test")
    func itemBasicTest() async throws {
        let item = Item(
            name: "Test Item",
            category: .refrigerated,
            quantity: 1
        )
        
        #expect(item.name == "Test Item")
        #expect(item.category == .refrigerated)
        #expect(item.quantity == 1)
    }
}