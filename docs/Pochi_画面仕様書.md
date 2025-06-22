# Pochi（ポチ）画面仕様書 - 第1フェーズ（MVP）

## 📱 画面設計概要

**対象デバイス**: iPhone専用（iPhone SE 第3世代〜iPhone 15 Pro Max）  
**対応OS**: iOS 15.0以上  
**デザインシステム**: iOS Human Interface Guidelines準拠  
**ブランドカラー**: ポチオレンジ（#FF9933）  

## 🎨 デザインシステム

### カラーパレット
```swift
// メインカラー
Primary Orange: #FF9933     // ポチオレンジ
Primary Orange Light: #FFB366
Primary Orange Dark: #E6851A

// システムカラー
Background: UIColor.systemGroupedBackground
Surface: UIColor.secondarySystemGroupedBackground
Text Primary: UIColor.label
Text Secondary: UIColor.secondaryLabel
Separator: UIColor.separator

// セマンティックカラー
Success: UIColor.systemGreen
Warning: UIColor.systemOrange
Error: UIColor.systemRed
Info: UIColor.systemBlue
```

### タイポグラフィ
```swift
// 見出し
Title 1: SF Pro Display Bold 34pt
Title 2: SF Pro Display Bold 28pt
Title 3: SF Pro Display Semibold 22pt

// 本文
Body: SF Pro Text Regular 17pt
Callout: SF Pro Text Regular 16pt
Footnote: SF Pro Text Regular 13pt
Caption: SF Pro Text Regular 12pt

// アクション
Button Large: SF Pro Text Semibold 17pt
Button Medium: SF Pro Text Semibold 15pt
Button Small: SF Pro Text Semibold 13pt
```

### アイコンセット
```swift
// システムアイコン（SF Symbols）
Tab Icons: house, archivebox, camera, cart, gearshape
Navigation: plus, magnifyingglass, ellipsis, chevron.right
Actions: checkmark, xmark, trash, pencil, camera.fill
Status: exclamationmark.triangle, checkmark.circle, clock
```

## 📋 画面一覧

### メイン画面（5画面）
1. **ホーム画面** - 概要・統計情報
2. **在庫一覧画面** - 商品一覧・検索
3. **スキャン画面** - バーコード読み取り
4. **買い物リスト画面** - 必要商品リスト
5. **設定画面** - アプリ設定・データ管理

### サブ画面（8画面）
6. **商品詳細画面** - 商品情報・編集
7. **商品追加画面** - 手動商品登録
8. **商品編集画面** - 商品情報修正
9. **カテゴリー管理画面** - カテゴリー追加・編集
10. **通知設定画面** - プッシュ通知設定
11. **データ管理画面** - エクスポート・インポート
12. **オンボーディング画面** - 初回起動時ガイド
13. **チュートリアル画面** - 機能説明

---

## 🏠 1. ホーム画面（HomeView）

### 画面概要
- **目的**: アプリの概要確認とクイックアクション
- **アクセス**: TabViewのメインタブ
- **権限**: 特になし

### UI構成
```
┌─────────────────────────────────────┐
│ 🏠 ホーム               🔔 通知     │
├─────────────────────────────────────┤
│ おかえりなさい！ポチです 🐕        │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 📊 今日の統計情報                │ │
│ │ 在庫アイテム数: 42個             │ │
│ │ 期限切れ間近: 3個               │ │
│ │ 今日登録した商品: 5個           │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ ⚠️ 注意が必要な商品              │ │
│ │ • 牛乳 (明日期限切れ)           │ │
│ │ • パン (2日後期限切れ)          │ │
│ │ • 卵 (在庫切れ)                │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 🚀 クイックアクション             │ │
│ │ [📱 ポチッとスキャン]             │ │
│ │ [✏️ 手動で追加]                  │ │
│ │ [🛒 買い物リスト]                │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

### 状態管理（HomeFeature.State）
```swift
struct State: Equatable {
  var statistics: DashboardStatistics = .init()
  var urgentItems: [UrgentItem] = []
  var isLoading = false
  var lastRefreshed: Date?
  
