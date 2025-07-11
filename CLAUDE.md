# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Pochi（ポチ）is an iOS inventory management app built with Swift 6.0 and The Composable Architecture (TCA) 1.15.0+. The app helps users track household inventory with barcode scanning, expiry date management, and shopping list generation.

## Technology Stack

- **Swift**: 6.0 with strict concurrency checking
- **Framework**: The Composable Architecture (TCA) 1.15.0+
- **UI**: SwiftUI
- **Database**: Core Data
- **Camera**: AVFoundation
- **Notifications**: UserNotifications
- **Minimum iOS**: 17.0
- **Target**: iPhone only

## Project Structure

```
Pochi/
├── PochiApp.swift              # Main app entry point
├── Features/                   # Feature modules using TCA
│   ├── App/                   # Root app feature
│   ├── Home/                  # Dashboard and statistics
│   ├── Inventory/             # Item management
│   ├── Scanner/               # Barcode scanning
│   ├── ShoppingList/          # Shopping list management
│   └── Settings/              # App configuration
├── Dependencies/              # TCA dependency clients
│   ├── DatabaseClient.swift  # Core Data operations
│   ├── HapticClient.swift    # Haptic feedback
│   └── UserNotificationClient.swift  # Push notifications
├── Models/                    # Domain models
│   ├── Item.swift            # Core inventory item model
│   └── ShoppingItem.swift    # Shopping list item model
└── Resources/                 # Assets and Core Data models
    └── CoreData/
        └── Pochi.xcdatamodeld # Core Data model
```

## Development Commands

### Building and Running
This is an Xcode project, use standard Xcode build commands:
- **Build**: `xcodebuild -project Pochi.xcodeproj -scheme Pochi -destination 'platform=iOS Simulator,name=iPhone 15' build`
- **Test**: `xcodebuild -project Pochi.xcodeproj -scheme Pochi -destination 'platform=iOS Simulator,name=iPhone 15' test`
- **Run**: Use Xcode's Run button or `xcodebuild` with appropriate destination

### Core Data Management
- Model file: `Pochi/Resources/CoreData/Pochi.xcdatamodeld`
- Entities: `ItemEntity`, `ShoppingItemEntity`
- Access via `DatabaseClient` dependency

## Architecture Patterns

### The Composable Architecture (TCA)

All features follow TCA patterns:

```swift
@Reducer
struct FeatureName {
    @ObservableState
    struct State: Equatable {
        // State properties
    }
    
    enum Action: ViewAction {
        case view(View)
        // Other actions
        
        enum View: Sendable {
            // View actions
        }
    }
    
    var body: some ReducerOf<Self> {
        // Reducer implementation
    }
}
```

### Dependencies
- Use `@DependencyClient` for external dependencies
- Register with `DependencyKey` protocol
- **Only provide `liveValue`** - NO `testValue` in dependency clients
- Test values should be defined in test files using `withDependencies`
- Access via `@Dependency(\.keyPath)` in reducers

#### Testing Dependencies
```swift
// ❌ Do NOT define testValue in dependency clients
extension CameraClient: DependencyKey {
    static let liveValue: CameraClient = { /* live implementation */ }()
    // static let testValue = ... // NEVER do this
}

// ✅ Define test mocks in test files using withDependencies
@Test func testCameraPermission() async throws {
    let result = await withDependencies {
        $0.camera = CameraClient(
            requestPermission: { true },
            startScanning: { AsyncStream<String> { _ in } },
            stopScanning: { }
        )
    } operation: {
        @Dependency(\.camera) var camera
        return await camera.requestPermission()
    }
    
    #expect(result == true)
}
```

### State Management
- Use `@ObservableState` for iOS 17+ compatibility
- Presentations use `@Presents` property wrapper

## Domain Models

### Core Item Model
```swift
struct Item: Equatable, Identifiable, Sendable {
    let id: UUID
    var name: String
    var category: Category
    var quantity: Int
    var expiryDate: Date?
    // Additional properties...
}
```

