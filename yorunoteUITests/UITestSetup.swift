//
//  UITestSetup.swift
//  yorunoteUITests
//
//  Created by Yamato on 2026/01/18.
//

import XCTest

/// 共通のセットアップとユーティリティを持つベースUIテストクラス
class BaseUITestCase: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        continueAfterFailure = false
        
        app = XCUIApplication()
        
        // テスト用にアプリを設定
        app.launchArguments.append("--uitesting")
        app.launchEnvironment["UITEST_MODE"] = "1"
        
        app.launch()
        
        // アプリの準備完了を待機
        waitForAppToBeReady()
    }
    
    override func tearDownWithError() throws {
        app.terminate()
        app = nil
        try super.tearDownWithError()
    }
    
    // MARK: - アプリ状態管理
    
    private func waitForAppToBeReady() {
        let tabBar = app.tabBars.element
        XCTAssertTrue(tabBar.waitForExistence(timeout: 10), "アプリが起動してタブバーが表示される必要があります")
    }
    
    /// ホームタブに移動
    func navigateToHome() {
        let homeTab = app.tabBars.buttons["ホーム"]
        if homeTab.exists && !homeTab.isSelected {
            homeTab.tap()
        }
        
        let navigationTitle = app.navigationBars["ヨルノート"]
        XCTAssertTrue(navigationTitle.waitForExistence(timeout: 5), "Should navigate to home view")
    }
    
    /// Navigates to shredder tab
    func navigateToShredder() {
        let shredderTab = app.tabBars.buttons["シュレッダー"]
        if shredderTab.exists && !shredderTab.isSelected {
            shredderTab.tap()
        }
        
        let navigationTitle = app.navigationBars["1分間シュレッダー"]
        XCTAssertTrue(navigationTitle.waitForExistence(timeout: 5), "Should navigate to shredder view")
    }
    
    // MARK: - Ritual Input Helpers
    
    /// Opens ritual input view from home
    func openRitualInput() -> Bool {
        navigateToHome()
        
        let ritualButton = app.buttons.containing(NSPredicate(format: "label CONTAINS '今日の儀式を始める'")).element
        
        if ritualButton.exists {
            ritualButton.tap()
            
            let ritualNavigationTitle = app.navigationBars["夜の儀式"]
            return ritualNavigationTitle.waitForExistence(timeout: 5)
        }
        
        return false
    }
    
    /// Fills ritual input form
    func fillRitualForm(
        eventText: String = "テストイベント",
        feelingText: String = "テスト感情",
        futureText: String = "テスト未来"
    ) {
        // Find text fields by their placeholder text or section headers
        let eventField = app.textFields.containing(NSPredicate(format: "placeholderValue CONTAINS '例：仕事でプレゼンがうまくいった'")).element
        let feelingField = app.textFields.containing(NSPredicate(format: "placeholderValue CONTAINS '例：緊張したけど、達成感があった'")).element
        let futureField = app.textFields.containing(NSPredicate(format: "placeholderValue CONTAINS '例：明日はゆっくりコーヒーでも飲もう'")).element
        
        if eventField.exists {
            eventField.tap()
            eventField.typeText(eventText)
        }
        
        if feelingField.exists {
            feelingField.tap()
            feelingField.typeText(feelingText)
        }
        
        if futureField.exists {
            futureField.tap()
            futureField.typeText(futureText)
        }
    }
    
    /// Saves ritual input
    func saveRitualInput() {
        let saveButton = app.buttons["保存"]
        if saveButton.exists && saveButton.isEnabled {
            saveButton.tap()
        }
    }
    
    /// Cancels ritual input
    func cancelRitualInput() {
        let cancelButton = app.buttons["キャンセル"]
        if cancelButton.exists {
            cancelButton.tap()
        }
    }
    
    // MARK: - Shredder Helpers
    
    /// Enters text in shredder
    func enterShredderText(_ text: String) {
        navigateToShredder()
        
        let textEditor = app.textViews.element
        if textEditor.exists {
            textEditor.tap()
            textEditor.typeText(text)
        }
    }
    
    /// Triggers manual shredding
    func triggerManualShredding() -> Bool {
        let shredderButton = app.buttons.containing(NSPredicate(format: "label CONTAINS 'スッキリする'")).element
        
        if shredderButton.exists && shredderButton.isEnabled {
            shredderButton.tap()
            return true
        }
        
        return false
    }
    
    /// Waits for shredding completion
    func waitForShreddingCompletion() -> Bool {
        let completionEmoji = app.staticTexts["✨"]
        let completionMessage = app.staticTexts.containing(NSPredicate(format: "label CONTAINS '頭の中が空っぽになりました'")).element
        
        return completionEmoji.waitForExistence(timeout: 10) || completionMessage.waitForExistence(timeout: 10)
    }
    
    /// Resets shredder
    func resetShredder() {
        let resetButton = app.buttons["もう一度書く"]
        if resetButton.exists {
            resetButton.tap()
        }
    }
    
    // MARK: - Date Picker Helpers
    
    /// Interacts with date picker
    func selectDate() {
        let datePicker = app.datePickers.element
        if datePicker.exists {
            datePicker.tap()
        }
    }
    
    // MARK: - Assertion Helpers
    
    /// Asserts that an element exists and is hittable
    func assertElementIsAccessible(_ element: XCUIElement, description: String, file: StaticString = #file, line: UInt = #line) {
        XCTAssertTrue(element.exists, "\(description) should exist", file: file, line: line)
        XCTAssertTrue(element.isHittable, "\(description) should be hittable", file: file, line: line)
    }
    
    /// Asserts that text is displayed
    func assertTextIsDisplayed(_ text: String, file: StaticString = #file, line: UInt = #line) {
        let textElement = app.staticTexts[text]
        XCTAssertTrue(textElement.exists, "Text '\(text)' should be displayed", file: file, line: line)
    }
    
    /// Asserts that button is enabled
    func assertButtonIsEnabled(_ buttonIdentifier: String, file: StaticString = #file, line: UInt = #line) {
        let button = app.buttons[buttonIdentifier]
        XCTAssertTrue(button.exists, "Button '\(buttonIdentifier)' should exist", file: file, line: line)
        XCTAssertTrue(button.isEnabled, "Button '\(buttonIdentifier)' should be enabled", file: file, line: line)
    }
    
    /// Asserts that button is disabled
    func assertButtonIsDisabled(_ buttonIdentifier: String, file: StaticString = #file, line: UInt = #line) {
        let button = app.buttons[buttonIdentifier]
        XCTAssertTrue(button.exists, "Button '\(buttonIdentifier)' should exist", file: file, line: line)
        XCTAssertFalse(button.isEnabled, "Button '\(buttonIdentifier)' should be disabled", file: file, line: line)
    }
    
    // MARK: - Wait Helpers
    
    /// Waits for element to exist with custom timeout
    func waitForElement(_ element: XCUIElement, timeout: TimeInterval = 5.0, file: StaticString = #file, line: UInt = #line) {
        XCTAssertTrue(element.waitForExistence(timeout: timeout), "Element should exist within \(timeout) seconds", file: file, line: line)
    }
    
    /// Waits for element to disappear
    func waitForElementToDisappear(_ element: XCUIElement, timeout: TimeInterval = 5.0, file: StaticString = #file, line: UInt = #line) {
        let expectation = XCTestExpectation(description: "Element should disappear")
        
        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak element] timer in
            if element?.exists == false {
                expectation.fulfill()
                timer.invalidate()
            }
        }
        
        let result = XCTWaiter.wait(for: [expectation], timeout: timeout)
        timer.invalidate()
        
        XCTAssertEqual(result, .completed, "Element should disappear within \(timeout) seconds", file: file, line: line)
    }
    
    // MARK: - Screenshot Helpers
    
    /// Takes screenshot with description
    func takeScreenshot(_ description: String) {
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = description
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    /// Takes screenshot on failure
    func takeScreenshotOnFailure(_ description: String = "Test Failure") {
        if let testRun = testRun, testRun.hasSucceeded == false {
            takeScreenshot(description)
        }
    }
    
    // MARK: - Performance Helpers
    
    /// Measures UI interaction performance (simplified version)
    func measureUIPerformance(_ description: String, block: () -> Void) {
        let startTime = CFAbsoluteTimeGetCurrent()
        block()
        let endTime = CFAbsoluteTimeGetCurrent()
        let totalTime = endTime - startTime
        
        print("\(description): \(String(format: "%.3f", totalTime)) seconds")
        
        // Assert reasonable performance (adjust timeout as needed)
        XCTAssertLessThan(totalTime, 30.0, "\(description) should complete within 30 seconds")
    }
    
    // MARK: - Accessibility Helpers
    
    /// Tests VoiceOver accessibility (call this from actual test methods)
    func verifyVoiceOverAccessibility() {
        // Test that main elements have accessibility labels
        let homeTab = app.tabBars.buttons["ホーム"]
        let shredderTab = app.tabBars.buttons["シュレッダー"]
        
        XCTAssertNotNil(homeTab.label, "Home tab should have accessibility label")
        XCTAssertNotNil(shredderTab.label, "Shredder tab should have accessibility label")
    }
    
    // MARK: - Error Recovery
    
    /// Recovers from modal state
    func dismissAnyModal() {
        // Try to dismiss any open modals
        let cancelButtons = app.buttons.matching(identifier: "キャンセル")
        for i in 0..<cancelButtons.count {
            let button = cancelButtons.element(boundBy: i)
            if button.exists && button.isHittable {
                button.tap()
                break
            }
        }
    }
    
    /// Resets app to home state
    func resetToHomeState() {
        dismissAnyModal()
        navigateToHome()
    }
}

