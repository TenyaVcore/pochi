//
//  InventoryFeature.swift
//  Pochi
//
//  Created by Claude Code on 2025/06/29.
//

import Foundation
import ComposableArchitecture

// MARK: - InventoryFeature Mock Implementation

@Reducer
struct InventoryFeature {
  @ObservableState
  struct State: Equatable {
    var items: [Item] = []
    var isLoading = false
    var searchText = ""
    var selectedCategory: Category? = nil
    var errorMessage: String?
    
    @Presents var addItem: AddItemFeature.State?
    @Presents var itemDetail: ItemDetailFeature.State?
  }
  
  enum Action: ViewAction {
    case view(View)
    case fetchItemsResponse(Result<[Item], Error>)
    case updateQuantityResponse(Result<Item, Error>)
    case addItem(PresentationAction<AddItemFeature.Action>)
    case itemDetail(PresentationAction<ItemDetailFeature.Action>)
    
    enum View: Sendable {
      case onAppear
      case searchTextChanged(String)
      case categoryFilterChanged(Category?)
      case refreshTapped
      case addItemTapped
      case itemTapped(Item)
      case incrementQuantity(Item.ID)
      case decrementQuantity(Item.ID)
    }
  }
  
  @Dependency(\.database) var database
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .view(.onAppear):
        return fetchItems(state: &state)
        
      case let .view(.searchTextChanged(text)):
        state.searchText = text
        return .none
        
      case let .view(.categoryFilterChanged(category)):
        state.selectedCategory = category
        return .none
        
      case .view(.refreshTapped):
        return fetchItems(state: &state)
        
      case .view(.addItemTapped):
        state.addItem = AddItemFeature.State()
        return .none
        
      case let .view(.itemTapped(item)):
        state.itemDetail = ItemDetailFeature.State(item: item)
        return .none
        
      case let .view(.incrementQuantity(itemId)):
        guard let item = state.items.first(where: { $0.id == itemId }) else {
          return .none
        }
        var updatedItem = item
        updatedItem.quantity += 1
        return updateQuantity(item: updatedItem, state: &state)
        
      case let .view(.decrementQuantity(itemId)):
        guard let item = state.items.first(where: { $0.id == itemId }),
              item.quantity > 0 else {
          return .none
        }
        var updatedItem = item
        updatedItem.quantity -= 1
        return updateQuantity(item: updatedItem, state: &state)
        
      case let .fetchItemsResponse(.success(items)):
        state.isLoading = false
        state.items = items
        return .none
        
      case .fetchItemsResponse(.failure):
        state.isLoading = false
        state.errorMessage = "データの取得に失敗しました"
        return .none
        
      case let .updateQuantityResponse(.success(item)):
        if let index = state.items.firstIndex(where: { $0.id == item.id }) {
          state.items[index] = item
        }
        return .none
        
      case .updateQuantityResponse(.failure):
        state.errorMessage = "数量の更新に失敗しました"
        return .none
        
      case .addItem(.presented(.saveResponse(.success))):
        // Refresh items when new item is added
        return fetchItems(state: &state)
        
      case .addItem:
        return .none
        
      case .itemDetail(.presented(.deleteResponse(.success))):
        // Refresh items when item is deleted
        return fetchItems(state: &state)
        
      case .itemDetail(.presented(.saveResponse(.success))):
        // Refresh items when item is updated
        return fetchItems(state: &state)
        
      case .itemDetail:
        return .none
      }
    }
    .ifLet(\.$addItem, action: \.addItem) {
      AddItemFeature()
    }
    .ifLet(\.$itemDetail, action: \.itemDetail) {
      ItemDetailFeature()
    }
  }
  
  // MARK: - Private Methods
  
  private func fetchItems(state: inout State) -> Effect<Action> {
    state.isLoading = true
    return .run { send in
      do {
        let items = try await database.fetchItems()
        await send(.fetchItemsResponse(.success(items)))
      } catch {
        await send(.fetchItemsResponse(.failure(error)))
      }
    }
  }
  
  private func updateQuantity(item: Item, state: inout State) -> Effect<Action> {
    return .run { send in
      do {
        let updatedItem = try await database.updateQuantity(item.id, item.quantity)
        await send(.updateQuantityResponse(.success(updatedItem)))
      } catch {
        await send(.updateQuantityResponse(.failure(error)))
      }
    }
  }
}

// MARK: - Computed Properties

extension InventoryFeature.State {
  var filteredItems: [Item] {
    var items = self.items
    
    // Apply category filter
    if let selectedCategory = selectedCategory {
      items = items.filter { $0.category == selectedCategory }
    }
    
    // Apply search filter
    if !searchText.isEmpty {
      items = items.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    return items.sorted { $0.name < $1.name }
  }
}