//
//  ItemDetailFeatureTests.swift
//  PochiTests
//
//  Created by Claude Code on 2025/06/28.
//

import Testing
import ComposableArchitecture
@testable import Pochi

/// TDD Red Phase: ItemDetailFeatureのテスト
///
/// このテストは意図的に失敗するように作成されています。
/// ItemDetailFeature Reducerが実装されるまでコンパイルエラーになります。
@Suite("ItemDetailFeature Tests")
struct ItemDetailFeatureTests {
    
    let sampleItem = Item(
        name: "牛乳",
        category: .refrigerated,
        quantity: 1,
        expiryDate: Date().addingTimeInterval(86400 * 7)
    )
    
    @Test("編集モード開始テスト")
    func startEditing() async throws {
        // ❌ ItemDetailFeature構造体がまだ存在しないためコンパイルエラー
        let store = TestStore(initialState: ItemDetailFeature.State(item: sampleItem)) {
            ItemDetailFeature()
        }
        
        await store.send(.view(.editTapped)) {
            $0.isEditing = true
            $0.editingItem = sampleItem
        }
    }
    
    @Test("編集モードキャンセルテスト")
    func cancelEditing() async throws {
        let initialState = ItemDetailFeature.State(
            item: sampleItem,
            isEditing: true,
            editingItem: sampleItem
        )
        
        let store = TestStore(initialState: initialState) {
            ItemDetailFeature()
        }
        
        await store.send(.view(.cancelEditTapped)) {
            $0.isEditing = false
            $0.editingItem = nil
        }
    }
    
    @Test("商品名編集テスト")
    func editName() async throws {
        let initialState = ItemDetailFeature.State(
            item: sampleItem,
            isEditing: true,
            editingItem: sampleItem
        )
        
        let store = TestStore(initialState: initialState) {
            ItemDetailFeature()
        }
        
        await store.send(.view(.nameChanged("低脂肪牛乳"))) {
            $0.editingItem?.name = "低脂肪牛乳"
        }
    }
    
    @Test("カテゴリ編集テスト")
    func editCategory() async throws {
        let initialState = ItemDetailFeature.State(
            item: sampleItem,
            isEditing: true,
            editingItem: sampleItem
        )
        
        let store = TestStore(initialState: initialState) {
            ItemDetailFeature()
        }
        
        await store.send(.view(.categoryChanged(.beverages))) {
            $0.editingItem?.category = .beverages
        }
    }
    
    @Test("数量編集テスト")
    func editQuantity() async throws {
        let initialState = ItemDetailFeature.State(
            item: sampleItem,
            isEditing: true,
            editingItem: sampleItem
        )
        
        let store = TestStore(initialState: initialState) {
            ItemDetailFeature()
        }
        
        await store.send(.view(.quantityChanged(3))) {
            $0.editingItem?.quantity = 3
        }
    }
    
    @Test("賞味期限編集テスト")
    func editExpiryDate() async throws {
        let initialState = ItemDetailFeature.State(
            item: sampleItem,
            isEditing: true,
            editingItem: sampleItem
        )
        
        let store = TestStore(initialState: initialState) {
            ItemDetailFeature()
        }
        
        let newDate = Date().addingTimeInterval(86400 * 14) // 2週間後
        
        await store.send(.view(.expiryDateChanged(newDate))) {
            $0.editingItem?.expiryDate = newDate
        }
    }
    
    @Test("保存成功テスト")
    func saveSuccess() async throws {
        var editedItem = sampleItem
        editedItem.name = "編集済み牛乳"
        editedItem.quantity = 2
        
        let initialState = ItemDetailFeature.State(
            item: sampleItem,
            isEditing: true,
            editingItem: editedItem
        )
        
        let store = TestStore(initialState: initialState) {
            ItemDetailFeature()
        } withDependencies: {
            // ❌ DatabaseClientのupdateItemメソッドが存在しない
            $0.database.updateItem = { item in
                // モック実装：常に成功
                return item
            }
        }
        
        await store.send(.view(.saveTapped)) {
            $0.isLoading = true
        }
        
        await store.receive(.saveResponse(.success(editedItem))) {
            $0.isLoading = false
            $0.isEditing = false
            $0.item = editedItem
            $0.editingItem = nil
        }
    }
    
    @Test("保存失敗テスト")
    func saveFailure() async throws {
        let initialState = ItemDetailFeature.State(
            item: sampleItem,
            isEditing: true
        )
        
        let store = TestStore(initialState: initialState) {
            ItemDetailFeature()
        } withDependencies: {
            $0.database.updateItem = { item in
                throw TestError.updateFailed
            }
        }
        
        await store.send(.view(.saveTapped)) {
            $0.isLoading = true
        }
        
        await store.receive(.saveResponse(.failure(TestError.updateFailed))) {
            $0.isLoading = false
            $0.errorMessage = "保存に失敗しました"
        }
    }
    
    @Test("削除確認テスト")
    func deleteConfirmation() async throws {
        let store = TestStore(initialState: ItemDetailFeature.State(item: sampleItem)) {
            ItemDetailFeature()
        }
        
        await store.send(.view(.deleteTapped)) {
            // ❌ showingDeleteAlertプロパティが存在しない
            $0.showingDeleteAlert = true
        }
    }
    
    @Test("削除実行テスト")
    func deleteExecution() async throws {
        let store = TestStore(initialState: ItemDetailFeature.State(item: sampleItem)) {
            ItemDetailFeature()
        } withDependencies: {
            $0.database.deleteItem = { id in
                // モック実装：常に成功
            }
            $0.dismiss = DismissEffect {
                // モック実装
            }
        }
        
        await store.send(.view(.deleteConfirmed)) {
            $0.isLoading = true
        }
        
        await store.receive(.deleteResponse(.success(()))) {
            $0.isLoading = false
        }
        // dismiss effectが実行される
    }
    
    @Test("削除失敗テスト")
    func deleteFailure() async throws {
        let store = TestStore(initialState: ItemDetailFeature.State(item: sampleItem)) {
            ItemDetailFeature()
        } withDependencies: {
            $0.database.deleteItem = { id in
                throw TestError.deleteFailed
            }
        }
        
        await store.send(.view(.deleteConfirmed)) {
            $0.isLoading = true
        }
        
        await store.receive(.deleteResponse(.failure(TestError.deleteFailed))) {
            $0.isLoading = false
            $0.errorMessage = "削除に失敗しました"
        }
    }
}

// MARK: - Test Helpers

extension TestError {
    static let updateFailed = TestError.saveFailed
    static let deleteFailed = TestError.saveFailed
}

extension ItemDetailFeature.State {
    init(
        item: Item,
        isEditing: Bool = false,
        editingItem: Item? = nil,
        isLoading: Bool = false,
        showingDeleteAlert: Bool = false,
        errorMessage: String? = nil
    ) {
        // ❌ この初期化メソッドは実装されていない
        self.item = item
        self.isEditing = isEditing
        self.editingItem = editingItem
        self.isLoading = isLoading
        self.showingDeleteAlert = showingDeleteAlert
        self.errorMessage = errorMessage
    }
}