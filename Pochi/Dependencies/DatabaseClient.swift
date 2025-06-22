//
//  DatabaseClient.swift
//  Pochi
//
//  Created by Pochi Team on 2025/06/21.
//

import Combine
import CoreData
import Dependencies
import Foundation

// MARK: - Database Client


struct DatabaseClient: Sendable {
  // Items
  var fetchItems: @Sendable () async throws -> [Item]
  var saveItem: @Sendable (Item) async throws -> Void
  var updateItem: @Sendable (Item) async throws -> Void
  var deleteItem: @Sendable (UUID) async throws -> Void
  var fetchItem: @Sendable (UUID) async throws -> Item?
  
  // Shopping Items
  var fetchShoppingItems: @Sendable () async throws -> [ShoppingItem]
  var saveShoppingItem: @Sendable (ShoppingItem) async throws -> Void
  var updateShoppingItem: @Sendable (ShoppingItem) async throws -> Void
  var deleteShoppingItem: @Sendable (UUID) async throws -> Void
  
  // Utility
  var clearAllData: @Sendable () async throws -> Void
}

// MARK: - Dependency Registration

extension DatabaseClient: DependencyKey {
  static let liveValue: DatabaseClient = {
    let stack = CoreDataStack.shared
    
    return DatabaseClient(
      fetchItems: {
        await stack.fetchItems()
      },
      saveItem: { item in
        await stack.save(item)
      },
      updateItem: { item in
        await stack.update(item)
      },
      deleteItem: { id in
        await stack.deleteItem(id)
      },
      fetchItem: { id in
        await stack.fetchItem(id)
      },
      fetchShoppingItems: {
        await stack.fetchShoppingItems()
      },
      saveShoppingItem: { item in
        await stack.save(item)
      },
      updateShoppingItem: { item in
        await stack.update(item)
      },
      deleteShoppingItem: { id in
        await stack.deleteShoppingItem(id)
      },
      clearAllData: {
        await stack.clearAllData()
      }
    )
  }()
  
}

extension DependencyValues {
  var database: DatabaseClient {
    get { self[DatabaseClient.self] }
    set { self[DatabaseClient.self] = newValue }
  }
}

// MARK: - Core Data Stack

@MainActor
final class CoreDataStack: ObservableObject {
  static let shared = CoreDataStack()
  
  @Published var hasChanges = false
  
  lazy var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "Pochi")
    
    container.loadPersistentStores { _, error in
      if let error = error as NSError? {
        fatalError("Core Data failed to load: \(error), \(error.userInfo)")
      }
    }
    
    container.viewContext.automaticallyMergesChangesFromParent = true
    return container
  }()
  
  private var context: NSManagedObjectContext {
    persistentContainer.viewContext
  }
  
  private init() {}
  
  func save() throws {
    if context.hasChanges {
      try context.save()
    }
  }
}

// MARK: - Items Operations

extension CoreDataStack {
  func fetchItems() async -> [Item] {
    await withCheckedContinuation { continuation in
      context.perform {
        let request: NSFetchRequest<ItemEntity> = ItemEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ItemEntity.createdAt, ascending: false)]
        
        do {
          let entities = try self.context.fetch(request)
          let items = entities.compactMap { $0.toDomainModel() }
          continuation.resume(returning: items)
        } catch {
          print("Failed to fetch items: \(error)")
          continuation.resume(returning: [])
        }
      }
    }
  }
  
  func save(_ item: Item) async {
    await withCheckedContinuation { continuation in
      context.perform {
        let entity = ItemEntity(context: self.context)
        entity.fromDomainModel(item)
        
        do {
          try self.save()
          continuation.resume()
        } catch {
          print("Failed to save item: \(error)")
          continuation.resume()
        }
      }
    }
  }
  
  func update(_ item: Item) async {
    await withCheckedContinuation { continuation in
      context.perform {
        let request: NSFetchRequest<ItemEntity> = ItemEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", item.id as CVarArg)
        
        do {
          let entities = try self.context.fetch(request)
          if let entity = entities.first {
            entity.fromDomainModel(item)
            try self.save()
          }
          continuation.resume()
        } catch {
          print("Failed to update item: \(error)")
          continuation.resume()
        }
      }
    }
  }
  
  func deleteItem(_ id: UUID) async {
    await withCheckedContinuation { continuation in
      context.perform {
        let request: NSFetchRequest<ItemEntity> = ItemEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
          let entities = try self.context.fetch(request)
          entities.forEach { self.context.delete($0) }
          try self.save()
          continuation.resume()
        } catch {
          print("Failed to delete item: \(error)")
          continuation.resume()
        }
      }
    }
  }
  
  func fetchItem(_ id: UUID) async -> Item? {
    await withCheckedContinuation { continuation in
      context.perform {
        let request: NSFetchRequest<ItemEntity> = ItemEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
          let entities = try self.context.fetch(request)
          let item = entities.first?.toDomainModel()
          continuation.resume(returning: item)
        } catch {
          print("Failed to fetch item: \(error)")
          continuation.resume(returning: nil)
        }
      }
    }
  }
}