  // Presentations
  @Presents var scanner: ScannerFeature.State?
  @Presents var addItem: AddItemFeature.State?
}

struct DashboardStatistics: Equatable {
  var totalItems: Int = 0
  var expiringSoon: Int = 0
  var addedToday: Int = 0
  var outOfStock: Int = 0
}
```

### アクション
```swift
enum Action: ViewAction {
  case view(View)
  case statisticsLoaded(DashboardStatistics)
  case urgentItemsLoaded([UrgentItem])
  case scanner(PresentationAction<ScannerFeature.Action>)
  case addItem(PresentationAction<AddItemFeature.Action>)
  
  enum View: Sendable {
    case onAppear
    case refreshTapped
    case quickScanTapped
    case quickAddTapped
    case shoppingListTapped
    case urgentItemTapped(UrgentItem.ID)
  }
}
```

### インタラクション
- **Pull to Refresh**: 統計情報の更新
- **クイックアクション**: 主要機能への導線
- **緊急アイテムタップ**: 商品詳細へ遷移

---

## 📦 2. 在庫一覧画面（InventoryView）

### 画面概要
- **目的**: 在庫商品の一覧表示・管理
- **アクセス**: TabViewの在庫タブ
- **権限**: 特になし

### UI構成
```
┌─────────────────────────────────────┐
│ 📦 在庫一覧     🔍 検索  ⚙️ フィルター │
├─────────────────────────────────────┤
│ 🔍 商品を検索...                    │
├─────────────────────────────────────┤
│ 📂 カテゴリー: [すべて ▼]           │
│ 🔄 並び順: [作成日 ▼]               │
├─────────────────────────────────────┤
│ ┌─────────────────────────────────┐ │
│ │ 🥛 牛乳                          │ │
│ │ 冷蔵 | 2個 | 明日期限切れ ⚠️      │ │
│ │ [➖] [2] [➕]                     │ │
│ └─────────────────────────────────┘ │
│ ┌─────────────────────────────────┐ │
│ │ 🍞 食パン                        │ │
│ │ 常温 | 1個 | 3日後期限切れ       │ │
│ │ [➖] [1] [➕]                     │ │
│ └─────────────────────────────────┘ │
│ ┌─────────────────────────────────┐ │
│ │ 🥚 卵                            │ │
│ │ 冷蔵 | 0個 | 在庫切れ ❌         │ │
│ │ [買い物リストに追加済み]         │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ [➕ 新しい商品を追加]             │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

### 状態管理（InventoryFeature.State）
```swift
struct State: Equatable {
  var items: IdentifiedArrayOf<InventoryItem> = []
  var searchQuery = ""
  var selectedCategory: Category = .all
  var sortOrder: SortOrder = .createdAt
  var isLoading = false
  var showingFilters = false
  
  // Computed properties
  var filteredItems: [InventoryItem] {
    items
      .filter { searchQuery.isEmpty || $0.name.localizedCaseInsensitiveContains(searchQuery) }
      .filter { selectedCategory == .all || $0.category == selectedCategory }
      .sorted(by: sortOrder.comparator)
  }
  
  // Presentations
  @Presents var itemDetail: ItemDetailFeature.State?
  @Presents var addItem: AddItemFeature.State?
  @Presents var editItem: EditItemFeature.State?
}
```

### アクション
```swift
enum Action: ViewAction {
  case view(View)
  case itemsLoaded([InventoryItem])
  case itemDetail(PresentationAction<ItemDetailFeature.Action>)
  case addItem(PresentationAction<AddItemFeature.Action>)
  case editItem(PresentationAction<EditItemFeature.Action>)
  
  enum View: Sendable {
    case onAppear
    case searchQueryChanged(String)
    case categorySelected(Category)
    case sortOrderSelected(SortOrder)
    case itemTapped(InventoryItem.ID)
    case incrementQuantity(InventoryItem.ID)
    case decrementQuantity(InventoryItem.ID)
    case deleteItem(InventoryItem.ID)
    case addItemTapped
  }
}
```

