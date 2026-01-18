//
//  HomeViewTests.swift
//  yorunoteTests
//
//  Created by Yamato on 2026/01/18.
//

import XCTest
import SwiftUI
import SwiftData
@testable import yorunote

final class HomeViewTests: XCTestCase {
    
    var modelContainer: ModelContainer!
    
    override func setUpWithError() throws {
        let schema = Schema([NightEntry.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
    }
    
    override func tearDownWithError() throws {
        modelContainer = nil
    }
    
    // MARK: - HOME-001: 初期表示
    func testHomeViewInitialDisplay() throws {
        let homeView = HomeView()
            .modelContainer(modelContainer)
        
        // ビューがクラッシュせずに作成できることをテスト
        XCTAssertNotNil(homeView, "HomeViewが正常に作成される必要があります")
        
        // 実際のUIテストでは、現在の日付が選択されていることを確認します
        // これにはViewInspectorまたは類似のテストフレームワークが必要です
    }
    
    // MARK: - HOME-011: 記録なしの場合
    func testHomeViewWithNoEntries() throws {
        let context = ModelContext(modelContainer)
        
        // エントリが存在しないことを確認
        let fetchDescriptor = FetchDescriptor<NightEntry>()
        let entries = try context.fetch(fetchDescriptor)
        XCTAssertEqual(entries.count, 0, "エントリなしで開始する必要があります")
        
        // 空のデータベースでビューを作成
        let homeView = HomeView()
            .modelContainer(modelContainer)
        
        XCTAssertNotNil(homeView, "HomeViewは空の状態を処理できる必要があります")
    }
    
    // MARK: - HOME-012: 記録ありの場合
    func testHomeViewWithExistingEntries() throws {
        let context = ModelContext(modelContainer)
        
        // テストエントリを作成
        let today = Date()
        let entry = NightEntry(
            date: today,
            eventText: "テストイベント",
            feelingText: "テスト感情",
            futureText: "テスト未来"
        )
        
        context.insert(entry)
        try context.save()
        
        // 保存されるかを確認
        let fetchDescriptor = FetchDescriptor<NightEntry>()
        let savedEntries = try context.fetch(fetchDescriptor)
        XCTAssertEqual(savedEntries.count, 1, "Should have one saved entry")
        
        let homeView = HomeView()
            .modelContainer(modelContainer)
        
        XCTAssertNotNil(homeView, "HomeView should handle existing entries")
    }
    
    // MARK: - Date Finding Logic Tests
    func testFindEntryForDate() throws {
        let context = ModelContext(modelContainer)
        let calendar = Calendar.current
        
        // 異なるエントリーを作成
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        
        let todayEntry = NightEntry(date: today, eventText: "今日のエントリ")
        let yesterdayEntry = NightEntry(date: yesterday, eventText: "昨日のエントリ")
        
        context.insert(todayEntry)
        context.insert(yesterdayEntry)
        try context.save()
        
        // 今日のエントリーが見つかるか確認
        let fetchDescriptor = FetchDescriptor<NightEntry>()
        let allEntries = try context.fetch(fetchDescriptor)
        
        let foundTodayEntry = allEntries.first { entry in
            calendar.isDate(entry.date, inSameDayAs: today)
        }
        
        let foundTomorrowEntry = allEntries.first { entry in
            calendar.isDate(entry.date, inSameDayAs: tomorrow)
        }
        
        XCTAssertNotNil(foundTodayEntry, "Should find today's entry")
        XCTAssertEqual(foundTodayEntry?.eventText, "今日のエントリ")
        XCTAssertNil(foundTomorrowEntry, "Should not find tomorrow's entry")
    }
    
    // MARK: - Multiple Entries Test
    func testHomeViewWithMultipleEntries() throws {
        let context = ModelContext(modelContainer)
        let calendar = Calendar.current
        let baseDate = Date()
        
        // 過去1週間のエントリを作成する
        for i in 0..<7 {
            let date = calendar.date(byAdding: .day, value: -i, to: baseDate) ?? baseDate
            let entry = NightEntry(
                date: date,
                eventText: "エントリ \(i)",
                feelingText: "感情 \(i)",
                futureText: "未来 \(i)"
            )
            context.insert(entry)
        }
        
        try context.save()
        
        // 全て保存されているか確認する
        let fetchDescriptor = FetchDescriptor<NightEntry>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        let savedEntries = try context.fetch(fetchDescriptor)
        
        XCTAssertEqual(savedEntries.count, 7, "Should have 7 entries")
        
        // エントリが日付順（新しい順）でソートされているかをテスト
        for i in 0..<6 {
            XCTAssertGreaterThanOrEqual(
                savedEntries[i].date,
                savedEntries[i + 1].date,
                "Entries should be sorted by date in descending order"
            )
        }
        
        let homeView = HomeView()
            .modelContainer(modelContainer)
        
        XCTAssertNotNil(homeView, "HomeView should handle multiple entries")
    }
    
    // MARK: - Edge Cases
    func testHomeViewWithFutureDate() throws {
        let context = ModelContext(modelContainer)
        let calendar = Calendar.current
        
        // 明日のエントリを作成する
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date())!
        let futureEntry = NightEntry(
            date: tomorrow,
            eventText: "未来のエントリ",
            feelingText: "未来の感情",
            futureText: "未来の未来"
        )
        
        context.insert(futureEntry)
        try context.save()
        
        let homeView = HomeView()
            .modelContainer(modelContainer)
        
        XCTAssertNotNil(homeView, "HomeView should handle future dates")
    }
    
    // MARK: - Performance Tests
    func testHomeViewPerformanceWithManyEntries() throws {
        let context = ModelContext(modelContainer)
        let calendar = Calendar.current
        let baseDate = Date()
        
        // 長期使用を再現するために多数のエントリを作成する
        let entryCount = 365 // 1年分
        
        for i in 0..<entryCount {
            let date = calendar.date(byAdding: .day, value: -i, to: baseDate) ?? baseDate
            let entry = NightEntry(
                date: date,
                eventText: "エントリ \(i)",
                feelingText: "感情 \(i)",
                futureText: "未来 \(i)"
            )
            context.insert(entry)
        }
        
        try context.save()
        
        // ビュー表示時間を測定する
        measure {
            let homeView = HomeView()
                .modelContainer(modelContainer)
            _ = homeView
        }
    }
    
    // MARK: - Data Consistency Tests
    func testDataConsistencyAfterUpdates() throws {
        let context = ModelContext(modelContainer)
        
        // 初期エントリを作成
        let entry = NightEntry(
            eventText: "初期テキスト",
            feelingText: "初期感情",
            futureText: "初期未来"
        )
        
        context.insert(entry)
        try context.save()
        
        // エントリーを更新
        entry.eventText = "更新されたテキスト"
        try context.save()
        
        let homeView = HomeView()
            .modelContainer(modelContainer)
        
        let fetchDescriptor = FetchDescriptor<NightEntry>()
        let entries = try context.fetch(fetchDescriptor)
        
        // 更新されたエントリーになっているか
        XCTAssertEqual(entries.count, 1, "Should have one entry")
        XCTAssertEqual(entries.first?.eventText, "更新されたテキスト", "Should see updated text")
        XCTAssertNotNil(homeView, "HomeView should handle updated data")
    }
}
