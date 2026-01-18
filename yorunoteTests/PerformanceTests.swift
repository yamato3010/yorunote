//
//  PerformanceTests.swift
//  yorunoteTests
//
//  Created by Yamato on 2026/01/18.
//

import XCTest
import SwiftUI
import SwiftData
@testable import yorunote

final class PerformanceTests: XCTestCase {
    
    var modelContainer: ModelContainer!
    
    override func setUpWithError() throws {
        let schema = Schema([NightEntry.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
    }
    
    override func tearDownWithError() throws {
        modelContainer = nil
    }
    
    // MARK: - PERF-011: 大量データ読み込み
    func testLargeDatasetFetchPerformance() throws {
        let context = ModelContext(modelContainer)
        
        // 1年分のデータを作成
        let entries = TestData.yearOfEntries()
        for entry in entries {
            context.insert(entry)
        }
        try context.save()
        
        // 取得時のパフォーマンスを計測
        measure {
            let fetchDescriptor = FetchDescriptor<NightEntry>(
                sortBy: [SortDescriptor(\.date, order: .reverse)]
            )
            let _ = try! context.fetch(fetchDescriptor)
        }
    }
    
    // MARK: - PERF-012: カレンダー描画
    func testCalendarDataPreparationPerformance() throws {
        let context = ModelContext(modelContainer)
        
        // 1年間分のデータを作成
        let entries = TestData.yearOfEntries()
        for entry in entries {
            context.insert(entry)
        }
        try context.save()
        
        // カレンダーデータを準備するまでのパフォーマンスを計測
        measure {
            let fetchDescriptor = FetchDescriptor<NightEntry>()
            let allEntries = try! context.fetch(fetchDescriptor)
            let calendar = Calendar.current
            let today = Date()
            
            // 現在の月の各日のエントリの検索
            for i in 0..<30 {
                let targetDate = calendar.date(byAdding: .day, value: -i, to: today) ?? today
                let _ = allEntries.first { entry in
                    calendar.isDate(entry.date, inSameDayAs: targetDate)
                }
            }
        }
    }
    
    // MARK: - Data Insertion Performance
    func testBulkInsertPerformance() throws {
        let context = ModelContext(modelContainer)
        
        measure {
            // 100このエントリを追加
            for i in 0..<100 {
                let entry = NightEntry(
                    eventText: "Performance test entry \(i)",
                    feelingText: "Performance test feeling \(i)",
                    futureText: "Performance test future \(i)"
                )
                context.insert(entry)
            }
            
            try! context.save()
        }
    }
    
    // MARK: - Search Performance
    func testDateBasedSearchPerformance() throws {
        let context = ModelContext(modelContainer)
        
        // 1000件のエントリを作成
        let entries = TestData.largeDataSet(count: 1000)
        for entry in entries {
            context.insert(entry)
        }
        try context.save()
        
        let calendar = Calendar.current
        let today = Date()
        
        measure {
            let fetchDescriptor = FetchDescriptor<NightEntry>()
            let allEntries = try! context.fetch(fetchDescriptor)
            
            // 今日のエントリを検索
            let _ = allEntries.first { entry in
                calendar.isDate(entry.date, inSameDayAs: today)
            }
        }
    }
    
    // MARK: - Update Performance
    func testBulkUpdatePerformance() throws {
        let context = ModelContext(modelContainer)
        
        let entries = TestData.largeDataSet(count: 100)
        for entry in entries {
            context.insert(entry)
        }
        try context.save()
        
        // エントリを更新する
        let fetchDescriptor = FetchDescriptor<NightEntry>()
        let savedEntries = try context.fetch(fetchDescriptor)
        
        measure {
            for (index, entry) in savedEntries.enumerated() {
                entry.eventText = "Updated event \(index)"
                entry.feelingText = "Updated feeling \(index)"
                entry.futureText = "Updated future \(index)"
            }
            
            try! context.save()
        }
    }
    
    // MARK: - Memory Performance
    func testMemoryUsageWithLargeDataset() throws {
        let context = ModelContext(modelContainer)
        
        measure {
            autoreleasepool {
                let entries = TestData.largeDataSet(count: 500)
                for entry in entries {
                    context.insert(entry)
                }
                try! context.save()
                
                let fetchDescriptor = FetchDescriptor<NightEntry>()
                let savedEntries = try! context.fetch(fetchDescriptor)
                
                let _ = savedEntries.map { entry in
                    "\(entry.eventText) - \(entry.feelingText) - \(entry.futureText)"
                }
            }
        }
    }
    
    // MARK: - View Creation Performance
    func testViewCreationPerformance() throws {
        let context = ModelContext(modelContainer)
        
        let entries = TestData.weekOfEntries()
        for entry in entries {
            context.insert(entry)
        }
        try context.save()
        
        measure {
            // データを使用してビューの作成をする
            let homeView = HomeView()
                .modelContainer(modelContainer)
            _ = homeView
            
            let ritualView = RitualInputView()
                .modelContainer(modelContainer)
            _ = ritualView
            
            let shredderView = ShredderView()
            _ = shredderView
        }
    }
    
    // MARK: - Date Calculation Performance
    func testDateCalculationPerformance() throws {
        let calendar = Calendar.current
        let baseDate = Date()
        
        measure {
            // カレンダービューの日付計算をする
            for i in 0..<365 {
                let _ = calendar.date(byAdding: .day, value: -i, to: baseDate)
                let _ = calendar.isDate(baseDate, inSameDayAs: baseDate)
                let _ = calendar.startOfDay(for: baseDate)
            }
        }
    }
    
    // MARK: - Text Processing Performance
    func testTextProcessingPerformance() throws {
        let longText = String(repeating: "パフォーマンステストのための長いテキスト。", count: 1000)
        
        measure {
            let _ = longText.isEmpty
            let _ = longText.count
            let _ = longText.prefix(100)
            let _ = longText.trimmingCharacters(in: .whitespacesAndNewlines)
            let _ = longText.components(separatedBy: .newlines)
        }
    }
    
    // MARK: - Concurrent Operations Performance
    func testConcurrentOperationsPerformance() throws {
        let context1 = ModelContext(modelContainer)
        let context2 = ModelContext(modelContainer)
        
        measure {
            // 同時操作再現
            let group = DispatchGroup()
            
            group.enter()
            DispatchQueue.global().async {
                for i in 0..<50 {
                    let entry = NightEntry(eventText: "Context1 entry \(i)")
                    context1.insert(entry)
                }
                try! context1.save()
                group.leave()
            }
            
            group.enter()
            DispatchQueue.global().async {
                for i in 0..<50 {
                    let entry = NightEntry(eventText: "Context2 entry \(i)")
                    context2.insert(entry)
                }
                try! context2.save()
                group.leave()
            }
            
            group.wait()
        }
    }
    
    // MARK: - Query Optimization Performance
    func testQueryOptimizationPerformance() throws {
        let context = ModelContext(modelContainer)
        
        let calendar = Calendar.current
        let baseDate = Date()
        
        for i in 0..<1000 {
            let randomDays = Int.random(in: 0...365)
            let date = calendar.date(byAdding: .day, value: -randomDays, to: baseDate) ?? baseDate
            let entry = NightEntry(
                date: date,
                eventText: "Query test entry \(i)"
            )
            context.insert(entry)
        }
        try context.save()
        
        measure {
            // さまざまなクエリをテスト
            
            // すべてを取得してフィルタリング
            let fetchAll = FetchDescriptor<NightEntry>()
            let allEntries = try! context.fetch(fetchAll)
            let _ = allEntries.filter { entry in
                calendar.isDate(entry.date, inSameDayAs: baseDate)
            }
            
            // ソートしてフェッチ
            let sortedFetch = FetchDescriptor<NightEntry>(
                sortBy: [SortDescriptor(\.date, order: .reverse)]
            )
            let _ = try! context.fetch(sortedFetch)
        }
    }
    
    // MARK: - Stress Tests
    func testStressTestWithRapidOperations() throws {
        let context = ModelContext(modelContainer)
        
        measure {
            for i in 0..<100 {
                let entry = NightEntry(eventText: "Stress test \(i)")
                context.insert(entry)
                
                if i % 10 == 0 {
                    try! context.save()
                }
                
                // Updateする
                entry.feelingText = "Updated feeling \(i)"
                
                // Fetchする
                let fetchDescriptor = FetchDescriptor<NightEntry>()
                let _ = try! context.fetch(fetchDescriptor)
            }
            
            try! context.save()
        }
    }
}