### インタラクション
- **検索**: リアルタイム検索（debounced）
- **フィルター**: カテゴリー・並び順変更
- **数量変更**: +/- ボタンでの即座反映
- **スワイプアクション**: 編集・削除
- **ロングプレス**: 複数選択モード

---

## 📱 3. スキャン画面（ScannerView）

### 画面概要
- **目的**: バーコードスキャンによる商品登録
- **アクセス**: TabViewのスキャンタブ
- **権限**: カメラアクセス

### UI構成
```
┌─────────────────────────────────────┐
│ 📱 スキャン          [💡] [⚙️ 設定] │
├─────────────────────────────────────┤
│                                     │
│ ┌─────────────────────────────────┐ │
│ │                                 │ │
│ │          📷 カメラ              │ │
│ │        プレビュー画面           │ │
│ │                                 │ │
│ │    ┌─────────────────┐          │ │
│ │    │                 │          │ │
│ │    │   スキャン範囲   │          │ │
│ │    │                 │          │ │
│ │    └─────────────────┘          │ │
│ │                                 │ │
│ └─────────────────────────────────┘ │
│                                     │
│ バーコードを枠内に合わせてください   │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 📝 手動で追加                    │ │
│ │ バーコードが読み取れない場合     │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 🔄 連続スキャンモード            │ │
│ │ 複数商品を一度に登録             │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

### 状態管理（ScannerFeature.State）
```swift
struct State: Equatable {
  var scanMode: ScanMode = .single
  var isScanning = false
  var scannedBarcode: String?
  var torchEnabled = false
  var hasPermission = false
  var permissionDenied = false
  var continuousScannedItems: [ScannedItem] = []
  
  // Presentations
  @Presents var productDetail: ProductDetailFeature.State?
  @Presents var manualAdd: AddItemFeature.State?
  @Presents var batchConfirm: BatchConfirmFeature.State?
}

enum ScanMode: CaseIterable {
  case single      // 単発スキャン
  case continuous  // 連続スキャン
}
```

### アクション
```swift
enum Action: ViewAction {
  case view(View)
  case scanResult(String)
  case permissionResponse(Bool)
  case productDetail(PresentationAction<ProductDetailFeature.Action>)
  case manualAdd(PresentationAction<AddItemFeature.Action>)
  case batchConfirm(PresentationAction<BatchConfirmFeature.Action>)
  
  enum View: Sendable {
    case onAppear
    case startScanning
    case stopScanning
    case toggleTorch
    case toggleScanMode
    case manualAddTapped
    case batchConfirmTapped
    case clearScannedItems
  }
}
```

### インタラクション
- **スキャン**: 自動検出とフィードバック
- **トーチ**: 暗所でのスキャン補助
- **モード切替**: 単発/連続スキャン
- **手動追加**: スキャン不可時の代替手段

---

## 🛒 4. 買い物リスト画面（ShoppingListView）

### 画面概要
- **目的**: 必要商品の管理と購入確認
- **アクセス**: TabViewの買い物リストタブ
- **権限**: 特になし

### UI構成
```
┌─────────────────────────────────────┐
│ 🛒 買い物リスト    [🗑️ 全削除] [編集]  │
├─────────────────────────────────────┤
│ 📝 新しいアイテムを追加...           │
├─────────────────────────────────────┤
│ 📊 5個のアイテム（2個完了）          │
├─────────────────────────────────────┤
│ ☑️ 牛乳                             │
│    冷蔵 | 2個必要 | 自動追加         │
│    [在庫に戻す]                     │
│                                     │
│ ☑️ パン                             │
│    常温 | 1個必要 | 手動追加         │
│    [在庫に戻す]                     │
│                                     │
│ ☐ 卵                               │
│    冷蔵 | 10個必要 | 自動追加        │
│    [完了]                           │
│                                     │
│ ☐ 醤油                             │
│    常温 | 1個必要 | 手動追加         │
│    [完了]                           │
│                                     │
│ ☐ 玉ねぎ                           │
│    常温 | 3個必要 | 手動追加         │
│    [完了]                           │
└─────────────────────────────────────┘
```

### 状態管理（ShoppingListFeature.State）
```swift
struct State: Equatable {
  var items: IdentifiedArrayOf<ShoppingItem> = []
  var newItemName = ""
  var checkedItems: Set<ShoppingItem.ID> = []
  var isEditing = false
  var showingDeleteConfirmation = false
  
