//
//  TestData.swift
//  yorunoteTests
//
//  テストスイート作成
//

import Foundation
import SwiftData
@testable import yorunote

/// yorunoteテスト用のテストデータフィクスチャ
struct TestData {
    
    // MARK: - サンプルNightEntryデータ
    
    static func sampleEntry() -> NightEntry {
        return NightEntry(
            eventText: "今日は素晴らしい一日だった",
            feelingText: "とても充実感があった",
            futureText: "明日も良い日になりそう"
        )
    }
    
    static func sampleEntryWithDate(_ date: Date) -> NightEntry {
        return NightEntry(
            date: date,
            eventText: "サンプルイベント",
            feelingText: "サンプル感情",
            futureText: "サンプル未来"
        )
    }
    
    static func emptyEntry() -> NightEntry {
        return NightEntry(
            eventText: "",
            feelingText: "",
            futureText: ""
        )
    }
    
    static func longTextEntry() -> NightEntry {
        let longText = String(repeating: "長いテキストのサンプル。", count: 100)
        return NightEntry(
            eventText: longText,
            feelingText: longText,
            futureText: longText
        )
    }
    
    static func specialCharacterEntry() -> NightEntry {
        let specialText = "🌙✨💭\n改行\tタブ\"引用符\"'アポストロフィ'<>記号&amp;エンティティ"
        return NightEntry(
            eventText: specialText,
            feelingText: specialText,
            futureText: specialText
        )
    }
    
    // MARK: - Multiple Entries
    
    static func weekOfEntries() -> [NightEntry] {
        let calendar = Calendar.current
        let baseDate = Date()
        var entries: [NightEntry] = []
        
        for i in 0..<7 {
            let date = calendar.date(byAdding: .day, value: -i, to: baseDate) ?? baseDate
            let entry = NightEntry(
                date: date,
                eventText: "Day \(i) event",
                feelingText: "Day \(i) feeling",
                futureText: "Day \(i) future"
            )
            entries.append(entry)
        }
        
        return entries
    }
    
    static func monthOfEntries() -> [NightEntry] {
        let calendar = Calendar.current
        let baseDate = Date()
        var entries: [NightEntry] = []
        
        for i in 0..<30 {
            let date = calendar.date(byAdding: .day, value: -i, to: baseDate) ?? baseDate
            let entry = NightEntry(
                date: date,
                eventText: "Month entry \(i)",
                feelingText: "Month feeling \(i)",
                futureText: "Month future \(i)"
            )
            entries.append(entry)
        }
        
        return entries
    }
    
    static func yearOfEntries() -> [NightEntry] {
        let calendar = Calendar.current
        let baseDate = Date()
        var entries: [NightEntry] = []
        
        for i in 0..<365 {
            let date = calendar.date(byAdding: .day, value: -i, to: baseDate) ?? baseDate
            let entry = NightEntry(
                date: date,
                eventText: "Year entry \(i)",
                feelingText: "Year feeling \(i)",
                futureText: "Year future \(i)"
            )
            entries.append(entry)
        }
        
        return entries
    }
    
    // MARK: - Specific Date Entries
    
    static func todayEntry() -> NightEntry {
        return NightEntry(
            date: Date(),
            eventText: "今日のエントリ",
            feelingText: "今日の感情",
            futureText: "今日の未来"
        )
    }
    
    static func yesterdayEntry() -> NightEntry {
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        return NightEntry(
            date: yesterday,
            eventText: "昨日のエントリ",
            feelingText: "昨日の感情",
            futureText: "昨日の未来"
        )
    }
    
    static func tomorrowEntry() -> NightEntry {
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        return NightEntry(
            date: tomorrow,
            eventText: "明日のエントリ",
            feelingText: "明日の感情",
            futureText: "明日の未来"
        )
    }
    
    // MARK: - Edge Case Entries
    
    static func whitespaceOnlyEntry() -> NightEntry {
        return NightEntry(
            eventText: "   ",
            feelingText: "\n\n\n",
            futureText: "\t\t\t"
        )
    }
    
    static func singleCharacterEntry() -> NightEntry {
        return NightEntry(
            eventText: "あ",
            feelingText: "い",
            futureText: "う"
        )
    }
    
    static func numbersOnlyEntry() -> NightEntry {
        return NightEntry(
            eventText: "12345",
            feelingText: "67890",
            futureText: "00000"
        )
    }
    
    // MARK: - Date Utilities
    
    static func dateFromString(_ dateString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateString) ?? Date()
    }
    
    static func entriesForDateRange(from startDate: Date, to endDate: Date) -> [NightEntry] {
        let calendar = Calendar.current
        var entries: [NightEntry] = []
        var currentDate = startDate
        var dayIndex = 0
        
        while currentDate <= endDate {
            let entry = NightEntry(
                date: currentDate,
                eventText: "Range entry \(dayIndex)",
                feelingText: "Range feeling \(dayIndex)",
                futureText: "Range future \(dayIndex)"
            )
            entries.append(entry)
            
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? endDate
            dayIndex += 1
        }
        
        return entries
    }
    
    // MARK: - Performance Test Data
    
    static func largeDataSet(count: Int = 1000) -> [NightEntry] {
        let calendar = Calendar.current
        let baseDate = Date()
        var entries: [NightEntry] = []
        
        for i in 0..<count {
            let date = calendar.date(byAdding: .day, value: -i, to: baseDate) ?? baseDate
            // ゼロパディングで文字列ソートでも正しい順序になるように
            let paddedIndex = String(format: "%04d", i)
            let entry = NightEntry(
                date: date,
                eventText: "Large dataset entry \(paddedIndex) - " + String(repeating: "text ", count: 10),
                feelingText: "Large dataset feeling \(paddedIndex) - " + String(repeating: "emotion ", count: 10),
                futureText: "Large dataset future \(paddedIndex) - " + String(repeating: "tomorrow ", count: 10)
            )
            entries.append(entry)
        }
        
        return entries
    }
    
    // MARK: - Validation Helpers
    
    static func isValidEntry(_ entry: NightEntry) -> Bool {
        return !entry.id.uuidString.isEmpty &&
               entry.date <= Date() &&
               entry.eventText.count >= 0 &&
               entry.feelingText.count >= 0 &&
               entry.futureText.count >= 0
    }
    
    static func hasContent(_ entry: NightEntry) -> Bool {
        return !entry.eventText.isEmpty ||
               !entry.feelingText.isEmpty ||
               !entry.futureText.isEmpty
    }
    
    static func isEmptyEntry(_ entry: NightEntry) -> Bool {
        return entry.eventText.isEmpty &&
               entry.feelingText.isEmpty &&
               entry.futureText.isEmpty
    }
}

// MARK: - Test Model Container Helper

extension TestData {
    
    /// Creates an in-memory model container for testing
    static func createTestContainer() throws -> ModelContainer {
        let schema = Schema([NightEntry.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [modelConfiguration])
    }
    
    /// Creates a test context with sample data
    static func createTestContextWithSampleData() throws -> ModelContext {
        let container = try createTestContainer()
        let context = ModelContext(container)
        
        // Add sample data
        let entries = weekOfEntries()
        for entry in entries {
            context.insert(entry)
        }
        
        try context.save()
        return context
    }
    
    /// Creates a test context with large dataset
    static func createTestContextWithLargeData(count: Int = 100) throws -> ModelContext {
        let container = try createTestContainer()
        let context = ModelContext(container)
        
        let entries = largeDataSet(count: count)
        for entry in entries {
            context.insert(entry)
        }
        
        try context.save()
        return context
    }
}