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
        var initialState = AddItemFeature.State()
        initialState.name = "牛乳"
        initialState.category = .refrigerated
        initialState.quantity = 2
        
        let store = TestStore(initialState: initialState) {
            AddItemFeature()
        } withDependencies: {
            // ❌ DatabaseClientのsaveItemメソッドが存在しない
            $0.database.saveItem = { item in
                // モック実装：常に成功
            }
            // ❌ dismiss dependencyが存在しない
            $0.dismiss = {
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
        
        await store.receive(\.saveResponse.success) {
            $0.isLoading = false
        }
    }
    
    @Test("保存失敗テスト")
    func saveFailure() async throws {
        var initialState = AddItemFeature.State()
        initialState.name = "牛乳"
        initialState.category = .refrigerated
        initialState.quantity = 2
        
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
        
        await store.receive(\.saveResponse.failure) {
            $0.isLoading = false
            $0.errorMessage = "保存に失敗しました"
        }
    }
    
    @Test("キャンセルテスト")
    func cancel() async throws {
        let store = TestStore(initialState: AddItemFeature.State()) {
            AddItemFeature()
        } withDependencies: {
            $0.dismiss = {
                // モック実装
            }
        }
        
        await store.send(.view(.cancelTapped))
        // dismiss effectが実行される
    }
    
    @Test("バリデーションテスト - 商品名必須")
    func validationNameRequired() async throws {
        let store = TestStore(initialState: AddItemFeature.State()) {
            AddItemFeature()
        }
        
        // 商品名が空の場合の保存試行
        await store.send(.view(.saveTapped)) {
            $0.validationErrors.insert(.nameRequired)
        }
        
        // 有効な商品名を入力
        await store.send(.view(.nameChanged("牛乳"))) {
            $0.name = "牛乳"
            $0.validationErrors.remove(.nameRequired)
        }
    }
    
    @Test("バリデーションテスト - 商品名文字数制限")
    func validationNameLength() async throws {
        let store = TestStore(initialState: AddItemFeature.State()) {
            AddItemFeature()
        }
        
        // 51文字の商品名を入力（制限を超える）
        let longName = String(repeating: "あ", count: 51)
        await store.send(.view(.nameChanged(longName))) {
            $0.name = longName
            $0.validationErrors.insert(.nameTooLong)
        }
        
        // 50文字の商品名を入力（制限内）
        let validName = String(repeating: "あ", count: 50)
        await store.send(.view(.nameChanged(validName))) {
            $0.name = validName
            $0.validationErrors.remove(.nameTooLong)
        }
    }
    
    @Test("バリデーションテスト - 数量範囲")
    func validationQuantityRange() async throws {
        let store = TestStore(initialState: AddItemFeature.State()) {
            AddItemFeature()
        }
        
        // 0以下の数量
        await store.send(.view(.quantityChanged(0))) {
            $0.quantity = 0
            $0.validationErrors.insert(.quantityInvalid)
        }
        
        // 1000以上の数量
        await store.send(.view(.quantityChanged(1000))) {
            $0.quantity = 1000
            $0.validationErrors.insert(.quantityInvalid)
        }
        
        // 有効な数量
        await store.send(.view(.quantityChanged(10))) {
            $0.quantity = 10
            $0.validationErrors.remove(.quantityInvalid)
        }
    }
    
    @Test("バリデーションテスト - 賞味期限")
    func validationExpiryDate() async throws {
        let store = TestStore(initialState: AddItemFeature.State()) {
            AddItemFeature()
        }
        
        // 過去の日付
        let pastDate = Date().addingTimeInterval(-86400) // 1日前
        await store.send(.view(.expiryDateChanged(pastDate))) {
            $0.expiryDate = pastDate
            $0.validationErrors.insert(.expiryDateInvalid)
        }
        
        // 現在以降の日付
        let futureDate = Date().addingTimeInterval(86400) // 1日後
        await store.send(.view(.expiryDateChanged(futureDate))) {
            $0.expiryDate = futureDate
            $0.validationErrors.remove(.expiryDateInvalid)
        }
        
        // nilに設定（賞味期限なし）
        await store.send(.view(.expiryDateChanged(nil))) {
            $0.expiryDate = nil
            $0.validationErrors.remove(.expiryDateInvalid)
        }
    }
}

// MARK: - Test Helpers

enum TestError: Error {
    case saveFailed
}

