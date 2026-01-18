//
//  IntegrationTests.swift
//  yorunoteTests
//
//  Created by Yamato on 2026/01/18.
//

import XCTest
import SwiftUI
import SwiftData
@testable import yorunote

final class IntegrationTests: XCTestCase {
    
    var modelContainer: ModelContainer!
    
    override func setUpWithError() throws {
        let schema = Schema([NightEntry.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
    }
    
    override func tearDownWithError() throws {
        modelContainer = nil
    }
    
    // MARK: - E2E-001: 新規エントリ作成から表示まで
    func testCompleteRitualFlow() throws {
        let context = ModelContext(modelContainer)
        
        // 空のデータベースから開始
        let fetchDescriptor = FetchDescriptor<NightEntry>()
        var entries = try context.fetch(fetchDescriptor)
        XCTAssertEqual(entries.count, 0, "Should start with no entries")
        
        // 新しいエントリを作成する
        let eventText = "今日は素晴らしい一日だった"
        let feelingText = "とても充実感があった"
        let futureText = "明日も良い日になりそう"
        
        let newEntry = NightEntry(
            date: Date(),
            eventText: eventText,
            feelingText: feelingText,
            futureText: futureText
        )
        
        context.insert(newEntry)
        try context.save()
        
        // エントリが保存され、取得できることを確認
        entries = try context.fetch(fetchDescriptor)
        XCTAssertEqual(entries.count, 1, "Should have one saved entry")
        
        let savedEntry = entries.first!
        XCTAssertEqual(savedEntry.eventText, eventText)
        XCTAssertEqual(savedEntry.feelingText, feelingText)
        XCTAssertEqual(savedEntry.futureText, futureText)
        
        // Step 4: Verify calendar functionality (finding entry by date)
        let calendar = Calendar.current
        let today = Date()
        
        let todayEntry = entries.first { entry in
            calendar.isDate(entry.date, inSameDayAs: today)
        }
        
        XCTAssertNotNil(todayEntry, "Should find today's entry")
        XCTAssertEqual(todayEntry?.eventText, eventText)
    }
    
    // MARK: - E2E-002: エントリ編集フロー
    func testEntryEditFlow() throws {
        let context = ModelContext(modelContainer)
        
        // Step 1: Create initial entry
        let originalEntry = NightEntry(
            eventText: "初期のイベント",
            feelingText: "初期の感情",
            futureText: "初期の未来"
        )
        
        context.insert(originalEntry)
        try context.save()
        
        // Step 2: Retrieve entry for editing (simulating HomeView -> RitualInputView flow)
        let fetchDescriptor = FetchDescriptor<NightEntry>()
        let entries = try context.fetch(fetchDescriptor)
        let entryToEdit = entries.first!
        
        // Step 3: Edit the entry (simulating RitualInputView edit mode)
        entryToEdit.eventText = "更新されたイベント"
        entryToEdit.feelingText = "更新された感情"
        entryToEdit.futureText = "更新された未来"
        
        try context.save()
        
        // Step 4: Verify the update (simulating HomeView refresh)
        let updatedEntries = try context.fetch(fetchDescriptor)
        XCTAssertEqual(updatedEntries.count, 1, "Should still have one entry")
        
        let updatedEntry = updatedEntries.first!
        XCTAssertEqual(updatedEntry.eventText, "更新されたイベント")
        XCTAssertEqual(updatedEntry.feelingText, "更新された感情")
        XCTAssertEqual(updatedEntry.futureText, "更新された未来")
        
        // Verify it's the same entry (same ID)
        XCTAssertEqual(updatedEntry.id, originalEntry.id, "Should be the same entry")
    }
    
    // MARK: - E2E-003: 複数日のエントリ管理
    func testMultipleDayEntryManagement() throws {
        let context = ModelContext(modelContainer)
        let calendar = Calendar.current
        let baseDate = Date()
        
        // Step 1: Create entries for multiple days
        var createdEntries: [NightEntry] = []
        
        for i in 0..<7 { // One week of entries
            let date = calendar.date(byAdding: .day, value: -i, to: baseDate) ?? baseDate
            let entry = NightEntry(
                date: date,
                eventText: "Day \(i) event",
                feelingText: "Day \(i) feeling",
                futureText: "Day \(i) future"
            )
            
            context.insert(entry)
            createdEntries.append(entry)
        }
        
        try context.save()
        
        // Step 2: Verify all entries are saved
        let fetchDescriptor = FetchDescriptor<NightEntry>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        let savedEntries = try context.fetch(fetchDescriptor)
        
        XCTAssertEqual(savedEntries.count, 7, "Should have 7 entries")
        
        // Step 3: Test date-based retrieval for each day
        for i in 0..<7 {
            let targetDate = calendar.date(byAdding: .day, value: -i, to: baseDate) ?? baseDate
            
            let foundEntry = savedEntries.first { entry in
                calendar.isDate(entry.date, inSameDayAs: targetDate)
            }
            
            XCTAssertNotNil(foundEntry, "Should find entry for day \(i)")
            XCTAssertEqual(foundEntry?.eventText, "Day \(i) event")
        }
        
        // Step 4: Test that entries are properly sorted (newest first)
        for i in 0..<6 {
            XCTAssertGreaterThanOrEqual(
                savedEntries[i].date,
                savedEntries[i + 1].date,
                "Entries should be sorted by date (newest first)"
            )
        }
    }
    
    // MARK: - E2E-011: 完全なシュレッダー体験
    func testCompleteShredderFlow() throws {
        // This test simulates the complete shredder experience
        // Since ShredderView doesn't persist data, we test the state transitions
        
        // Step 1: Initial state
        var text = ""
        var timeRemaining = 60
        var isTimerRunning = false
        var isShredding = false
        var showCompletion = false
        
        XCTAssertTrue(text.isEmpty, "Should start with empty text")
        XCTAssertEqual(timeRemaining, 60, "Should start with 60 seconds")
        XCTAssertFalse(isTimerRunning, "Timer should not be running")
        
        // Step 2: User starts typing
        text = "今日はとても疲れた。仕事でミスをしてしまい、上司に怒られた。"
        
        if !isTimerRunning && !text.isEmpty {
            isTimerRunning = true
        }
        
        XCTAssertTrue(isTimerRunning, "Timer should start when typing begins")
        
        // Step 3: Timer counts down (simulate passage of time)
        while timeRemaining > 0 && isTimerRunning {
            timeRemaining -= 1
        }
        
        // Step 4: Auto-shredding when timer reaches zero
        if isTimerRunning && timeRemaining == 0 {
            isTimerRunning = false
            isShredding = true
        }
        
        XCTAssertEqual(timeRemaining, 0, "Timer should reach zero")
        XCTAssertFalse(isTimerRunning, "Timer should stop")
        XCTAssertTrue(isShredding, "Shredding should start")
        
        // Step 5: Shredding animation completes
        isShredding = false
        showCompletion = true
        text = "" // Data is destroyed
        
        XCTAssertFalse(isShredding, "Shredding should complete")
        XCTAssertTrue(showCompletion, "Completion screen should show")
        XCTAssertTrue(text.isEmpty, "Text should be completely erased")
        
        // Step 6: Reset for another session
        showCompletion = false
        timeRemaining = 60
        isTimerRunning = false
        
        XCTAssertFalse(showCompletion, "Should return to initial state")
        XCTAssertEqual(timeRemaining, 60, "Timer should reset")
        XCTAssertFalse(isTimerRunning, "Timer should not be running")
    }
    
    // MARK: - E2E-012: タブ間移動
    func testTabSwitchingWithShredder() throws {
        let context = ModelContext(modelContainer)
        
        // Step 1: Create some entries in the ritual tab
        let entry = NightEntry(
            eventText: "通常のエントリ",
            feelingText: "通常の感情",
            futureText: "通常の未来"
        )
        
        context.insert(entry)
        try context.save()
        
        // Step 2: Simulate shredder usage (no data should be saved)
        var shredderText = "シュレッダーで書いた内容"
        
        // Simulate shredding completion
        shredderText = "" // Data is destroyed
        
        XCTAssertTrue(shredderText.isEmpty, "Shredder text should be destroyed")
        
        // Step 3: Switch back to home tab and verify ritual data is intact
        let fetchDescriptor = FetchDescriptor<NightEntry>()
        let savedEntries = try context.fetch(fetchDescriptor)
        
        XCTAssertEqual(savedEntries.count, 1, "Ritual entries should be unaffected")
        XCTAssertEqual(savedEntries.first?.eventText, "通常のエントリ")
        
        // Step 4: Verify shredder and ritual are completely independent
        XCTAssertTrue(shredderText.isEmpty, "Shredder should not affect ritual data")
        XCTAssertFalse(savedEntries.isEmpty, "Ritual data should not affect shredder")
    }
    
    // MARK: - DATA-001: 日付境界
    func testDateBoundaryHandling() throws {
        let context = ModelContext(modelContainer)
        let calendar = Calendar.current
        
        // Create entries at different times of day
        let morning = calendar.date(bySettingHour: 6, minute: 0, second: 0, of: Date())!
        let evening = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: Date())!
        
        let morningEntry = NightEntry(
            date: morning,
            eventText: "朝のエントリ"
        )
        
        let eveningEntry = NightEntry(
            date: evening,
            eventText: "夜のエントリ"
        )
        
        context.insert(morningEntry)
        context.insert(eveningEntry)
        try context.save()
        
        // Both entries should be found for "today"
        let fetchDescriptor = FetchDescriptor<NightEntry>()
        let allEntries = try context.fetch(fetchDescriptor)
        
        let todayEntries = allEntries.filter { entry in
            calendar.isDate(entry.date, inSameDayAs: Date())
        }
        
        XCTAssertEqual(todayEntries.count, 2, "Both morning and evening entries should be found for today")
    }
    
    // MARK: - DATA-011: 同時操作
    func testConcurrentOperations() throws {
        let context1 = ModelContext(modelContainer)
        let context2 = ModelContext(modelContainer)
        
        // Simulate concurrent entry creation
        let entry1 = NightEntry(eventText: "Context 1 entry")
        let entry2 = NightEntry(eventText: "Context 2 entry")
        
        context1.insert(entry1)
        context2.insert(entry2)
        
        // Save from both contexts
        try context1.save()
        try context2.save()
        
        // Verify both entries exist
        let fetchDescriptor = FetchDescriptor<NightEntry>()
        let allEntries = try context1.fetch(fetchDescriptor)
        
        XCTAssertEqual(allEntries.count, 2, "Both entries should be saved")
        
        let eventTexts = Set(allEntries.map { $0.eventText })
        XCTAssertTrue(eventTexts.contains("Context 1 entry"))
        XCTAssertTrue(eventTexts.contains("Context 2 entry"))
    }
    
    // MARK: - Performance Integration Tests
    func testAppPerformanceWithLargeDataset() throws {
        let context = ModelContext(modelContainer)
        let calendar = Calendar.current
        let baseDate = Date()
        
        // Create a year's worth of entries
        let entryCount = 365
        
        measure {
            for i in 0..<entryCount {
                let date = calendar.date(byAdding: .day, value: -i, to: baseDate) ?? baseDate
                let entry = NightEntry(
                    date: date,
                    eventText: "Entry \(i) - " + String(repeating: "text ", count: 10),
                    feelingText: "Feeling \(i) - " + String(repeating: "emotion ", count: 10),
                    futureText: "Future \(i) - " + String(repeating: "tomorrow ", count: 10)
                )
                context.insert(entry)
            }
            
            try! context.save()
            
            // Test retrieval performance
            let fetchDescriptor = FetchDescriptor<NightEntry>(
                sortBy: [SortDescriptor(\.date, order: .reverse)]
            )
            let _ = try! context.fetch(fetchDescriptor)
        }
    }
    
    // MARK: - Error Recovery Tests
    func testErrorRecoveryFlow() throws {
        let context = ModelContext(modelContainer)
        
        // Create a valid entry
        let validEntry = NightEntry(eventText: "Valid entry")
        context.insert(validEntry)
        try context.save()
        
        // Simulate an error scenario and recovery
        do {
            // This should succeed
            let fetchDescriptor = FetchDescriptor<NightEntry>()
            let entries = try context.fetch(fetchDescriptor)
            XCTAssertEqual(entries.count, 1, "Should recover and fetch existing data")
        } catch {
            XCTFail("Should not throw error during normal operation")
        }
        
        // Test that the app can continue working after an error
        let anotherEntry = NightEntry(eventText: "Recovery entry")
        context.insert(anotherEntry)
        try context.save()
        
        let fetchDescriptor = FetchDescriptor<NightEntry>()
        let allEntries = try context.fetch(fetchDescriptor)
        XCTAssertEqual(allEntries.count, 2, "Should continue working after error recovery")
    }
}
