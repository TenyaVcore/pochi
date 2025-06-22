# Pochi（ポチ）実装計画書 - 第1フェーズ（MVP）

## 📋 プロジェクト概要

**アプリ名**: Pochi（ポチ）- かんたん在庫管理  
**キャッチコピー**: 「ポチッと在庫管理」  
**開発期間**: 3ヶ月  
**技術スタック**: Swift 6.0 + TCA 1.15.0+ のみ（SwiftUI、Core Data、AVFoundationなどはiOS標準API）  
**対象OS**: iOS 15.0+（iPhone専用）  

## 🎯 MVP目標

- **ターゲットユーザー**: 20-40代の主婦/主夫、一人暮らしの社会人
- **成功指標**: DAU 1,000人、継続率40%（30日後）
- **品質要件**: クラッシュ率0.1%以下、応答時間1秒以内

## 📅 3ヶ月実装スケジュール

### Month 1: 基盤構築フェーズ

#### Week 1: プロジェクト環境構築
- [ ] **Xcodeプロジェクト作成**
  - Bundle ID: `com.pochi.inventory`
  - Deployment Target: iOS 15.0
  - Swift 6.0 + Strict Concurrency Checking有効化
  - Workspace + Package構成

- [ ] **Swift Package Manager依存関係**
  ```swift
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.15.0"),
  ]
  ```
  
- [ ] **TCA内蔵機能の活用**
  - TCA内蔵のテスト機能を使用
  - TCA内蔵のDependency管理システムを使用
  - SwiftUI標準機能でUI実装

- [ ] **プロジェクト構造設計**
  ```
  Pochi/
  ├── App/                 # メインアプリ
  │   ├── PochiApp.swift
  │   └── AppFeature.swift
  ├── Features/            # 機能別Feature
  │   ├── Home/
  │   ├── Inventory/
  │   ├── Scanner/
  │   ├── ShoppingList/
  │   └── Settings/
  ├── Dependencies/        # TCA Dependencies
  │   ├── DatabaseClient.swift
  │   ├── CameraClient.swift
  │   ├── APIClient.swift
  │   └── UserNotificationClient.swift
  ├── Models/              # ドメインモデル
  │   ├── Item.swift
  │   ├── Category.swift
  │   └── ShoppingItem.swift
  ├── Resources/           # アセット・ローカライゼーション
  │   ├── Assets.xcassets
  │   └── Localizable.strings
  └── Tests/               # テスト
      ├── FeatureTests/
      └── IntegrationTests/
  ```

#### Week 2: Core Data + TCA統合設計（標準APIのみ使用）
- [ ] **Core Dataモデル設計**
  ```swift
  // Item Entity（標準Core Dataのみ使用）
  @objc(Item)
  public class Item: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var quantity: Int32
    @NSManaged public var category: String
    @NSManaged public var expiryDate: Date?
    @NSManaged public var createdAt: Date
    @NSManaged public var imageData: Data?
  }
  ```

- [ ] **DatabaseClient実装**
  ```swift
  @DependencyClient
  struct DatabaseClient: Sendable {
    var fetchItems: @Sendable () async throws -> [Item]
    var saveItem: @Sendable (Item) async throws -> Void
    var deleteItem: @Sendable (UUID) async throws -> Void
    var updateQuantity: @Sendable (UUID, Int) async throws -> Void
  }
  ```

- [ ] **Actor分離設計**
  ```swift
  @DatabaseActor
  final class CoreDataStack {
    static let shared = CoreDataStack()
    lazy var persistentContainer: NSPersistentContainer = { ... }()
  }
  ```

#### Week 3-4: バーコードスキャン機能実装（AVFoundation標準API使用）
- [ ] **CameraClient実装**
  ```swift
  // AVFoundationのみ使用（外部ライブラリ不要）
  @DependencyClient
  struct CameraClient: Sendable {
    var requestPermission: @Sendable () async -> Bool
    var startScanning: @Sendable () -> AsyncStream<String>
    var stopScanning: @Sendable () async -> Void
  }
  ```

- [ ] **ScannerFeature実装**
  ```swift
  @Reducer
  struct ScannerFeature {
    @ObservableState
    struct State: Equatable {
      var scanMode: ScanMode = .single
      var scannedBarcode: String?
      var isScanning = false
      @Presents var productDetail: ProductDetailFeature.State?
    }
    
    enum Action: ViewAction, Sendable {
      case view(View)
      case scanResult(String)
      case productDetail(PresentationAction<ProductDetailFeature.Action>)
      
      enum View: Sendable {
        case startScanTapped
        case stopScanTapped
      }
    }
  }
  ```

- [ ] **APIClient（JAN検索）実装**
  ```swift
  // URLSessionのみ使用（外部HTTPライブラリ不要）
  @DependencyClient
  struct APIClient: Sendable {
    var searchProduct: @Sendable (String) async throws -> Product?
  }
  ```

### Month 2: コア機能開発フェーズ

