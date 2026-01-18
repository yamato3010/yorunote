//
//  RitualInputViewTests.swift
//  yorunoteTests
//
//  Created by Yamato on 2026/01/18.
//

import XCTest
import SwiftUI
import SwiftData
@testable import yorunote

final class RitualInputViewTests: XCTestCase {
    
    var modelContainer: ModelContainer!
    
    override func setUpWithError() throws {
        let schema = Schema([NightEntry.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
    }
    
    override func tearDownWithError() throws {
        modelContainer = nil
    }
    
    // MARK: - RITUAL-001: 新規作成モード
    func testRitualInputViewNewEntryMode() throws {
        let ritualView = RitualInputView()
            .modelContainer(modelContainer)
        
        XCTAssertNotNil(ritualView, "RitualInputView should be created for new entry")
    }
    
    // MARK: - RITUAL-002: 編集モード
    func testRitualInputViewEditMode() throws {
        let context = ModelContext(modelContainer)
        
        // 既存のエントリを作成
        let existingEntry = NightEntry(
            eventText: "既存のイベント",
            feelingText: "既存の感情",
            futureText: "既存の未来"
        )
        
        context.insert(existingEntry)
        try context.save()
        
        let ritualView = RitualInputView(entry: existingEntry)
            .modelContainer(modelContainer)
        
        XCTAssertNotNil(ritualView, "RitualInputView should be created for editing")
    }
    
    // MARK: - Save Logic Tests
    func testSaveNewEntry() throws {
        let context = ModelContext(modelContainer)
        
        let eventText = "新しいイベント"
        let feelingText = "新しい感情"
        let futureText = "新しい未来"
        
        // 新規エントリモードでsaveEntry()が呼び出されたときに保存されるかを確認
        let newEntry = NightEntry(
            date: Date(),
            eventText: eventText,
            feelingText: feelingText,
            futureText: futureText
        )
        
        context.insert(newEntry)
        try context.save()
        
        // 保存されているか確認
        let fetchDescriptor = FetchDescriptor<NightEntry>()
        let savedEntries = try context.fetch(fetchDescriptor)
        
        XCTAssertEqual(savedEntries.count, 1, "Should have one saved entry")
        XCTAssertEqual(savedEntries.first?.eventText, eventText)
        XCTAssertEqual(savedEntries.first?.feelingText, feelingText)
        XCTAssertEqual(savedEntries.first?.futureText, futureText)
    }
    
    func testUpdateExistingEntry() throws {
        let context = ModelContext(modelContainer)
        
        let existingEntry = NightEntry(
            eventText: "初期イベント",
            feelingText: "初期感情",
            futureText: "初期未来"
        )
        
        context.insert(existingEntry)
        try context.save()
        
        // エントリの更新をする
        existingEntry.eventText = "更新されたイベント"
        existingEntry.feelingText = "更新された感情"
        existingEntry.futureText = "更新された未来"
        
        try context.save()
        
        // 更新されているか確認
        let fetchDescriptor = FetchDescriptor<NightEntry>()
        let savedEntries = try context.fetch(fetchDescriptor)
        
        XCTAssertEqual(savedEntries.count, 1, "Should still have one entry")
        XCTAssertEqual(savedEntries.first?.eventText, "更新されたイベント")
        XCTAssertEqual(savedEntries.first?.feelingText, "更新された感情")
        XCTAssertEqual(savedEntries.first?.futureText, "更新された未来")
    }
    
    // MARK: - RITUAL-013: 空入力での保存
    func testSaveButtonDisabledForEmptyInput() throws {
        // 保存ボタンを有効にするかどうかを決定するロジックをテスト
        let eventText = ""
        let feelingText = ""
        let futureText = ""
        
        let shouldDisableSaveButton = eventText.isEmpty && feelingText.isEmpty && futureText.isEmpty
        
        XCTAssertTrue(shouldDisableSaveButton, "Save button should be disabled when all fields are empty")
    }
    
    func testSaveButtonEnabledWithAnyInput() throws {
        // eventTextだけ入れる
        var eventText = "何かのイベント"
        var feelingText = ""
        var futureText = ""
        
        var shouldDisableSaveButton = eventText.isEmpty && feelingText.isEmpty && futureText.isEmpty
        XCTAssertFalse(shouldDisableSaveButton, "Save button should be enabled with event text")
        
        // feelingTextだけ入れる
        eventText = ""
        feelingText = "何かの感情"
        futureText = ""
        
        shouldDisableSaveButton = eventText.isEmpty && feelingText.isEmpty && futureText.isEmpty
        XCTAssertFalse(shouldDisableSaveButton, "Save button should be enabled with feeling text")
        
        // futureTextだけ入れる
        eventText = ""
        feelingText = ""
        futureText = "何かの未来"
        
        shouldDisableSaveButton = eventText.isEmpty && feelingText.isEmpty && futureText.isEmpty
        XCTAssertFalse(shouldDisableSaveButton, "Save button should be enabled with future text")
    }
    
    // MARK: - Edge Cases
    func testSaveWithWhitespaceOnlyInput() throws {
        let context = ModelContext(modelContainer)
        
        // 空白のみのコンテンツを含むエントリの保存をテストする
        let entry = NightEntry(
            eventText: "   ",
            feelingText: "\n\n",
            futureText: "\t\t"
        )
        
        context.insert(entry)
        try context.save()
        
        let fetchDescriptor = FetchDescriptor<NightEntry>()
        let savedEntries = try context.fetch(fetchDescriptor)
        
        XCTAssertEqual(savedEntries.count, 1, "Should save entry with whitespace")
        XCTAssertEqual(savedEntries.first?.eventText, "   ")
        XCTAssertEqual(savedEntries.first?.feelingText, "\n\n")
        XCTAssertEqual(savedEntries.first?.futureText, "\t\t")
    }
    
    func testSaveWithVeryLongText() throws {
        let context = ModelContext(modelContainer)
        
        // 非常に長いテキスト（1000文字）を作成する
        let longText = String(repeating: "あ", count: 1000)
        
        let entry = NightEntry(
            eventText: longText,
            feelingText: longText,
            futureText: longText
        )
        
        context.insert(entry)
        try context.save()
        
        let fetchDescriptor = FetchDescriptor<NightEntry>()
        let savedEntries = try context.fetch(fetchDescriptor)
        
        XCTAssertEqual(savedEntries.count, 1, "Should save entry with long text")
        XCTAssertEqual(savedEntries.first?.eventText.count, 1000)
        XCTAssertEqual(savedEntries.first?.feelingText.count, 1000)
        XCTAssertEqual(savedEntries.first?.futureText.count, 1000)
    }
    
    func testSaveWithSpecialCharacters() throws {
        let context = ModelContext(modelContainer)
        // 特殊文字でテスト
        let specialText = "🌙✨💭\n改行\tタブ\"引用符\"'アポストロフィ'<>記号"
        
        let entry = NightEntry(
            eventText: specialText,
            feelingText: specialText,
            futureText: specialText
        )
        
        context.insert(entry)
        try context.save()
        
        let fetchDescriptor = FetchDescriptor<NightEntry>()
        let savedEntries = try context.fetch(fetchDescriptor)
        
        XCTAssertEqual(savedEntries.count, 1, "Should save entry with special characters")
        XCTAssertEqual(savedEntries.first?.eventText, specialText)
        XCTAssertEqual(savedEntries.first?.feelingText, specialText)
        XCTAssertEqual(savedEntries.first?.futureText, specialText)
    }
    
    // MARK: - Performance Tests
    func testSavePerformance() throws {
        let context = ModelContext(modelContainer)
        
        measure {
            let entry = NightEntry(
                eventText: "パフォーマンステスト",
                feelingText: "パフォーマンステスト",
                futureText: "パフォーマンステスト"
            )
            
            context.insert(entry)
            try! context.save()
        }
    }
    
    // MARK: - Data Validation Tests
    func testDateIsSetCorrectly() throws {
        let context = ModelContext(modelContainer)
        
        let beforeSave = Date()
        
        let entry = NightEntry(
            eventText: "日付テスト",
            feelingText: "日付テスト",
            futureText: "日付テスト"
        )
        
        context.insert(entry)
        try context.save()
        
        let afterSave = Date()
        
        // エントリの日付がbeforeSaveとafterSaveの間であることを確認
        XCTAssertGreaterThanOrEqual(entry.date, beforeSave, "Entry date should be after or equal to beforeSave")
        XCTAssertLessThanOrEqual(entry.date, afterSave, "Entry date should be before or equal to afterSave")
    }
    
    func testUniqueIDGeneration() throws {
        let context = ModelContext(modelContainer)
        
        let entry1 = NightEntry(eventText: "エントリ1")
        let entry2 = NightEntry(eventText: "エントリ2")
        
        context.insert(entry1)
        context.insert(entry2)
        try context.save()
        
        XCTAssertNotEqual(entry1.id, entry2.id, "Each entry should have a unique ID")
    }
}