### Categories
Predefined categories: refrigerated, frozen, pantry, beverages, snacks, seasonings, other

### Expiry Management
`ExpiryCalculator` provides utility functions for expiry status calculation with 3-day warning threshold.

## Key Features (Planned)

1. **Barcode Scanning**: AVFoundation-based scanner for product registration
2. **Inventory Management**: CRUD operations for household items
3. **Expiry Tracking**: Automatic notifications for items nearing expiry
4. **Shopping Lists**: Auto-generated lists based on low stock
5. **Statistics Dashboard**: Overview of inventory status

## Testing Strategy

This project follows **Test-Driven Development (TDD)** methodology:

### TDD Process
1. **Red**: Write failing tests first
2. **Green**: Write minimal code to pass tests
3. **Refactor**: Improve code while maintaining tests

### Test Framework
- **Primary Framework**: Swift Testing (iOS 17+)

### Test Types
- **Unit Tests**: TCA TestStore for reducer testing with Swift Testing
- **Integration Tests**: Feature interaction testing
- **UI Tests**: XCTest UI automation (Swift Testing not yet supported)
- Target coverage: 80%+

### TDD Guidelines
- Write tests before implementing features
- Test public interfaces, not implementation details
- Use TCA TestStore for comprehensive state testing
- Mock dependencies for isolated testing

### Mandatory TDD Workflow
**ALWAYS follow this exact sequence when developing new features:**

1. **Red Phase** - Write failing tests first:
   ```bash
   # 1. Write test code
   # 2. Ensure project builds successfully
   xcodebuild -project Pochi.xcodeproj -scheme Pochi -destination 'platform=iOS Simulator,name=iPhone 16' build
   
   # 3. Run tests and CONFIRM they FAIL
   xcodebuild -project Pochi.xcodeproj -scheme Pochi -destination 'platform=iOS Simulator,name=iPhone 16' test
   ```
   
2. **Green Phase** - Write minimal implementation:
   ```bash
   # 4. Write minimal code to make tests pass
   # 5. Run tests and confirm they PASS
   xcodebuild test
   ```
   
3. **Refactor Phase** - Improve code while keeping tests green

**⚠️ CRITICAL RULE: Never write implementation code without first having a failing test that builds successfully. This ensures tests are actually testing the implementation, not just passing by accident.**

#### TDD Verification Checklist
Before implementing any feature, verify:
- [ ] Tests are written and compile successfully
- [ ] Project builds without errors (`xcodebuild build`)  
- [ ] Tests fail as expected (`xcodebuild test` shows failures)
- [ ] Test failure messages clearly indicate what needs to be implemented
- [ ] Only then proceed with implementation

## Localization

Primary language: Japanese
UI text and messages use Japanese labels and copy as specified in the design documents.

## Implementation Guidelines

### Concurrency
- Swift 6.0 strict concurrency enabled
- Use `@Sendable` for cross-actor data
- Core Data operations isolated to `@MainActor`
- Async/await patterns throughout

### Error Handling
- Friendly error messages in Japanese
- "ポチッと失敗" theme for error states
- Graceful fallbacks for network/camera failures

### Performance
- Lazy loading for large item lists
- Image optimization and caching
- Debounced search (0.5s)
- Memory-conscious Core Data usage

## Development Status

This is a new project in early development phase. Most features are planned but not yet implemented. The current codebase contains:
- Basic TCA app structure
- Domain models and Core Data setup
- Dependency architecture
- Tab-based navigation skeleton

Refer to `docs/` for detailed implementation plans and UI specifications.

## Development Practices

- タスクを実行し始める際、PRを作成した後は必ずlinearのチケットの状態を変更して。タスクを始める際は必ず新しいブランチを作成して
- **チケット運用ルール**:
  - PR作成後のチケットのステータスはInReviewにして