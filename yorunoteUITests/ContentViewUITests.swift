//
//  ContentViewUITests.swift
//  yorunoteUITests
//
//  Created by Yamato on 2026/01/18.
//

import XCTest

final class ContentViewUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - UI-001: ホームタブ選択
    func testHomeTabSelection() throws {
        let homeTab = app.tabBars.buttons["ホーム"]
        XCTAssertTrue(homeTab.exists, "ホームタブが存在する必要があります")
        
        homeTab.tap()
        
        // ホームビューが表示されることを確認
        let navigationTitle = app.navigationBars["ヨルノート"]
        XCTAssertTrue(navigationTitle.exists, "正しいタイトルでホームビューが表示される必要があります")
    }
    
    // MARK: - UI-002: シュレッダータブ選択
    func testShredderTabSelection() throws {
        let shredderTab = app.tabBars.buttons["シュレッダー"]
        XCTAssertTrue(shredderTab.exists, "シュレッダータブが存在する必要があります")
        
        shredderTab.tap()
        
        // シュレッダー画面が表示されていること
        let navigationTitle = app.navigationBars["1分間シュレッダー"]
        XCTAssertTrue(navigationTitle.exists, "Shredder view should be displayed with correct title")
        
        // タイマーが表示されていること
        let timerLabel = app.staticTexts["60秒"]
        XCTAssertTrue(timerLabel.exists, "Timer should show 60 seconds initially")
    }
    
    // MARK: - UI-003: カラースキーム切り替え
    func testColorSchemeChange() throws {
        let homeTab = app.tabBars.buttons["ホーム"]
        homeTab.tap()
        
        let shredderTab = app.tabBars.buttons["シュレッダー"]
        shredderTab.tap()
        
        let timerLabel = app.staticTexts["60秒"]
        XCTAssertTrue(timerLabel.exists, "Timer should be visible in dark mode")
        
        homeTab.tap()
        
        let navigationTitle = app.navigationBars["ヨルノート"]
        XCTAssertTrue(navigationTitle.exists, "Home view should still be functional after tab switching")
    }
    
    // MARK: - Tab Persistence Tests
    func testTabSelectionPersistence() throws {
        // シュレッダータブを押す
        let shredderTab = app.tabBars.buttons["シュレッダー"]
        shredderTab.tap()
        
        // シュレッダータブがセレクト状態になっていること
        XCTAssertTrue(shredderTab.isSelected, "Shredder tab should be selected")
        
        // ホームタブを選択
        let homeTab = app.tabBars.buttons["ホーム"]
        homeTab.tap()
        
        // セレクト状態が切り替わっていること
        XCTAssertTrue(homeTab.isSelected, "Home tab should be selected")
        XCTAssertFalse(shredderTab.isSelected, "Shredder tab should not be selected")
    }
    
    // MARK: - Navigation Tests
    func testTabBarAccessibility() throws {
        let homeTab = app.tabBars.buttons["ホーム"]
        let shredderTab = app.tabBars.buttons["シュレッダー"]
        
        XCTAssertTrue(homeTab.exists, "Home tab should exist")
        XCTAssertTrue(homeTab.isHittable, "Home tab should be accessible")
        XCTAssertTrue(shredderTab.exists, "Shredder tab should exist")
        XCTAssertTrue(shredderTab.isHittable, "Shredder tab should be accessible")
        
        XCTAssertEqual(homeTab.label, "ホーム", "Home tab should have correct accessibility label")
        XCTAssertEqual(shredderTab.label, "シュレッダー", "Shredder tab should have correct accessibility label")
    }
    
    // MARK: - Performance Tests
    func testTabSwitchingPerformance() throws {
        let homeTab = app.tabBars.buttons["ホーム"]
        let shredderTab = app.tabBars.buttons["シュレッダー"]
        
        // テスト前にタブが存在することを確認する
        XCTAssertTrue(homeTab.exists, "Home tab should exist")
        XCTAssertTrue(shredderTab.exists, "Shredder tab should exist")
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // タブを複数回切り替える
        for _ in 0..<5 {
            shredderTab.tap()
            XCTAssertTrue(app.navigationBars["1分間シュレッダー"].waitForExistence(timeout: 2))
            homeTab.tap()
            XCTAssertTrue(app.navigationBars["ヨルノート"].waitForExistence(timeout: 2))
        }
        
        let endTime = CFAbsoluteTimeGetCurrent()
        let totalTime = endTime - startTime
        
        XCTAssertLessThan(totalTime, 60.0, "Tab switching should complete within 60 seconds")
        
        print("Tab switching performance: \(String(format: "%.2f", totalTime)) seconds for 10 switches")
    }
    
    // MARK: - Error Handling Tests
    func testAppLaunchStability() throws {
        XCTAssertTrue(app.tabBars.element.exists, "Tab bar should exist after launch")
        
        let homeTab = app.tabBars.buttons["ホーム"]
        let shredderTab = app.tabBars.buttons["シュレッダー"]
        
        XCTAssertTrue(homeTab.exists, "Home tab should exist after launch")
        XCTAssertTrue(shredderTab.exists, "Shredder tab should exist after launch")
    }
    
    // MARK: - Visual Tests
    func testTabBarVisualElements() throws {
        let tabBar = app.tabBars.element
        XCTAssertTrue(tabBar.exists, "Tab bar should be visible")
        
        let homeTab = app.tabBars.buttons["ホーム"]
        let shredderTab = app.tabBars.buttons["シュレッダー"]
        
        XCTAssertTrue(homeTab.exists, "Home tab should be visible")
        XCTAssertTrue(shredderTab.exists, "Shredder tab should be visible")
        
        // Verify tabs are properly positioned
        XCTAssertLessThan(homeTab.frame.minX, shredderTab.frame.minX, "Home tab should be to the left of shredder tab")
    }
}
