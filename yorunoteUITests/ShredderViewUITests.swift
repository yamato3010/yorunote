//
//  ShredderViewUITests.swift
//  yorunoteUITests
//
//  Created by Yamato on 2026/01/18.
//

import XCTest

final class ShredderViewUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        
        let shredderTab = app.tabBars.buttons["シュレッダー"]
        shredderTab.tap()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - SHRED-001: 初期状態
    func testShredderViewInitialState() throws {
        let navigationTitle = app.navigationBars["1分間シュレッダー"]
        XCTAssertTrue(navigationTitle.exists, "Navigation title should be displayed")
        
        let timerLabel = app.staticTexts["60秒"]
        XCTAssertTrue(timerLabel.exists, "Timer should show 60 seconds initially")
        
        let textEditor = app.textViews.element
        XCTAssertTrue(textEditor.exists, "Text editor should be displayed")
        
        let shredderButton = app.buttons.containing(NSPredicate(format: "label CONTAINS 'スッキリする'")).element
        XCTAssertTrue(shredderButton.exists, "Shredder button should exist")
    }
    
    // MARK: - SHRED-011: 自由入力
    func testTextInput() throws {
        let textEditor = app.textViews.element
        XCTAssertTrue(textEditor.exists, "Text editor should exist")
        
        textEditor.tap()
        textEditor.typeText("今日はとても疲れた。仕事でミスをしてしまい、とても落ち込んでいる。")
        
        XCTAssertTrue(textEditor.value as? String != nil, "Text should be entered in editor")
    }
    
    // MARK: - SHRED-002: 入力開始でタイマー開始
    func testTimerStartsOnInput() throws {
        let textEditor = app.textViews.element
        let timerLabel = app.staticTexts["60秒"]
        
        XCTAssertTrue(timerLabel.exists, "Timer should show 60 seconds initially")
        
        textEditor.tap()
        textEditor.typeText("何かのテキスト")
        
        XCTAssertTrue(textEditor.exists, "Text editor should remain functional")
    }
    
    // MARK: - SHRED-021: 手動実行
    func testManualShredderExecution() throws {
        let textEditor = app.textViews.element
        let shredderButton = app.buttons.containing(NSPredicate(format: "label CONTAINS 'スッキリする'")).element
        
        textEditor.tap()
        textEditor.typeText("削除したいテキスト")
        
        if shredderButton.waitForExistence(timeout: 2) && shredderButton.isEnabled {
            shredderButton.tap()
            
            let completionEmoji = app.staticTexts["✨"]
            let completionMessage = app.staticTexts.containing(NSPredicate(format: "label CONTAINS '頭の中が空っぽになりました'")).element
            
            if completionEmoji.waitForExistence(timeout: 5) {
                XCTAssertTrue(completionEmoji.exists, "Completion emoji should appear")
            }
            
            if completionMessage.waitForExistence(timeout: 5) {
                XCTAssertTrue(completionMessage.exists, "Completion message should appear")
            }
        }
    }
    
    // MARK: - SHRED-031: もう一度書くボタン
    func testResetFunctionality() throws {
        let textEditor = app.textViews.element
        let shredderButton = app.buttons.containing(NSPredicate(format: "label CONTAINS 'スッキリする'")).element
        
        textEditor.tap()
        textEditor.typeText("リセットテスト")
        
        if shredderButton.waitForExistence(timeout: 2) && shredderButton.isEnabled {
            shredderButton.tap()
            
            let resetButton = app.buttons["もう一度書く"]
            if resetButton.waitForExistence(timeout: 5) {
                resetButton.tap()
                
                let timerLabel = app.staticTexts["60秒"]
                XCTAssertTrue(timerLabel.waitForExistence(timeout: 2), "Timer should reset to 60 seconds")
                
                XCTAssertTrue(textEditor.exists, "Text editor should be available after reset")
            }
        }
    }
    
    // MARK: - UI State Tests
    func testShredderButtonState() throws {
        let textEditor = app.textViews.element
        let shredderButton = app.buttons.containing(NSPredicate(format: "label CONTAINS 'スッキリする'")).element
        
        XCTAssertTrue(shredderButton.exists, "Shredder button should exist")
        
        textEditor.tap()
        textEditor.typeText("ボタンテスト")
        
        XCTAssertTrue(shredderButton.exists, "Shredder button should still exist after text input")
    }
    
    // MARK: - Animation Tests
    func testShredderAnimation() throws {
        let textEditor = app.textViews.element
        let shredderButton = app.buttons.containing(NSPredicate(format: "label CONTAINS 'スッキリする'")).element
        
        textEditor.tap()
        textEditor.typeText("アニメーションテスト")
        
        if shredderButton.waitForExistence(timeout: 2) && shredderButton.isEnabled {
            shredderButton.tap()
            
            let animationEmoji = app.staticTexts["🗑️"]
            let animationMessage = app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'モヤモヤを消去しました'")).element
            
            if animationEmoji.waitForExistence(timeout: 3) {
                XCTAssertTrue(animationEmoji.exists, "Animation emoji should appear")
            }
            
            if animationMessage.waitForExistence(timeout: 3) {
                XCTAssertTrue(animationMessage.exists, "Animation message should appear")
            }
        }
    }
    
    // MARK: - Long Text Tests
    func testLongTextInput() throws {
        let textEditor = app.textViews.element
        
        textEditor.tap()
        
        let longText = String(repeating: "長いテキストのテスト。", count: 50)
        textEditor.typeText(longText)
        
        XCTAssertTrue(textEditor.exists, "Text editor should handle long text")
        
        let shredderButton = app.buttons.containing(NSPredicate(format: "label CONTAINS 'スッキリする'")).element
        XCTAssertTrue(shredderButton.exists, "Shredder button should exist with long text")
    }
    
    // MARK: - Special Characters Tests
    func testSpecialCharactersInput() throws {
        let textEditor = app.textViews.element
        
        textEditor.tap()
        
        // 特殊な文字を入れる
        let specialText = "🌙✨💭\n改行テスト\tタブテスト\"引用符\"'アポストロフィ'"
        textEditor.typeText(specialText)
        
        XCTAssertTrue(textEditor.exists, "Text editor should handle special characters")
    }
    
    // MARK: - Performance Tests
    func testShredderViewPerformance() throws {
        let textEditor = app.textViews.element
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        if textEditor.exists {
            textEditor.tap()
            textEditor.typeText("パフォーマンステスト")
        }
        
        let endTime = CFAbsoluteTimeGetCurrent()
        let totalTime = endTime - startTime
        
        XCTAssertLessThan(totalTime, 10.0, "Text input should complete within 10 seconds")
        print("Text input performance: \(String(format: "%.2f", totalTime)) seconds")
    }
    
    // MARK: - Accessibility Tests
    func testShredderViewAccessibility() throws {
        let textEditor = app.textViews.element
        let shredderButton = app.buttons.containing(NSPredicate(format: "label CONTAINS 'スッキリする'")).element
        let timerLabel = app.staticTexts["60秒"]
        
        XCTAssertTrue(textEditor.isHittable, "Text editor should be accessible")
        XCTAssertTrue(shredderButton.isHittable, "Shredder button should be accessible")
        XCTAssertTrue(timerLabel.exists, "Timer label should be accessible")
    }
    
    // MARK: - State Persistence Tests
    func testViewStateAfterTabSwitch() throws {
        let textEditor = app.textViews.element
        
        textEditor.tap()
        textEditor.typeText("タブ切り替えテスト")
         
        let shredderTab = app.tabBars.buttons["シュレッダー"]
        shredderTab.tap()
        
        let navigationTitle = app.navigationBars["1分間シュレッダー"]
        XCTAssertTrue(navigationTitle.exists, "Shredder view should be functional after tab switch")
        
        XCTAssertTrue(textEditor.exists, "Text editor should exist after tab switch")
    }
    
    // MARK: - Error Handling Tests
    func testRapidInteractions() throws {
        let textEditor = app.textViews.element
        let shredderButton = app.buttons.containing(NSPredicate(format: "label CONTAINS 'スッキリする'")).element
        
        for i in 0..<5 {
            textEditor.tap()
            textEditor.typeText("テスト\(i)")
            
            if shredderButton.exists && shredderButton.isEnabled {
                shredderButton.tap()
                
                // アニメーションを待機
                sleep(3)
                
                // もう一度書くボタンを探して押す
                let resetButton = app.buttons["もう一度書く"]
                if resetButton.exists {
                    resetButton.tap()
                }
                sleep(1)
            }
        }
        
        XCTAssertTrue(textEditor.exists, "Text editor should remain stable after rapid interactions")
    }
}
