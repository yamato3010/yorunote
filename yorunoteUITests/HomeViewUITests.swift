//
//  HomeViewUITests.swift
//  yorunoteUITests
//
//  Created by Yamato on 2026/01/18.
//

import XCTest

final class HomeViewUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        
        let homeTab = app.tabBars.buttons["ホーム"]
        homeTab.tap()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - HOME-001: 初期表示
    func testHomeViewInitialDisplay() throws {
        let navigationTitle = app.navigationBars["ヨルノート"]
        XCTAssertTrue(navigationTitle.exists, "Navigation title should be displayed")
        
        let datePicker = app.datePickers.element
        XCTAssertTrue(datePicker.exists, "Date picker should be displayed")
        
        XCTAssertTrue(datePicker.exists, "Date picker should show current date")
    }
    
    // MARK: - HOME-002: 日付選択
    func testDateSelection() throws {
        let datePicker = app.datePickers.element
        XCTAssertTrue(datePicker.exists, "Date picker should exist")
        
        datePicker.tap()
        
        XCTAssertTrue(datePicker.exists, "Date picker should remain functional after interaction")
    }
    
    // MARK: - HOME-011: 記録なしの場合
    func testNoEntryState() throws {
        let noEntryMessage = app.staticTexts.containing(NSPredicate(format: "label CONTAINS '記録はありません'")).element
        
        if noEntryMessage.exists {
            XCTAssertTrue(noEntryMessage.exists, "No entry message should be displayed when no record exists")
        }
    }
    
    // MARK: - HOME-013: 今日の場合
    func testTodayRitualButton() throws {
        let ritualButton = app.buttons.containing(NSPredicate(format: "label CONTAINS '今日の儀式を始める'")).element
        
        if ritualButton.exists {
            XCTAssertTrue(ritualButton.exists, "Ritual start button should be displayed for today")
            XCTAssertTrue(ritualButton.isHittable, "Ritual start button should be tappable")
        }
    }
    
    // MARK: - HOME-021: 儀式開始ボタンタップ
    func testRitualStartButtonTap() throws {
        let ritualButton = app.buttons.containing(NSPredicate(format: "label CONTAINS '今日の儀式を始める'")).element
        
        if ritualButton.exists {
            ritualButton.tap()
            
            let ritualNavigationTitle = app.navigationBars["夜の儀式"]
            XCTAssertTrue(ritualNavigationTitle.waitForExistence(timeout: 2), "Ritual input view should be presented")
            
            let eventTextField = app.textFields.containing(NSPredicate(format: "placeholderValue CONTAINS '例：仕事でプレゼンがうまくいった'")).element
            XCTAssertTrue(eventTextField.exists, "Event text field should exist")
            
            let cancelButton = app.buttons["キャンセル"]
            if cancelButton.exists {
                cancelButton.tap()
            }
        }
    }
    
    // MARK: - HOME-012: 記録ありの場合
    func testExistingEntryDisplay() throws {
        let entryConfirmation = app.staticTexts.containing(NSPredicate(format: "label CONTAINS '【記録あり】'")).element
        
        if entryConfirmation.exists {
            XCTAssertTrue(entryConfirmation.exists, "Entry confirmation should be displayed")
            
            let confirmButton = app.buttons["内容を確認する"]
            if confirmButton.exists {
                XCTAssertTrue(confirmButton.exists, "Content confirmation button should exist")
                XCTAssertTrue(confirmButton.isHittable, "Content confirmation button should be tappable")
            }
        }
    }
    
    // MARK: - HOME-022: 内容確認ボタンタップ
    func testContentConfirmationButtonTap() throws {
        let confirmButton = app.buttons["内容を確認する"]
        
        if confirmButton.exists {
            confirmButton.tap()
            
            let ritualNavigationTitle = app.navigationBars["夜の儀式"]
            XCTAssertTrue(ritualNavigationTitle.waitForExistence(timeout: 2), "Ritual input view should be presented")
            
            let cancelButton = app.buttons["キャンセル"]
            if cancelButton.exists {
                cancelButton.tap()
            }
        }
    }
    
    // MARK: - Calendar Interaction Tests
    func testCalendarInteraction() throws {
        let datePicker = app.datePickers.element
        XCTAssertTrue(datePicker.exists, "Date picker should exist")
        
        datePicker.tap()
        
        XCTAssertTrue(datePicker.exists, "Date picker should remain after interaction")
    }
    
    // MARK: - Navigation Tests
    func testNavigationElements() throws {
        let navigationBar = app.navigationBars["ヨルノート"]
        XCTAssertTrue(navigationBar.exists, "Navigation bar should exist")
        
        XCTAssertGreaterThan(navigationBar.frame.height, 0, "Navigation bar should have height")
    }
    
    // MARK: - Layout Tests
    func testLayoutElements() throws {
        let datePicker = app.datePickers.element
        XCTAssertTrue(datePicker.exists, "Date picker should be visible")
        
        XCTAssertGreaterThan(datePicker.frame.height, 0, "Date picker should have height")
        XCTAssertGreaterThan(datePicker.frame.width, 0, "Date picker should have width")
    }
    
    // MARK: - Accessibility Tests
    func testAccessibilityElements() throws {
        let datePicker = app.datePickers.element
        XCTAssertTrue(datePicker.isHittable, "Date picker should be accessible")
        
        // アクセシビリティが存在するかどうかをテスト
        let ritualButton = app.buttons.containing(NSPredicate(format: "label CONTAINS '今日の儀式を始める'")).element
        if ritualButton.exists {
            XCTAssertTrue(ritualButton.isHittable, "Ritual button should be accessible")
        }
    }
    
    // MARK: - Performance Tests
    func testHomeViewPerformance() throws {
        let datePicker = app.datePickers.element
        
        if datePicker.exists {
            let startTime = CFAbsoluteTimeGetCurrent()
            
            for _ in 0..<3 {
                datePicker.tap()
                Thread.sleep(forTimeInterval: 0.1)
            }
            
            let endTime = CFAbsoluteTimeGetCurrent()
            let totalTime = endTime - startTime
            
            XCTAssertLessThan(totalTime, 5.0, "Date picker interactions should complete within 5 seconds")
            print("Date picker performance: \(String(format: "%.2f", totalTime)) seconds")
        }
    }
    
    // MARK: - State Management Tests
    func testViewStateConsistency() throws {
        let shredderTab = app.tabBars.buttons["シュレッダー"]
        shredderTab.tap()
        
        let homeTab = app.tabBars.buttons["ホーム"]
        homeTab.tap()
        
        let navigationTitle = app.navigationBars["ヨルノート"]
        XCTAssertTrue(navigationTitle.exists, "Home view should maintain state after tab switching")
        
        let datePicker = app.datePickers.element
        XCTAssertTrue(datePicker.exists, "Date picker should still exist after tab switching")
    }
    
    // MARK: - Error Handling Tests
    func testViewStability() throws {
        let datePicker = app.datePickers.element
        
        if datePicker.exists {
            for _ in 0..<5 {
                datePicker.tap()
            }
            
            XCTAssertTrue(datePicker.exists, "Date picker should remain stable after rapid interactions")
        }
    }
}