#### Week 1-2: 在庫管理機能実装
- [ ] **InventoryFeature実装**
  ```swift
  @Reducer
  struct InventoryFeature {
    @ObservableState
    struct State: Equatable {
      var items: IdentifiedArrayOf<InventoryItem> = []
      var searchQuery = ""
      var selectedCategory: Category = .all
      var sortOrder: SortOrder = .createdAt
      @Presents var itemDetail: ItemDetailFeature.State?
    }
    
    enum Action: ViewAction, Sendable {
      case view(View)
      case itemsLoaded([InventoryItem])
      case itemDetail(PresentationAction<ItemDetailFeature.Action>)
      
      enum View: Sendable {
        case onAppear
        case searchQueryChanged(String)
        case categorySelected(Category)
        case itemTapped(InventoryItem.ID)
        case incrementQuantity(InventoryItem.ID)
        case decrementQuantity(InventoryItem.ID)
      }
    }
  }
  ```

- [ ] **手動商品登録機能**
  ```swift
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
    }
  }
  ```

#### Week 3: 賞味期限管理・通知機能（UserNotifications標準API使用）
- [ ] **UserNotificationClient実装**
  ```swift
  // UserNotifications標準APIのみ使用
  @DependencyClient
  struct UserNotificationClient: Sendable {
    var requestAuthorization: @Sendable () async -> Bool
    var scheduleNotification: @Sendable (NotificationRequest) async throws -> Void
    var cancelNotification: @Sendable (String) async -> Void
  }
  ```

- [ ] **期限管理ロジック**
  ```swift
  struct ExpiryCalculator {
    static func daysUntilExpiry(_ date: Date) -> Int {
      Calendar.current.dateComponents([.day], from: .now, to: date).day ?? 0
    }
    
    static func isExpiringSoon(_ date: Date, threshold: Int = 3) -> Bool {
      daysUntilExpiry(date) <= threshold
    }
  }
  ```

#### Week 4: 買い物リスト機能
- [ ] **ShoppingListFeature実装**
  ```swift
  @Reducer
  struct ShoppingListFeature {
    @ObservableState
    struct State: Equatable {
      var items: IdentifiedArrayOf<ShoppingItem> = []
      var newItemName = ""
      var checkedItems: Set<ShoppingItem.ID> = []
    }
    
    enum Action: ViewAction, Sendable {
      case view(View)
      case itemsLoaded([ShoppingItem])
      
      enum View: Sendable {
        case onAppear
        case addItemTapped
        case itemChecked(ShoppingItem.ID)
        case restockItem(ShoppingItem.ID)
      }
    }
  }
  ```

### Month 3: 統合・リリース準備フェーズ

#### Week 1: 基本Navigation構造実装
- [ ] **AppFeature実装**
  ```swift
  @Reducer
  struct AppFeature {
    @ObservableState
    struct State: Equatable {
      var selectedTab: Tab = .home
      var home = HomeFeature.State()
      var inventory = InventoryFeature.State()
      var scanner = ScannerFeature.State()
      var shoppingList = ShoppingListFeature.State()
      var settings = SettingsFeature.State()
    }
    
    enum Tab: CaseIterable {
      case home, inventory, scanner, shoppingList, settings
    }
  }
  ```

#### Week 2: UI/UX最適化
- [ ] **SwiftUI + TCA統合**
  ```swift
  struct InventoryView: View {
    @Bindable var store: StoreOf<InventoryFeature>
    
    var body: some View {
      NavigationStack {
        List {
          ForEach(store.items) { item in
            InventoryRowView(item: item) {
              store.send(.view(.itemTapped(item.id)))
            }
            .swipeActions {
              Button("削除", role: .destructive) {
                store.send(.view(.deleteItem(item.id)))
              }
            }
          }
        }
        .searchable(text: $store.searchQuery)
        .navigationTitle("在庫一覧")
      }
    }
  }
  ```

- [ ] **Dark Mode対応**
- [ ] **Dynamic Type対応**
- [ ] **アクセシビリティ対応**

#### Week 3: テスト実装
- [ ] **TCA TestStore使用**
  ```swift
  final class InventoryFeatureTests: XCTestCase {
    @MainActor
    func testItemsLoading() async {
      let store = TestStore(initialState: InventoryFeature.State()) {
        InventoryFeature()
      } withDependencies: {
        $0.database = .testValue
      }
      
      await store.send(.view(.onAppear))
      await store.receive(.itemsLoaded([]))
    }
  }
  ```

- [ ] **TCA統合テスト**
- [ ] **XCTest標準機能でUIテスト**

#### Week 4: App Store準備
- [ ] **App Store Connect設定**
  - アプリ情報登録
  - スクリーンショット作成
  - 説明文作成
  - プライバシーポリシー

- [ ] **TestFlight配信**
  - 内部テスター招待
  - ベータテスト実施
  - フィードバック収集・修正

## 🏗️ 技術的実装詳細

### Swift 6.0 + TCA Best Practices

