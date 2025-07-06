//
//  InventoryFeatureTests.swift
//  PochiTests
//
//  Created by Claude Code on 2025/06/28.
//

import Testing
import ComposableArchitecture
@testable import Pochi

/// TDD Red Phase: InventoryFeatureのテスト
///
/// このテストは意図的に失敗するように作成されています。
/// InventoryFeature Reducerが実装されるまでコンパイルエラーになります。
//@Suite("InventoryFeature Tests")
//struct InventoryFeatureTests {
//    
//    @Test("アイテム読み込みテスト")
//    func itemsLoading() async throws {
//        // ❌ InventoryFeature構造体がまだ存在しないためコンパイルエラー
//        let store = TestStore(initialState: InventoryFeature.State()) {
//            InventoryFeature()
//        } withDependencies: {
//            // ❌ DatabaseClientのtestValueが存在しない
//            $0.database.fetchItems = { 
//                [
//                    Item(name: "牛乳", category: .refrigerated, quantity: 1),
//                    Item(name: "パン", category: .pantry, quantity: 2)
//                ]
//            }
//        }
//        
//        await store.send(.view(.onAppear)) {
//            $0.isLoading = true
//        }
//        
//        await store.receive(.itemsLoaded([
//            Item(name: "牛乳", category: .refrigerated, quantity: 1),
//            Item(name: "パン", category: .pantry, quantity: 2)
//        ])) {
//            $0.isLoading = false
//            $0.items = IdentifiedArrayOf([
//                Item(name: "牛乳", category: .refrigerated, quantity: 1),
//                Item(name: "パン", category: .pantry, quantity: 2)
//            ])
//        }
//    }
//    
//    @Test("検索機能テスト")
//    func searchFunctionality() async throws {
//        // ❌ InventoryFeature.StateのsearchQueryプロパティが存在しない
//        let initialState = InventoryFeature.State(
//            items: IdentifiedArrayOf([
//                Item(name: "牛乳", category: .refrigerated, quantity: 1),
//                Item(name: "豆乳", category: .refrigerated, quantity: 1),
//                Item(name: "パン", category: .pantry, quantity: 2)
//            ])
//        )
//        
//        let store = TestStore(initialState: initialState) {
//            InventoryFeature()
//        }
//        
//        await store.send(.view(.searchQueryChanged("牛"))) {
//            $0.searchQuery = "牛"
//        }
//        
//        // フィルタされたアイテムの確認
//        #expect(store.state.filteredItems.count == 1)
//        #expect(store.state.filteredItems.first?.name == "牛乳")
//    }
//    
//    @Test("カテゴリフィルタテスト")
//    func categoryFilter() async throws {
//        // ❌ InventoryFeature.StateのselectedCategoryプロパティが存在しない
//        let initialState = InventoryFeature.State(
//            items: IdentifiedArrayOf([
//                Item(name: "牛乳", category: .refrigerated, quantity: 1),
//                Item(name: "パン", category: .pantry, quantity: 2),
//                Item(name: "アイス", category: .frozen, quantity: 3)
//            ])
//        )
//        
//        let store = TestStore(initialState: initialState) {
//            InventoryFeature()
//        }
//        
//        await store.send(.view(.categorySelected(.refrigerated))) {
//            $0.selectedCategory = .refrigerated
//        }
//        
//        // フィルタされたアイテムの確認
//        #expect(store.state.filteredItems.count == 1)
//        #expect(store.state.filteredItems.first?.category == .refrigerated)
//    }
//    
//    @Test("数量増加テスト")
//    func incrementQuantity() async throws {
//        let testItem = Item(name: "牛乳", category: .refrigerated, quantity: 1)
//        let initialState = InventoryFeature.State(
//            items: IdentifiedArrayOf([testItem])
//        )
//        
//        let store = TestStore(initialState: initialState) {
//            InventoryFeature()
//        } withDependencies: {
//            // ❌ DatabaseClientのupdateQuantityメソッドが存在しない
//            $0.database.updateQuantity = { id, newQuantity in
//                // モック実装
//            }
//        }
//        
//        await store.send(.view(.incrementQuantity(testItem.id))) {
//            $0.items[id: testItem.id]?.quantity = 2
//        }
//    }
//    
//    @Test("数量減少テスト")
//    func decrementQuantity() async throws {
//        let testItem = Item(name: "牛乳", category: .refrigerated, quantity: 2)
//        let initialState = InventoryFeature.State(
//            items: IdentifiedArrayOf([testItem])
//        )
//        
//        let store = TestStore(initialState: initialState) {
//            InventoryFeature()
//        } withDependencies: {
//            $0.database.updateQuantity = { id, newQuantity in
//                // モック実装
//            }
//        }
//        
//        await store.send(.view(.decrementQuantity(testItem.id))) {
//            $0.items[id: testItem.id]?.quantity = 1
//        }
//    }
//    
//    @Test("アイテム削除テスト")
//    func deleteItem() async throws {
//        let testItem = Item(name: "牛乳", category: .refrigerated, quantity: 1)
//        let initialState = InventoryFeature.State(
//            items: IdentifiedArrayOf([testItem])
//        )
//        
//        let store = TestStore(initialState: initialState) {
//            InventoryFeature()
//        } withDependencies: {
//            // ❌ DatabaseClientのdeleteItemメソッドが存在しない
//            $0.database.deleteItem = { id in
//                // モック実装
//            }
//        }
//        
//        await store.send(.view(.deleteItem(testItem.id))) {
//            $0.items.remove(id: testItem.id)
//        }
//        
//        #expect(store.state.items.isEmpty)
//    }
//    
//    @Test("アイテム詳細遷移テスト")
//    func itemDetailNavigation() async throws {
//        let testItem = Item(name: "牛乳", category: .refrigerated, quantity: 1)
//        let initialState = InventoryFeature.State(
//            items: IdentifiedArrayOf([testItem])
//        )
//        
//        let store = TestStore(initialState: initialState) {
//            InventoryFeature()
//        }
//        
//        await store.send(.view(.itemTapped(testItem.id))) {
//            // ❌ ItemDetailFeature.Stateが存在しない
//            $0.itemDetail = ItemDetailFeature.State(item: testItem)
//        }
//    }
//    
//    @Test("商品追加画面遷移テスト")
//    func addItemNavigation() async throws {
//        let store = TestStore(initialState: InventoryFeature.State()) {
//            InventoryFeature()
//        }
//        
//        await store.send(.view(.addItemTapped)) {
//            // ❌ AddItemFeature.Stateが存在しない
//            $0.addItem = AddItemFeature.State()
//        }
//    }
//}