  // Computed properties
  var pendingItems: [ShoppingItem] {
    items.filter { !checkedItems.contains($0.id) }
  }
  
  var completedItems: [ShoppingItem] {
    items.filter { checkedItems.contains($0.id) }
  }
  
  // Presentations
  @Presents var addItem: AddShoppingItemFeature.State?
  @Presents var editItem: EditShoppingItemFeature.State?
}
```

### アクション
```swift
enum Action: ViewAction {
  case view(View)
  case itemsLoaded([ShoppingItem])
  case itemAdded(ShoppingItem)
  case addItem(PresentationAction<AddShoppingItemFeature.Action>)
  case editItem(PresentationAction<EditShoppingItemFeature.Action>)
  
  enum View: Sendable {
    case onAppear
    case newItemNameChanged(String)
    case addItemTapped
    case itemChecked(ShoppingItem.ID)
    case itemUnchecked(ShoppingItem.ID)
    case restockItem(ShoppingItem.ID)
    case deleteItem(ShoppingItem.ID)
    case deleteAllCompleted
    case editModeToggled
  }
}
```

### インタラクション
- **チェック**: 購入完了のマーク
- **在庫復帰**: 購入完了商品を在庫に追加
- **編集モード**: 複数選択・削除
- **クイック追加**: テキスト入力での即座追加

---

## ⚙️ 5. 設定画面（SettingsView）

### 画面概要
- **目的**: アプリの設定とデータ管理
- **アクセス**: TabViewの設定タブ
- **権限**: 通知・データアクセス

### UI構成
```
┌─────────────────────────────────────┐
│ ⚙️ 設定                              │
├─────────────────────────────────────┤
│ 🔔 通知設定                          │
│ 期限切れ通知やリマインダーの設定     │
│                                 〉  │
├─────────────────────────────────────┤
│ 📂 カテゴリー管理                    │
│ 商品カテゴリーの追加・編集           │
│                                 〉  │
├─────────────────────────────────────┤
│ 💾 データ管理                        │
│ バックアップ・復元・エクスポート     │
│                                 〉  │
├─────────────────────────────────────┤
│ 🎨 アプリの外観                      │
│ テーマ・表示設定                     │
│                                 〉  │
├─────────────────────────────────────┤
│ ❓ ヘルプ・サポート                   │
│ 使い方・お問い合わせ                 │
│                                 〉  │
├─────────────────────────────────────┤
│ ℹ️ アプリについて                     │
│ ライセンス・プライバシーポリシー     │
│                                 〉  │
├─────────────────────────────────────┤
│ 📊 使用統計                          │
│ アプリの利用状況を改善に活用         │
│ [有効] / [無効]                     │
└─────────────────────────────────────┘
```

### 状態管理（SettingsFeature.State）
```swift
struct State: Equatable {
  var notificationSettings: NotificationSettings = .init()
  var appearanceSettings: AppearanceSettings = .init()
  var dataSettings: DataSettings = .init()
  var analyticsEnabled = true
  
