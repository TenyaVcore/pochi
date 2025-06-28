//
//  InventoryE2ETests.swift
//  PochiUITests
//
//  Created by Claude Code on 2025/06/28.
//

import XCTest

/// TDD Red Phase: 在庫管理機能のE2Eテスト
/// 
/// このテストは意図的に失敗するように作成されています。
/// 実装が進むにつれて段階的に成功するようになります。
final class InventoryE2ETests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    /// ユーザーが在庫管理を行うEnd-to-Endシナリオ
    ///
    /// ❌ このテストは最初は失敗する（実装がないため）
    ///
    /// シナリオ:
    /// 1. アプリ起動 → 在庫タブ選択
    /// 2. 商品追加 → 牛乳を登録
    /// 3. 一覧確認 → 牛乳が表示される
    /// 4. 数量変更 → +ボタンで数量増加
    /// 5. 詳細表示 → 商品詳細画面へ遷移
    /// 6. 削除操作 → 商品を削除
    func testUserCanManageInventoryEndToEnd() throws {
        // ❌ 在庫タブが存在しないため失敗
        let inventoryTab = app.tabBars.buttons["在庫"]
        XCTAssertTrue(inventoryTab.exists, "在庫タブが見つからない")
        inventoryTab.tap()
        
        // ❌ 追加ボタンが存在しないため失敗
        let addButton = app.navigationBars.buttons["追加"]
        XCTAssertTrue(addButton.exists, "追加ボタンが見つからない")
        addButton.tap()
        
        // ❌ 商品名入力フィールドが存在しないため失敗
        let nameField = app.textFields["商品名"]
        XCTAssertTrue(nameField.exists, "商品名フィールドが見つからない")
        nameField.typeText("牛乳")
        
        // ❌ カテゴリ選択ボタンが存在しないため失敗
        let categoryButton = app.buttons["冷蔵"]
        XCTAssertTrue(categoryButton.exists, "冷蔵カテゴリボタンが見つからない")
        categoryButton.tap()
        
        // ❌ 数量ステッパーが存在しないため失敗
        let quantityStepper = app.steppers["数量"]
        XCTAssertTrue(quantityStepper.exists, "数量ステッパーが見つからない")
        quantityStepper.buttons["+"].tap()
        
        // ❌ 保存ボタンが存在しないため失敗
        let saveButton = app.buttons["保存"]
        XCTAssertTrue(saveButton.exists, "保存ボタンが見つからない")
        saveButton.tap()
        
        // ❌ 一覧に牛乳が表示されないため失敗
        let milkItem = app.staticTexts["牛乳"]
        XCTAssertTrue(milkItem.exists, "牛乳アイテムが一覧に表示されない")
        
        // ❌ 数量増加ボタンが存在しないため失敗
        let incrementButton = app.buttons["牛乳-数量増加"]
        XCTAssertTrue(incrementButton.exists, "数量増加ボタンが見つからない")
        incrementButton.tap()
        
        // ❌ 数量が更新されないため失敗
        let quantityLabel = app.staticTexts["牛乳-数量"]
        XCTAssertEqual(quantityLabel.label, "2", "数量が正しく更新されない")
        
        // ❌ 詳細画面への遷移ができないため失敗
        milkItem.tap()
        let detailNavBar = app.navigationBars["商品詳細"]
        XCTAssertTrue(detailNavBar.exists, "商品詳細画面に遷移できない")
        
        // ❌ 削除ボタンが存在しないため失敗
        let deleteButton = app.buttons["削除"]
        XCTAssertTrue(deleteButton.exists, "削除ボタンが見つからない")
        deleteButton.tap()
        
        // ❌ 削除確認アラートが表示されないため失敗
        let deleteAlert = app.alerts.buttons["削除"]
        XCTAssertTrue(deleteAlert.exists, "削除確認アラートが表示されない")
        deleteAlert.tap()
        
        // ❌ アイテムが削除されないため失敗
        XCTAssertFalse(app.staticTexts["牛乳"].exists, "牛乳が削除されていない")
    }
    
    /// 商品追加の基本フロー
    ///
    /// ❌ このテストは最初は失敗する（UIが未実装のため）
    func testAddItemBasicFlow() throws {
        app.tabBars.buttons["在庫"].tap()
        app.navigationBars.buttons["追加"].tap()
        
        // 最小限の入力で商品追加
        app.textFields["商品名"].typeText("テスト商品")
        app.buttons["保存"].tap()
        
        // 一覧に表示されることを確認
        XCTAssertTrue(app.staticTexts["テスト商品"].exists)
    }
    
    /// 商品詳細編集の基本フロー
    ///
    /// ❌ このテストは最初は失敗する（UIが未実装のため）
    func testEditItemBasicFlow() throws {
        // 前提: テスト商品が存在する状態
        testAddItemBasicFlow()
        
        // 詳細画面へ遷移
        app.staticTexts["テスト商品"].tap()
        
        // 編集モードに入る
        app.buttons["編集"].tap()
        
        // 商品名を変更
        let nameField = app.textFields["商品名"]
        nameField.clearAndEnterText(text: "編集済み商品")
        
        // 保存
        app.buttons["保存"].tap()
        
        // 変更が反映されることを確認
        XCTAssertTrue(app.staticTexts["編集済み商品"].exists)
    }
}

// MARK: - XCUIElement Extension for Testing

extension XCUIElement {
    /// テキストフィールドの内容をクリアして新しいテキストを入力
    func clearAndEnterText(text: String) {
        guard self.exists else {
            XCTFail("Element does not exist")
            return
        }
        
        self.tap()
        self.press(forDuration: 1.0)
        self.typeText(XCUIKeyboardKey.selectAll.rawValue)
        self.typeText(text)
    }
}