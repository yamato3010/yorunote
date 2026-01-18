//
//  NightEntryModelTests.swift
//  yorunoteTests
//
//  Created by Yamato on 2026/01/18.
//

import XCTest
import SwiftData
@testable import yorunote

final class NightEntryModelTests: XCTestCase {
    
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    
    override func setUpWithError() throws {
        // テスト用のインメモリデータベース
        let schema = Schema([NightEntry.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        modelContext = ModelContext(modelContainer)
    }
    
    override func tearDownWithError() throws {
        modelContainer = nil
        modelContext = nil
    }
    
    // MARK: - MODEL-001: デフォルト値での初期化
    func testNightEntryDefaultInitialization() throws {
        let entry = NightEntry()
        
        XCTAssertNotNil(entry.id, "IDが生成されている必要があります")
        XCTAssertNotNil(entry.date, "日付が設定されている必要があります")
        XCTAssertEqual(entry.eventText, "", "イベントテキストは空文字列である必要があります")
        XCTAssertEqual(entry.feelingText, "", "感情テキストは空文字列である必要があります")
        XCTAssertEqual(entry.futureText, "", "未来テキストは空文字列である必要があります")
        
        // 日付が現在時刻に近いことを確認（1秒以内）
        let now = Date()
        XCTAssertLessThan(abs(entry.date.timeIntervalSince(now)), 1.0, "日付は現在時刻に近い必要があります")
    }
    
    // MARK: - MODEL-002: 全パラメータ指定での初期化
    func testNightEntryParameterizedInitialization() throws {
        let testDate = Date(timeIntervalSince1970: 1640995200) // 2022-01-01 00:00:00 UTC
        let eventText = "テストイベント"
        let feelingText = "テスト感情"
        let futureText = "テスト未来"
        
        let entry = NightEntry(
            date: testDate,
            eventText: eventText,
            feelingText: feelingText,
            futureText: futureText
        )
        
        XCTAssertNotNil(entry.id, "IDが生成されている必要があります")
        XCTAssertEqual(entry.date, testDate, "日付は指定した値と一致する必要があります")
        XCTAssertEqual(entry.eventText, eventText, "イベントテキストは指定した値と一致する必要があります")
        XCTAssertEqual(entry.feelingText, feelingText, "感情テキストは指定した値と一致する必要があります")
        XCTAssertEqual(entry.futureText, futureText, "未来テキストは指定した値と一致する必要があります")
    }
    
    // MARK: - MODEL-003: 空文字列での初期化
    func testNightEntryEmptyStringInitialization() throws {
        let entry = NightEntry(
            eventText: "",
            feelingText: "",
            futureText: ""
        )
        
        XCTAssertEqual(entry.eventText, "", "空のイベントテキストが保持される必要があります")
        XCTAssertEqual(entry.feelingText, "", "空の感情テキストが保持される必要があります")
        XCTAssertEqual(entry.futureText, "", "空の未来テキストが保持される必要があります")
    }
    
    // MARK: - MODEL-011: 新規エントリ保存
    func testSaveNewEntry() throws {
        let entry = NightEntry(
            eventText: "今日は良い日だった",
            feelingText: "とても嬉しい",
            futureText: "明日も頑張ろう"
        )
        
        modelContext.insert(entry)
        try modelContext.save()
        
        // エントリが保存されたことを確認
        let fetchDescriptor = FetchDescriptor<NightEntry>()
        let savedEntries = try modelContext.fetch(fetchDescriptor)
        
        XCTAssertEqual(savedEntries.count, 1, "保存されたエントリが1つある必要があります")
        XCTAssertEqual(savedEntries.first?.eventText, "今日は良い日だった")
        XCTAssertEqual(savedEntries.first?.feelingText, "とても嬉しい")
        XCTAssertEqual(savedEntries.first?.futureText, "明日も頑張ろう")
    }
    
    // MARK: - MODEL-012: 既存エントリ更新
    func testUpdateExistingEntry() throws {
        // 初期エントリを作成して保存
        let entry = NightEntry(eventText: "初期テキスト")
        modelContext.insert(entry)
        try modelContext.save()
        
        // エントリを更新
        entry.eventText = "更新されたテキスト"
        entry.feelingText = "新しい感情"
        try modelContext.save()
        
        // 更新を確認
        let fetchDescriptor = FetchDescriptor<NightEntry>()
        let savedEntries = try modelContext.fetch(fetchDescriptor)
        
        XCTAssertEqual(savedEntries.count, 1, "エントリは1つのままである必要があります")
        XCTAssertEqual(savedEntries.first?.eventText, "更新されたテキスト")
        XCTAssertEqual(savedEntries.first?.feelingText, "新しい感情")
    }
    
    // MARK: - MODEL-013: 複数エントリ保存
    func testSaveMultipleEntries() throws {
        let entry1 = NightEntry(eventText: "エントリ1")
        let entry2 = NightEntry(eventText: "エントリ2")
        let entry3 = NightEntry(eventText: "エントリ3")
        
        modelContext.insert(entry1)
        modelContext.insert(entry2)
        modelContext.insert(entry3)
        try modelContext.save()
        
        let fetchDescriptor = FetchDescriptor<NightEntry>()
        let savedEntries = try modelContext.fetch(fetchDescriptor)
        
        XCTAssertEqual(savedEntries.count, 3, "Should have three saved entries")
        
        let eventTexts = savedEntries.map { $0.eventText }.sorted()
        XCTAssertEqual(eventTexts, ["エントリ1", "エントリ2", "エントリ3"])
    }
    
    // MARK: - MODEL-021: 日付順ソート取得
    func testFetchEntriesSortedByDate() throws {
        let date1 = Date(timeIntervalSince1970: 1640995200) // 2022-01-01
        let date2 = Date(timeIntervalSince1970: 1641081600) // 2022-01-02
        let date3 = Date(timeIntervalSince1970: 1641168000) // 2022-01-03
        
        let entry1 = NightEntry(date: date1, eventText: "最古のエントリ")
        let entry2 = NightEntry(date: date3, eventText: "最新のエントリ")
        let entry3 = NightEntry(date: date2, eventText: "中間のエントリ")
        
        modelContext.insert(entry1)
        modelContext.insert(entry2)
        modelContext.insert(entry3)
        try modelContext.save()
        
        // 日付の降順で並べ替え
        let fetchDescriptor = FetchDescriptor<NightEntry>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        let sortedEntries = try modelContext.fetch(fetchDescriptor)
        
        XCTAssertEqual(sortedEntries.count, 3)
        XCTAssertEqual(sortedEntries[0].eventText, "最新のエントリ")
        XCTAssertEqual(sortedEntries[1].eventText, "中間のエントリ")
        XCTAssertEqual(sortedEntries[2].eventText, "最古のエントリ")
    }
    
    // MARK: - MODEL-022: 特定日付のエントリ検索
    func testFindEntryForSpecificDate() throws {
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        
        let todayEntry = NightEntry(date: today, eventText: "今日のエントリ")
        let yesterdayEntry = NightEntry(date: yesterday, eventText: "昨日のエントリ")
        let tomorrowEntry = NightEntry(date: tomorrow, eventText: "明日のエントリ")
        
        modelContext.insert(todayEntry)
        modelContext.insert(yesterdayEntry)
        modelContext.insert(tomorrowEntry)
        try modelContext.save()
        
        // すべてのエントリを取得し、今日のエントリをみつける
        let fetchDescriptor = FetchDescriptor<NightEntry>()
        let allEntries = try modelContext.fetch(fetchDescriptor)
        
        let todayEntryFound = allEntries.first { entry in
            calendar.isDate(entry.date, inSameDayAs: today)
        }
        
        XCTAssertNotNil(todayEntryFound, "Should find today's entry")
        XCTAssertEqual(todayEntryFound?.eventText, "今日のエントリ")
    }
    
    // MARK: - MODEL-023: 存在しない日付の検索
    func testFindEntryForNonExistentDate() throws {
        let calendar = Calendar.current
        let today = Date()
        let searchDate = calendar.date(byAdding: .year, value: -1, to: today)! // 1 year ago
        
        // 今日のエントリーを保存する
        let todayEntry = NightEntry(date: today, eventText: "今日のエントリ")
        modelContext.insert(todayEntry)
        try modelContext.save()
        
        // 1年前のエントリーを検索
        let fetchDescriptor = FetchDescriptor<NightEntry>()
        let allEntries = try modelContext.fetch(fetchDescriptor)
        
        let searchResult = allEntries.first { entry in
            calendar.isDate(entry.date, inSameDayAs: searchDate)
        }
        
        XCTAssertNil(searchResult, "Should not find entry for non-existent date")
    }
}
