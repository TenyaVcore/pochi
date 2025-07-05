//
//  ItemDetailFeature.swift
//  Pochi
//
//  Created by Claude Code on 2025/06/29.
//

import Foundation
import ComposableArchitecture

// MARK: - ItemDetailFeature Mock Implementation

@Reducer
struct ItemDetailFeature {
  @ObservableState
  struct State: Equatable {
    var item: Item
    var isEditing = false
    var editingItem: Item?
    var isLoading = false
    var showingDeleteAlert = false
    var errorMessage: String?
    
    init(
      item: Item,
      isEditing: Bool = false,
      editingItem: Item? = nil,
      isLoading: Bool = false,
      showingDeleteAlert: Bool = false,
      errorMessage: String? = nil
    ) {
      self.item = item
      self.isEditing = isEditing
      self.editingItem = editingItem
      self.isLoading = isLoading
      self.showingDeleteAlert = showingDeleteAlert
      self.errorMessage = errorMessage
    }
  }
  
  enum Action: ViewAction {
    case view(View)
    case saveResponse(Result<Item, Error>)
    case deleteResponse(Result<Void, Error>)
    
    enum View: Sendable {
      case editTapped
      case cancelEditTapped
      case nameChanged(String)
      case categoryChanged(Category)
      case quantityChanged(Int)
      case expiryDateChanged(Date)
      case saveTapped
      case deleteTapped
      case deleteConfirmed
    }
  }
  
  @Dependency(\.database) var database
  @Dependency(\.dismiss) var dismiss
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .view(.editTapped):
        state.isEditing = true
        state.editingItem = state.item
        return .none
        
      case .view(.cancelEditTapped):
        state.isEditing = false
        state.editingItem = nil
        return .none
        
      case let .view(.nameChanged(name)):
        state.editingItem?.name = name
        return .none
        
      case let .view(.categoryChanged(category)):
        state.editingItem?.category = category
        return .none
        
      case let .view(.quantityChanged(quantity)):
        state.editingItem?.quantity = quantity
        return .none
        
      case let .view(.expiryDateChanged(date)):
        state.editingItem?.expiryDate = date
        return .none
        
      case .view(.saveTapped):
        guard let editingItem = state.editingItem else { return .none }
        state.isLoading = true
        
        return .run { send in
          do {
            let updatedItem = try await database.updateItem(editingItem)
            await send(.saveResponse(.success(updatedItem)))
          } catch {
            await send(.saveResponse(.failure(error)))
          }
        }
        
      case .view(.deleteTapped):
        state.showingDeleteAlert = true
        return .none
        
      case .view(.deleteConfirmed):
        state.isLoading = true
        let itemId = state.item.id
        
        return .run { send in
          do {
            try await database.deleteItem(itemId)
            await send(.deleteResponse(.success(())))
            await dismiss()
          } catch {
            await send(.deleteResponse(.failure(error)))
          }
        }
        
      case let .saveResponse(.success(item)):
        state.isLoading = false
        state.isEditing = false
        state.item = item
        state.editingItem = nil
        return .none
        
      case .saveResponse(.failure):
        state.isLoading = false
        state.errorMessage = "保存に失敗しました"
        return .none
        
      case .deleteResponse(.success):
        state.isLoading = false
        return .none
        
      case .deleteResponse(.failure):
        state.isLoading = false
        state.errorMessage = "削除に失敗しました"
        return .none
      }
    }
  }
}