// MARK: - UI Test Utilities

struct UITestUtilities {
    
    /// Generates test text of specified length
    static func generateTestText(length: Int) -> String {
        let characters = "あいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめもやゆよらりるれろわをん"
        return String((0..<length).map { _ in characters.randomElement()! })
    }
    
    /// Creates long text for testing text input limits
    static func longTestText() -> String {
        return String(repeating: "これは長いテストテキストです。", count: 100)
    }
    
    /// Creates text with special characters
    static func specialCharacterTestText() -> String {
        return "🌙✨💭\n改行テスト\tタブテスト\"引用符テスト\"'アポストロフィテスト'"
    }
}

// MARK: - Custom XCTest Expectations

extension XCTestCase {
    
    /// Creates expectation for UI element to appear
    func expectationForElementToAppear(_ element: XCUIElement, timeout: TimeInterval = 5.0) -> XCTestExpectation {
        let expectation = XCTestExpectation(description: "Element should appear")
        
        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak element] timer in
            if element?.exists == true {
                expectation.fulfill()
                timer.invalidate()
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + timeout) {
            timer.invalidate()
        }
        
        return expectation
    }
    
    /// Creates expectation for UI element to disappear
    func expectationForElementToDisappear(_ element: XCUIElement, timeout: TimeInterval = 5.0) -> XCTestExpectation {
        let expectation = XCTestExpectation(description: "Element should disappear")
        
        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak element] timer in
            if element?.exists == false {
                expectation.fulfill()
                timer.invalidate()
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + timeout) {
            timer.invalidate()
        }
        
        return expectation
    }
}
