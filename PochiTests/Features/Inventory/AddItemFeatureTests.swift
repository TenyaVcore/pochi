//
//  AddItemFeatureTests.swift
//  PochiTests
//
//  Created by Claude Code on 2025/06/28.
//

import Testing
import ComposableArchitecture
import Foundation
@testable import Pochi

/// TDD Red Phase: AddItemFeatureのテスト
///
/// このテストは意図的に失敗するように作成されています。
/// AddItemFeature Reducerが実装されるまでコンパイルエラーになります。
@Suite("AddItemFeature Tests")
struct AddItemFeatureTests {
    
    @Test("商品名変更テスト")
    func nameChange() async throws {
        // ❌ AddItemFeature構造体がまだ存在しないためコンパイルエラー
        let store = TestStore(initialState: AddItemFeature.State()) {
            AddItemFeature()
        }
        
        await store.send(.view(.nameChanged("牛乳"))) {
            $0.name = "牛乳"
        }
    }
    
    @Test("カテゴリ変更テスト")
    func categoryChange() async throws {
        let store = TestStore(initialState: AddItemFeature.State()) {
            AddItemFeature()
        }
        
        await store.send(.view(.categoryChanged(.frozen))) {
            $0.category = .frozen
        }
    }
    
    @Test("数量変更テスト")
    func quantityChange() async throws {
        let store = TestStore(initialState: AddItemFeature.State()) {
            AddItemFeature()
        }
        
        await store.send(.view(.quantityChanged(5))) {
            $0.quantity = 5
        }
    }
    
    @Test("賞味期限変更テスト")
    func expiryDateChange() async throws {
        let store = TestStore(initialState: AddItemFeature.State()) {
            AddItemFeature()
        }
        
        let testDate = Date().addingTimeInterval(86400 * 7) // 1週間後
        
        await store.send(.view(.expiryDateChanged(testDate))) {
            $0.expiryDate = testDate
        }
    }
    
    @Test("画像選択テスト")
    func imageSelection() async throws {
        let store = TestStore(initialState: AddItemFeature.State()) {
            AddItemFeature()
        }
        
        let testImageData = Data([0x01, 0x02, 0x03])
        
        await store.send(.view(.imageSelected(testImageData))) {
            $0.selectedImage = testImageData
        }
    }
    
    @Test("保存成功テスト")
    func saveSuccess() async throws {
        let initialState = AddItemFeature.State(
            name: "牛乳",
            category: .refrigerated,
            quantity: 2
        )
        
        let store = TestStore(initialState: initialState) {
            AddItemFeature()
        } withDependencies: {
            // ❌ DatabaseClientのsaveItemメソッドが存在しない
            $0.database.saveItem = { item in
                // モック実装：常に成功
            }
            // ❌ dismiss dependencyが存在しない
            $0.dismiss = DismissEffect {
                // モック実装
            }
        }
        
        await store.send(.view(.saveTapped)) {
            $0.isLoading = true
        }
        
        let expectedItem = Item(
            name: "牛乳",
            category: .refrigerated,
            quantity: 2
        )
        
        await store.receive(.saveResponse(.success(expectedItem))) {
            $0.isLoading = false
        }
    }
    
    @Test("保存失敗テスト")
    func saveFailure() async throws {
        let initialState = AddItemFeature.State(
            name: "牛乳",
            category: .refrigerated,
            quantity: 2
        )
        
        let store = TestStore(initialState: initialState) {
            AddItemFeature()
        } withDependencies: {
            $0.database.saveItem = { item in
                throw TestError.saveFailed
            }
        }
        
        await store.send(.view(.saveTapped)) {
            $0.isLoading = true
        }
        
        await store.receive(.saveResponse(.failure(TestError.saveFailed))) {
            $0.isLoading = false
            $0.errorMessage = "保存に失敗しました"
        }
    }
    
    @Test("キャンセルテスト")
    func cancel() async throws {
        let store = TestStore(initialState: AddItemFeature.State()) {
            AddItemFeature()
        } withDependencies: {
            $0.dismiss = DismissEffect {
                // モック実装
            }
        }
        
        await store.send(.view(.cancelTapped))
        // dismiss effectが実行される
    }
    
    @Test("バリデーションテスト")
    func validation() async throws {
        let store = TestStore(initialState: AddItemFeature.State()) {
            AddItemFeature()
        }
        
        // 商品名が空の場合の保存試行
        await store.send(.view(.saveTapped)) {
            // ❌ validationErrorsプロパティが存在しない
            $0.validationErrors.insert(.nameRequired)
        }
        
        // 有効な商品名を入力
        await store.send(.view(.nameChanged("牛乳"))) {
            $0.name = "牛乳"
            $0.validationErrors.remove(.nameRequired)
        }
    }
}

// MARK: - Test Helpers

enum TestError: Error {
    case saveFailed
}

extension AddItemFeature.State {
    init(
        name: String = "",
        category: Pochi.Category = .refrigerated,
        quantity: Int = 1,
        expiryDate: Date? = nil,
        selectedImage: Data? = nil,
        isLoading: Bool = false
    ) {
        // ❌ この初期化メソッドは実装されていない
        self.name = name
        self.category = category
        self.quantity = quantity
        self.expiryDate = expiryDate
        self.selectedImage = selectedImage
        self.isLoading = isLoading
    }
}