  // Presentations
  @Presents var notifications: NotificationSettingsFeature.State?
  @Presents var categories: CategoryManagementFeature.State?
  @Presents var dataManagement: DataManagementFeature.State?
  @Presents var appearance: AppearanceSettingsFeature.State?
  @Presents var about: AboutFeature.State?
}
```

### アクション
```swift
enum Action: ViewAction {
  case view(View)
  case settingsLoaded(Settings)
  case notifications(PresentationAction<NotificationSettingsFeature.Action>)
  case categories(PresentationAction<CategoryManagementFeature.Action>)
  case dataManagement(PresentationAction<DataManagementFeature.Action>)
  case appearance(PresentationAction<AppearanceSettingsFeature.Action>)
  case about(PresentationAction<AboutFeature.Action>)
  
  enum View: Sendable {
    case onAppear
    case notificationsTapped
    case categoriesTapped
    case dataManagementTapped
    case appearanceTapped
    case helpTapped
    case aboutTapped
    case analyticsToggled(Bool)
  }
}
```

---

## 📄 6. 商品詳細画面（ItemDetailView）

### 画面概要
- **目的**: 商品情報の詳細表示と編集
- **アクセス**: 在庫一覧からの遷移
- **権限**: 写真ライブラリ（画像変更時）

### UI構成
```
┌─────────────────────────────────────┐
│ 〈 戻る          商品詳細     [編集] │
├─────────────────────────────────────┤
│ ┌─────────────────────────────────┐ │
│ │                                 │ │
│ │        🥛 商品画像              │ │
│ │                                 │ │
│ └─────────────────────────────────┘ │
│                                     │
│ 🥛 牛乳                             │
│ 冷蔵食品                           │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 📦 在庫情報                      │ │
│ │ 現在の在庫: 2個                  │ │
│ │ [➖] [2] [➕]                     │ │
│ │                                 │ │
│ │ 📅 賞味期限: 2024/06/22          │ │
│ │ ⚠️ 明日期限切れです！             │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 📊 履歴                          │ │
│ │ 登録日: 2024/06/20               │ │
│ │ 最終更新: 2024/06/21             │ │
│ │ 消費回数: 3回                    │ │
│ └─────────────────────────────────┘ │
│                                     │
│ [🗑️ 削除]                           │
└─────────────────────────────────────┘
```

### 状態管理（ItemDetailFeature.State）
```swift
struct State: Equatable {
  var item: InventoryItem
  var isEditing = false
  var showingDeleteConfirmation = false
  var showingImagePicker = false
  
  // Computed properties
  var expiryStatus: ExpiryStatus {
    ExpiryCalculator.status(for: item.expiryDate)
  }
  
  var daysUntilExpiry: Int {
    ExpiryCalculator.daysUntilExpiry(item.expiryDate)
  }
  
  // Presentations
  @Presents var editItem: EditItemFeature.State?
  @Presents var imagePicker: ImagePickerFeature.State?
}
```

### アクション
```swift
enum Action: ViewAction {
  case view(View)
  case itemUpdated(InventoryItem)
  case editItem(PresentationAction<EditItemFeature.Action>)
  case imagePicker(PresentationAction<ImagePickerFeature.Action>)
  
  enum View: Sendable {
    case onAppear
    case editTapped
    case incrementQuantity
    case decrementQuantity
    case changeImageTapped
    case deleteItemTapped
    case deleteConfirmed
  }
}
```

---

## ✏️ 7. 商品追加画面（AddItemView）

### 画面概要
- **目的**: 新規商品の手動登録
- **アクセス**: 各画面からのモーダル表示
- **権限**: 写真ライブラリ（画像追加時）

### UI構成
```
┌─────────────────────────────────────┐
│ [キャンセル]    商品追加     [保存] │
├─────────────────────────────────────┤
│ ┌─────────────────────────────────┐ │
│ │ [📷 写真を追加]                  │ │
│ │                                 │ │
│ └─────────────────────────────────┘ │
│                                     │
│ 商品名 *                           │
│ ┌─────────────────────────────────┐ │
│ │ 商品名を入力...                  │ │
│ └─────────────────────────────────┘ │
│                                     │
│ カテゴリー *                        │
│ ┌─────────────────────────────────┐ │
│ │ 冷蔵食品                 ▼     │ │
│ └─────────────────────────────────┘ │
│                                     │
│ 数量 *                             │
│ ┌─────────────────────────────────┐ │
│ │ [➖] [1] [➕]                     │ │
│ └─────────────────────────────────┘ │
│                                     │
│ 賞味期限                           │
│ ┌─────────────────────────────────┐ │
│ │ [🗓️ 期限を設定]                   │ │
│ └─────────────────────────────────┘ │
│                                     │
│ メモ                               │
│ ┌─────────────────────────────────┐ │
│ │ 商品のメモを入力...              │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

