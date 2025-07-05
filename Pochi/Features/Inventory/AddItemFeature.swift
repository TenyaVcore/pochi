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
    }
  }
  
  enum Action: ViewAction {
    case view(View)
    case saveResponse(Result<Item, Error>)
    
    enum View: Sendable {
      case nameChanged(String)
      case categoryChanged(Category)
      case quantityChanged(Int)
      case expiryDateChanged(Date)
      case imageSelected(Data)
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
        if !name.isEmpty {
          state.validationErrors.remove(.nameRequired)
        }
        return .none
        
      case let .view(.categoryChanged(category)):
        state.category = category
        return .none
        
      case let .view(.quantityChanged(quantity)):
        state.quantity = quantity
        return .none
        
      case let .view(.expiryDateChanged(date)):
        state.expiryDate = date
        return .none
        
      case let .view(.imageSelected(data)):
        state.selectedImage = data
        return .none
        
      case .view(.saveTapped):
        if state.name.isEmpty {
          state.validationErrors.insert(.nameRequired)
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