#### Concurrency対応
```swift
// Actor分離
@DatabaseActor
final class CoreDataClient {
  func fetchItems() async throws -> [Item] {
    // Core Data操作
  }
}

// Sendable準拠
struct Item: Equatable, Identifiable, Sendable {
  let id: UUID
  let name: String
  let quantity: Int
}
```

#### State管理
```swift
// iOS 17+: @ObservableState使用
@ObservableState
struct State: Equatable {
  var items: IdentifiedArrayOf<Item> = []
  @Presents var alert: AlertState<Action.Alert>?
}

// iOS 15-16: WithPerceptionTracking使用
struct LegacyView: View {
  let store: StoreOf<Feature>
  
  var body: some View {
    WithPerceptionTracking {
      // View content
    }
  }
}
```

#### Effect管理
```swift
case .view(.loadItems):
  return .run { send in
    let items = try await dependencies.database.fetchItems()
    await send(.itemsLoaded(items))
  }
  .cancellable(id: CancelID.loadItems)
```

### Dependencies設計

#### DatabaseClient
```swift
extension DatabaseClient: DependencyKey {
  static let liveValue = Self(
    fetchItems: {
      await CoreDataStack.shared.fetchItems()
    },
    saveItem: { item in
      await CoreDataStack.shared.save(item)
    }
  )
  
  static let testValue = Self(
    fetchItems: { [] },
    saveItem: { _ in }
  )
}
```

#### HapticClient
```swift
// UIKit標準のHaptic APIのみ使用
@DependencyClient
struct HapticClient: Sendable {
  var impact: @Sendable (UIImpactFeedbackGenerator.FeedbackType) -> Void
  var notification: @Sendable (UINotificationFeedbackGenerator.FeedbackType) -> Void
}
```

## 🎨 UI/UX設計指針

### デザイン原則
- **iOS Human Interface Guidelines準拠**
- **「ポチッと」ブランディング統一**
- **Direct Manipulation（直接操作）重視**
- **エラー時の親しみやすいメッセージ**

### カラーパレット
```swift
extension Color {
  static let pochiOrange = Color(red: 1.0, green: 0.6, blue: 0.2)
  static let pochiBackground = Color(.systemGroupedBackground)
  static let pochiText = Color(.label)
}
```

### サウンドデザイン
- **操作音**: 軽快な「ポチッ」音
- **完了音**: 達成感のある音
- **エラー音**: 優しい通知音

## 📊 品質保証・テスト戦略

### テスト種別
1. **Unit Tests**: TCA TestStoreを使用したReducerテスト
2. **Integration Tests**: TCA Feature間連携テスト
3. **UI Tests**: XCTest標準機能でUIテスト
4. **Performance Tests**: XCTest標準の性能測定機能を使用

### 品質指標
- **Code Coverage**: 80%以上
- **Crash Rate**: 0.1%以下
- **Response Time**: 主要操作1秒以内
- **Memory Usage**: 100MB以下（通常使用時）

## 🔒 セキュリティ・プライバシー

### データ保護
- **ローカルストレージ**: Core Data暗号化
- **通信**: HTTPS通信のみ
- **権限管理**: 必要最小限の権限要求

### プライバシー対応
- **App Tracking Transparency**: iOS 14.5+対応
- **Privacy Manifest**: プライバシー情報開示
- **データ匿名化**: 分析データの匿名化

## 📈 リリース後の運用計画

### 分析・計測
```swift
// TCA Dependencyとして実装
@DependencyClient
struct AnalyticsClient: Sendable {
  var track: @Sendable (String, [String: Any]) async -> Void
}

// 使用例
enum AnalyticsEvent: String, CaseIterable {
  case pochiScanSuccess = "pochi_scan_success"
  case pochiManualAdd = "pochi_manual_add"
  case pochiNotificationTap = "pochi_notification_tap"
}
```

### A/Bテスト準備
- **オンボーディング画面**
- **スキャン画面UI**
- **通知設定タイミング**

## 🚀 第2フェーズ準備

### 技術的準備
- **CloudKit同期**: デバイス間同期
- **Apple Watch**: 在庫確認機能
- **Widget**: 期限切れ間近表示
- **Shortcuts**: Siri連携

### 機能拡張
- **家族共有**: 最大6名での在庫共有
- **AI予測**: 消費パターン学習
- **EC連携**: Amazon・楽天連携
- **企業向け**: B2B在庫管理

## ✅ 完了定義（Definition of Done）

### MVP完了条件
- [ ] バーコードスキャンで商品登録可能
- [ ] 在庫の増減がワンタップで可能
- [ ] 期限3日前に通知が届く
- [ ] 買い物リストが自動生成される
- [ ] データがデバイスに保存される
- [ ] TestFlightで50名以上がテスト完了
- [ ] App Store審査通過

### 品質指標達成
- [ ] クラッシュ率0.1%以下
- [ ] 主要機能の応答時間1秒以内
- [ ] Code Coverage 80%以上
- [ ] Xcode標準の静的解析でWarningゼロ

---

**作成日**: 2025年6月21日  
**更新日**: 2025年6月21日  
**バージョン**: 1.0  
**作成者**: Pochi開発チーム  