### 状態管理（AddItemFeature.State）
```swift
struct State: Equatable {
  var name = ""
  var category: Category = .refrigerated
  var quantity = 1
  var expiryDate: Date?
  var hasExpiryDate = false
  var memo = ""
  var selectedImage: Data?
  var isLoading = false
  var validationErrors: Set<ValidationError> = []
  
  // Computed properties
  var isValid: Bool {
    !name.isEmpty && quantity > 0
  }
  
  // Presentations
  @Presents var imagePicker: ImagePickerFeature.State?
  @Presents var datePicker: DatePickerFeature.State?
}

enum ValidationError: CaseIterable {
  case emptyName
  case invalidQuantity
  case futureExpiryDate
}
```

### アクション
```swift
enum Action: ViewAction {
  case view(View)
  case itemSaved(InventoryItem)
  case imagePicker(PresentationAction<ImagePickerFeature.Action>)
  case datePicker(PresentationAction<DatePickerFeature.Action>)
  
  enum View: Sendable {
    case nameChanged(String)
    case categoryChanged(Category)
    case quantityChanged(Int)
    case expiryDateToggled(Bool)
    case expiryDateChanged(Date)
    case memoChanged(String)
    case addImageTapped
    case saveItemTapped
    case cancelTapped
  }
}
```

---

## 🔔 8. 通知設定画面（NotificationSettingsView）

### 画面概要
- **目的**: プッシュ通知の詳細設定
- **アクセス**: 設定画面からの遷移
- **権限**: 通知許可

### UI構成
```
┌─────────────────────────────────────┐
│ 〈 戻る          通知設定            │
├─────────────────────────────────────┤
│ 📱 通知の許可                        │
│ 期限切れ通知を受け取るには           │
│ 通知を許可してください               │
│ [設定アプリで許可] ・ 許可済み ✅    │
├─────────────────────────────────────┤
│ ⏰ 期限切れ通知 [●●●●○○○]           │
│ 賞味期限の何日前に通知するか         │
│ 現在の設定: 3日前                   │
│                                     │
│ 📅 通知タイミング                    │
│ ┌─────────────────────────────────┐ │
│ │ ☑️ 1日前                         │ │
│ │ ☑️ 2日前                         │ │
│ │ ☑️ 3日前                         │ │
│ │ ☐ 5日前                         │ │
│ │ ☐ 7日前                         │ │
│ └─────────────────────────────────┘ │
│                                     │
│ 🕐 通知時刻                          │
│ ┌─────────────────────────────────┐ │
│ │ 朝の通知: 09:00                  │ │
│ │ 夕方の通知: 18:00                │ │
│ └─────────────────────────────────┘ │
│                                     │
│ 🛒 買い物リスト通知 [●●●○○○○]        │
│ 在庫切れ時の自動通知                 │
│                                     │
│ 📊 週次レポート通知 [●●○○○○○]        │
│ 週に1回の在庫状況レポート            │
└─────────────────────────────────────┘
```

---

## 📱 9. オンボーディング画面（OnboardingView）

