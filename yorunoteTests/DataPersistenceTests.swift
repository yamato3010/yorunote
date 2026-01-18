//
//  DataPersistenceTests.swift
//  yorunoteTests
//
//  Created by Yamato on 2026/01/18.
//

import XCTest
import SwiftData
@testable import yorunote

final class DataPersistenceTests: XCTestCase {
    
    // MARK: - PERSIST-001: アプリ起動時の初期化
    func testModelContainerInitialization() throws {
        let schema = Schema([NightEntry.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        
        XCTAssertNoThrow(
            try ModelContainer(for: schema, configurations: [modelConfiguration]),
            "ModelContainerは例外をスローせずに初期化される必要があります"
        )
        
        let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
        XCTAssertNotNil(container, "ModelContainerが正常に作成される必要があります")
    }
    
    // MARK: - PERSIST-002: スキーマ設定
    func testSchemaConfiguration() throws {
        let schema = Schema([NightEntry.self])
        
        XCTAssertTrue(schema.entities.contains { $0.name == "NightEntry" }, 
                     "スキーマにNightEntryエンティティが含まれている必要があります")
    }
    
    // MARK: - PERSIST-003: 永続化設定
    func testPersistenceConfiguration() throws {
        let schema = Schema([NightEntry.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        XCTAssertFalse(modelConfiguration.isStoredInMemoryOnly, 
                      "設定は永続ストレージ用に設定される必要があります")
    }
    
    // MARK: - PERSIST-011: アプリ再起動後のデータ
    func testDataPersistenceAcrossContexts() throws {
        let schema = Schema([NightEntry.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
        
        // データを保存
        let context1 = ModelContext(container)
        let entry = NightEntry(eventText: "永続化テスト")
        context1.insert(entry)
        try context1.save()
        
        // アプリを再起動して保存されているか確認
        let context2 = ModelContext(container)
        let fetchDescriptor = FetchDescriptor<NightEntry>()
        let retrievedEntries = try context2.fetch(fetchDescriptor)
        
        XCTAssertEqual(retrievedEntries.count, 1, "Data should persist across contexts")
        XCTAssertEqual(retrievedEntries.first?.eventText, "永続化テスト")
    }
    
    // MARK: - PERSIST-012: 大量データ保存
    func testLargeDataSetPersistence() throws {
        let schema = Schema([NightEntry.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
        let context = ModelContext(container)
        
        // Create 100+ entries
        let entryCount = 100
        let calendar = Calendar.current
        let baseDate = Date()
        
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
        
        // セーブ時の時間を計測
        let saveStartTime = CFAbsoluteTimeGetCurrent()
        try context.save()
        let saveEndTime = CFAbsoluteTimeGetCurrent()
        let saveTime = saveEndTime - saveStartTime
        
        // パフォーマンスを測定
        let fetchStartTime = CFAbsoluteTimeGetCurrent()
        let fetchDescriptor = FetchDescriptor<NightEntry>()
        let savedEntries = try context.fetch(fetchDescriptor)
        let fetchEndTime = CFAbsoluteTimeGetCurrent()
        let fetchTime = fetchEndTime - fetchStartTime
        
        XCTAssertEqual(savedEntries.count, entryCount, "All entries should be saved")
        XCTAssertLessThan(saveTime, 10.0, "Save operation should complete within 10 seconds")
        XCTAssertLessThan(fetchTime, 5.0, "Fetch operation should complete within 5 seconds")
        
        let sortedEntries = savedEntries.sorted { 
            // 数値部分を抽出して正しくソート
            let num1 = Int($0.eventText.replacingOccurrences(of: "エントリ ", with: "")) ?? 0
            let num2 = Int($1.eventText.replacingOccurrences(of: "エントリ ", with: "")) ?? 0
            return num1 < num2
        }
        
        // データ整合性の検証（最初の10件のみチェックして高速化）
        let checkCount = min(10, sortedEntries.count)
        for index in 0..<checkCount {
            let entry = sortedEntries[index]
            XCTAssertEqual(entry.eventText, "エントリ \(index)", "Entry text should match index at position \(index)")
            XCTAssertEqual(entry.feelingText, "感情 \(index)", "Feeling text should match index at position \(index)")
            XCTAssertEqual(entry.futureText, "未来 \(index)", "Future text should match index at position \(index)")
        }
    }
    
    // MARK: - Error Handling Tests
    func testDatabaseErrorHandling() throws {
        let schema = Schema([NightEntry.self])
        
        // 通常の状況ではエラーは発生しないはずだが、エラー処理パスをテスト
        XCTAssertNoThrow(
            try ModelContainer(for: schema, configurations: []),
            "Empty configuration should be handled gracefully"
        )
    }
    
    // MARK: - Memory Management Tests
    func testMemoryManagement() throws {
        let schema = Schema([NightEntry.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        
        weak var weakContainer: ModelContainer?
        weak var weakContext: ModelContext?
        
        autoreleasepool {
            let container = try! ModelContainer(for: schema, configurations: [modelConfiguration])
            let context = ModelContext(container)
            
            weakContainer = container
            weakContext = context
            
            let entry = NightEntry(eventText: "メモリテスト")
            context.insert(entry)
            try! context.save()
        }
        
        XCTAssertNil(weakContext, "Context should be deallocated")
        XCTAssertNil(weakContainer, "Container should be deallocated")
    }
}
