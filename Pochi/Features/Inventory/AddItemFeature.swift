//
//  AddItemFeature.swift
//  Pochi
//
//  Created by Claude Code on 2025/06/29.
//

import Foundation
import ComposableArchitecture

// MARK: - AddItemFeature Mock Implementation

@Reducer
struct AddItemFeature {
  @ObservableState
  struct State: Equatable {
    var name = ""
    var category: Category = .refrigerated
    var quantity = 1
    var expiryDate: Date?
    var selectedImage: Data?
    var isLoading = false
    var errorMessage: String?
    var validationErrors: Set<ValidationError> = []
    
    enum ValidationError: Hashable {
      case nameRequired
      case nameTooLong
      case quantityInvalid
      case expiryDateInvalid
    }
  }
  
  enum Action: ViewAction {
    case view(View)
    case saveResponse(Result<Item, Error>)
    
    enum View: Sendable {
      case nameChanged(String)
      case categoryChanged(Category)
      case quantityChanged(Int)
      case expiryDateChanged(Date?)
      case imageSelected(Data?)
      case saveTapped
      case cancelTapped
    }
  }
  
  @Dependency(\.database) var database
  @Dependency(\.dismiss) var dismiss
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case let .view(.nameChanged(name)):
        state.name = name
        validateName(&state)
        return .none
        
      case let .view(.categoryChanged(category)):
        state.category = category
        return .none
        
      case let .view(.quantityChanged(quantity)):
        state.quantity = quantity
        validateQuantity(&state)
        return .none
        
      case let .view(.expiryDateChanged(date)):
        state.expiryDate = date
        validateExpiryDate(&state)
        return .none
        
      case let .view(.imageSelected(data)):
        state.selectedImage = data
        return .none
        
      case .view(.saveTapped):
        // 全てのバリデーションを実行
        validateName(&state)
        validateQuantity(&state)
        validateExpiryDate(&state)
        
        // バリデーションエラーがある場合は保存しない
        if !state.validationErrors.isEmpty {
          return .none
        }
        
        state.isLoading = true
        let item = Item(
          name: state.name,
          category: state.category,
          quantity: state.quantity,
          expiryDate: state.expiryDate,
          imageData: state.selectedImage
        )
        
        return .run { send in
          do {
            try await database.saveItem(item)
            await send(.saveResponse(.success(item)))
            await dismiss()
          } catch {
            await send(.saveResponse(.failure(error)))
          }
        }
        
      case .view(.cancelTapped):
        return .run { _ in
          await dismiss()
        }
        
      case let .saveResponse(.success(item)):
        state.isLoading = false
        return .none
        
      case .saveResponse(.failure):
        state.isLoading = false
        state.errorMessage = "保存に失敗しました"
        return .none
      }
    }
  }
}

// MARK: - Mock Dependencies

extension DependencyValues {
  var dismiss: @Sendable () async -> Void {
    get { self[DismissKey.self] }
    set { self[DismissKey.self] = newValue }
  }
}

private enum DismissKey: DependencyKey {
  static let liveValue: @Sendable () async -> Void = { }
}

// MARK: - Validation Functions

private func validateName(_ state: inout AddItemFeature.State) {
  // 商品名必須チェック
  if state.name.isEmpty {
    state.validationErrors.insert(.nameRequired)
  } else {
    state.validationErrors.remove(.nameRequired)
  }
  
  // 商品名文字数チェック（50文字以内）
  if state.name.count > 50 {
    state.validationErrors.insert(.nameTooLong)
  } else {
    state.validationErrors.remove(.nameTooLong)
  }
}

private func validateQuantity(_ state: inout AddItemFeature.State) {
  // 数量範囲チェック（1以上999以下）
  if state.quantity < 1 || state.quantity > 999 {
    state.validationErrors.insert(.quantityInvalid)
  } else {
    state.validationErrors.remove(.quantityInvalid)
  }
}

private func validateExpiryDate(_ state: inout AddItemFeature.State) {
  // 賞味期限チェック（現在日時以降）
  if let date = state.expiryDate {
    let now = Date()
    if date < now {
      state.validationErrors.insert(.expiryDateInvalid)
    } else {
      state.validationErrors.remove(.expiryDateInvalid)
    }
  } else {
    // 賞味期限を設定しない場合はエラーを削除
    state.validationErrors.remove(.expiryDateInvalid)
  }
}