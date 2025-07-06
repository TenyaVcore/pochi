//
//  InventoryFeatureTests.swift
//  PochiTests
//
//  Created by Claude Code on 2025/06/28.
//

import Testing
import ComposableArchitecture
import Foundation
@testable import Pochi

@Suite("InventoryFeature Tests")
struct InventoryFeatureTests {
    
    @Test("アイテム読み込みテスト")
    func itemsLoading() async throws {
        let testItems = [
            Item(name: "牛乳", category: .refrigerated, quantity: 1),
            Item(name: "パン", category: .pantry, quantity: 2)
        ]
        
        let store = TestStore(initialState: InventoryFeature.State()) {
            InventoryFeature()
        } withDependencies: {
            $0.database.fetchItems = { testItems }
        }
        
        await store.send(\.view.onAppear) {
            $0.isLoading = true
        }
        
        await store.receive(\.fetchItemsResponse.success) {
            $0.isLoading = false
            $0.items = testItems
        }
    }
    
    @Test("検索機能テスト")
    func searchFunctionality() async throws {
        let testItems = [
            Item(name: "牛乳", category: .refrigerated, quantity: 1),
            Item(name: "豆乳", category: .refrigerated, quantity: 1),
            Item(name: "パン", category: .pantry, quantity: 2)
        ]
        
        let store = TestStore(initialState: InventoryFeature.State(items: testItems)) {
            InventoryFeature()
        }
        
        await store.send(\.view.searchTextChanged, "牛") {
            $0.searchText = "牛"
        }
        
        // フィルタされたアイテムの確認
        #expect(store.state.filteredItems.count == 2)
        #expect(store.state.filteredItems.allSatisfy { $0.name.contains("牛") })
    }
    
    @Test("カテゴリフィルタテスト") 
    func categoryFilter() async throws {
        let testItems = [
            Item(name: "牛乳", category: .refrigerated, quantity: 1),
            Item(name: "パン", category: .pantry, quantity: 2),
            Item(name: "アイス", category: .frozen, quantity: 3)
        ]
        
        let store = TestStore(initialState: InventoryFeature.State(items: testItems)) {
            InventoryFeature()
        }
        
        await store.send(\.view.categoryFilterChanged, Category.refrigerated) {
            $0.selectedCategory = .refrigerated
        }
        
        // フィルタされたアイテムの確認
        #expect(store.state.filteredItems.count == 1)
        #expect(store.state.filteredItems.first?.category == .refrigerated)
    }
    
    @Test("数量増加テスト")
    func incrementQuantity() async throws {
        let testItem = Item(name: "牛乳", category: .refrigerated, quantity: 1)
        let updatedItem = Item(
            id: testItem.id,
            name: testItem.name,
            category: testItem.category,
            quantity: 2,
            expiryDate: testItem.expiryDate,
            imageData: testItem.imageData,
            memo: testItem.memo,
            createdAt: testItem.createdAt,
            updatedAt: fixedDate
        )
        let fixedDate = Date(timeIntervalSince1970: 0)
        
        let store = TestStore(initialState: InventoryFeature.State(items: [testItem])) {
            InventoryFeature()
        } withDependencies: {
            $0.database.updateQuantity = { id, quantity in
                #expect(id == testItem.id)
                #expect(quantity == 2)
                return updatedItem
            }
        }
        
        await store.send(\.view.incrementQuantity, testItem.id)
        
        await store.receive(\.updateQuantityResponse.success) {
            $0.items = [updatedItem]
        }
    }
    
    @Test("数量減少テスト")
    func decrementQuantity() async throws {
        let testItem = Item(name: "牛乳", category: .refrigerated, quantity: 2)
        let updatedItem = Item(
            id: testItem.id,
            name: testItem.name,
            category: testItem.category,
            quantity: 1,
            expiryDate: testItem.expiryDate,
            imageData: testItem.imageData,
            memo: testItem.memo,
            createdAt: testItem.createdAt,
            updatedAt: Date()
        )
        
        let store = TestStore(initialState: InventoryFeature.State(items: [testItem])) {
            InventoryFeature()
        } withDependencies: {
            $0.database.updateQuantity = { id, quantity in
                #expect(id == testItem.id)
                #expect(quantity == 1)
                return updatedItem
            }
        }
        
        await store.send(\.view.decrementQuantity, testItem.id)
        
        await store.receive(\.updateQuantityResponse.success) {
            $0.items = [updatedItem]
        }
    }
    
    @Test("数量減少境界値テスト - 0以下にはならない")
    func decrementQuantityBoundary() async throws {
        let testItem = Item(name: "牛乳", category: .refrigerated, quantity: 0)
        
        let store = TestStore(initialState: InventoryFeature.State(items: [testItem])) {
            InventoryFeature()
        }
        
        await store.send(\.view.decrementQuantity, testItem.id)
        // 数量が0の場合は何もしない
    }
    
    @Test("アイテム詳細遷移テスト")
    func itemDetailNavigation() async throws {
        let testItem = Item(name: "牛乳", category: .refrigerated, quantity: 1)
        
        let store = TestStore(initialState: InventoryFeature.State(items: [testItem])) {
            InventoryFeature()
        }
        
        await store.send(\.view.itemTapped, testItem) {
            $0.itemDetail = ItemDetailFeature.State(item: testItem)
        }
    }
    
    @Test("商品追加画面遷移テスト")
    func addItemNavigation() async throws {
        let store = TestStore(initialState: InventoryFeature.State()) {
            InventoryFeature()
        }
        
        await store.send(\.view.addItemTapped) {
            $0.addItem = AddItemFeature.State()
        }
    }
    
    @Test("リフレッシュテスト")
    func refresh() async throws {
        let testItems = [
            Item(name: "牛乳", category: .refrigerated, quantity: 1)
        ]
        
        let store = TestStore(initialState: InventoryFeature.State()) {
            InventoryFeature()
        } withDependencies: {
            $0.database.fetchItems = { testItems }
        }
        
        await store.send(\.view.refreshTapped) {
            $0.isLoading = true
        }
        
        await store.receive(\.fetchItemsResponse.success) {
            $0.isLoading = false
            $0.items = testItems
        }
    }
    
    @Test("エラーハンドリングテスト")
    func errorHandling() async throws {
        let store = TestStore(initialState: InventoryFeature.State()) {
            InventoryFeature()
        } withDependencies: {
            $0.database.fetchItems = { 
                throw NSError(domain: "TestError", code: 1, userInfo: [:])
            }
        }
        
        await store.send(\.view.onAppear) {
            $0.isLoading = true
        }
        
        await store.receive(\.fetchItemsResponse.failure) {
            $0.isLoading = false
            $0.errorMessage = "データの取得に失敗しました"
        }
    }
}