### 画面概要
- **目的**: 初回ユーザーへのアプリ紹介
- **アクセス**: 初回起動時の自動表示
- **権限**: カメラ・通知の事前説明

### UI構成（3画面構成）

#### 画面1: ようこそ
```
┌─────────────────────────────────────┐
│                                     │
│ ┌─────────────────────────────────┐ │
│ │                                 │ │
│ │          🐕 ポチ                │ │
│ │        マスコット               │ │
│ │                                 │ │
│ └─────────────────────────────────┘ │
│                                     │
│ 　　　 Pochiへようこそ！             │
│                                     │
│ 「ポチッと」簡単に在庫管理          │
│                                     │
│ バーコードをスキャンするだけで       │
│ 商品を登録、賞味期限もしっかり管理   │
│                                     │
│ [○○●] [スキップ] [次へ]             │
└─────────────────────────────────────┘
```

#### 画面2: 主要機能
```
┌─────────────────────────────────────┐
│                                     │
│ ┌─────────────────────────────────┐ │
│ │                                 │ │
│ │        📱 スキャン               │ │
│ │       アニメーション             │ │
│ │                                 │ │
│ └─────────────────────────────────┘ │
│                                     │
│ 　　　 ポチッとスキャン             │
│                                     │
│ バーコードをスキャンするだけで       │
│ 商品情報を自動取得                   │
│                                     │
│ 手動入力も可能で、よく使う商品は     │
│ 「ポチリスト」に登録して             │
│ ワンタップ追加                       │
│                                     │
│ [○●○] [スキップ] [次へ]             │
└─────────────────────────────────────┘
```

#### 画面3: 権限許可
```
┌─────────────────────────────────────┐
│                                     │
│ ┌─────────────────────────────────┐ │
│ │                                 │ │
│ │        🔔 通知                  │ │
│ │       アイコン                   │ │
│ │                                 │ │
│ └─────────────────────────────────┘ │
│                                     │
│ 　　　 通知でお知らせ               │
│                                     │
│ 賞味期限が近づいたら通知でお知らせ   │
│ 大切な食材を無駄にしません           │
│                                     │
│ 📷 カメラ: バーコードスキャン用      │
│ 🔔 通知: 期限切れ前のお知らせ用      │
│                                     │
│ [●○○] [後で] [許可して始める]       │
└─────────────────────────────────────┘
```

### 状態管理（OnboardingFeature.State）
```swift
struct State: Equatable {
  var currentPage = 0
  var totalPages = 3
  var hasSeenOnboarding = false
  var permissionStatus: PermissionStatus = .notDetermined
  
  // Presentations
  @Presents var permissionRequest: PermissionRequestFeature.State?
}
```

---

## 🎯 ユーザビリティ配慮事項

### アクセシビリティ
- **VoiceOver**: 全要素に適切なラベル設定
- **Dynamic Type**: 文字サイズ変更に対応
- **Color Contrast**: WCAG AA準拠
- **Reduce Motion**: アニメーション削減設定

### エラーハンドリング
- **ネットワークエラー**: 「ポチッと失敗...もう一度お試しください」
- **カメラエラー**: 「カメラが使用できません。設定を確認してください」
- **保存エラー**: 「保存に失敗しました。しばらく待ってから再試行してください」

### パフォーマンス最適化
- **遅延読み込み**: 大量アイテムのLazy Loading
- **画像最適化**: 自動リサイズとキャッシュ
- **検索最適化**: デバウンス処理（0.5秒）
- **メモリ管理**: 適切なライフサイクル管理

### ブランディング統一
- **「ポチ」文言**: 操作完了時の親しみやすいメッセージ
- **サウンド**: 「ポチッ」音での操作フィードバック
- **アニメーション**: 楽しさを演出する適度なアニメーション
- **カラー**: 温かみのあるオレンジ系メインカラー

---

**作成日**: 2025年6月21日  
**更新日**: 2025年6月21日  
**バージョン**: 1.0  
**作成者**: Pochi開発チーム  