// MARK: - Shopping Items Operations

extension CoreDataStack {
  func fetchShoppingItems() async -> [ShoppingItem] {
    await withCheckedContinuation { continuation in
      context.perform {
        let request: NSFetchRequest<ShoppingItemEntity> = ShoppingItemEntity.fetchRequest()
        request.sortDescriptors = [
          NSSortDescriptor(keyPath: \ShoppingItemEntity.isChecked, ascending: true),
          NSSortDescriptor(keyPath: \ShoppingItemEntity.createdAt, ascending: false)
        ]
        
        do {
          let entities = try self.context.fetch(request)
          let items = entities.compactMap { $0.toDomainModel() }
          continuation.resume(returning: items)
        } catch {
          print("Failed to fetch shopping items: \(error)")
          continuation.resume(returning: [])
        }
      }
    }
  }
  
  func save(_ item: ShoppingItem) async {
    await withCheckedContinuation { continuation in
      context.perform {
        let entity = ShoppingItemEntity(context: self.context)
        entity.fromDomainModel(item)
        
        do {
          try self.save()
          continuation.resume()
        } catch {
          print("Failed to save shopping item: \(error)")
          continuation.resume()
        }
      }
    }
  }
  
  func update(_ item: ShoppingItem) async {
    await withCheckedContinuation { continuation in
      context.perform {
        let request: NSFetchRequest<ShoppingItemEntity> = ShoppingItemEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", item.id as CVarArg)
        
        do {
          let entities = try self.context.fetch(request)
          if let entity = entities.first {
            entity.fromDomainModel(item)
            try self.save()
          }
          continuation.resume()
        } catch {
          print("Failed to update shopping item: \(error)")
          continuation.resume()
        }
      }
    }
  }
  
  func deleteShoppingItem(_ id: UUID) async {
    await withCheckedContinuation { continuation in
      context.perform {
        let request: NSFetchRequest<ShoppingItemEntity> = ShoppingItemEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
          let entities = try self.context.fetch(request)
          entities.forEach { self.context.delete($0) }
          try self.save()
          continuation.resume()
        } catch {
          print("Failed to delete shopping item: \(error)")
          continuation.resume()
        }
      }
    }
  }
  
  func clearAllData() async {
    await withCheckedContinuation { continuation in
      context.perform {
        do {
          // Delete all items
          let itemRequest: NSFetchRequest<NSFetchRequestResult> = ItemEntity.fetchRequest()
          let deleteItemsRequest = NSBatchDeleteRequest(fetchRequest: itemRequest)
          try self.context.execute(deleteItemsRequest)
          
          // Delete all shopping items
          let shoppingRequest: NSFetchRequest<NSFetchRequestResult> = ShoppingItemEntity.fetchRequest()
          let deleteShoppingRequest = NSBatchDeleteRequest(fetchRequest: shoppingRequest)
          try self.context.execute(deleteShoppingRequest)
          
          try self.save()
          continuation.resume()
        } catch {
          print("Failed to clear all data: \(error)")
          continuation.resume()
        }
      }
    }
  }
}

// MARK: - Core Data Entity Extensions

extension ItemEntity {
  func toDomainModel() -> Item? {
    guard let id = id,
          let name = name,
          let category = category,
          let categoryEnum = Category(rawValue: category),
          let createdAt = createdAt,
          let updatedAt = updatedAt else { return nil }
    
    return Item(
      id: id,
      name: name,
      category: categoryEnum,
      quantity: Int(quantity),
      expiryDate: expiryDate,
      imageData: imageData,
      memo: memo,
      createdAt: createdAt,
      updatedAt: updatedAt
    )
  }
  
  func fromDomainModel(_ item: Item) {
    id = item.id
    name = item.name
    category = item.category.rawValue
    quantity = Int32(item.quantity)
    expiryDate = item.expiryDate
    imageData = item.imageData
    memo = item.memo
    createdAt = item.createdAt
    updatedAt = item.updatedAt
  }
}

extension ShoppingItemEntity {
  func toDomainModel() -> ShoppingItem? {
    guard let id = id,
          let name = name,
          let category = category,
          let categoryEnum = Category(rawValue: category),
          let addedFrom = addedFrom,
          let addedFromEnum = AddedFrom(rawValue: addedFrom),
          let createdAt = createdAt,
          let updatedAt = updatedAt else { return nil }
    
    return ShoppingItem(
      id: id,
      name: name,
      category: categoryEnum,
      quantity: Int(quantity),
      memo: memo,
      isChecked: isChecked,
      addedFrom: addedFromEnum,
      createdAt: createdAt,
      updatedAt: updatedAt
    )
  }
  
  func fromDomainModel(_ item: ShoppingItem) {
    id = item.id
    name = item.name
    category = item.category.rawValue
    quantity = Int32(item.quantity)
    memo = item.memo
    isChecked = item.isChecked
    addedFrom = item.addedFrom.rawValue
    createdAt = item.createdAt
    updatedAt = item.updatedAt
  }
}
