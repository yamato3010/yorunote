//
//  TestSetup.swift
//  yorunoteTests
//
//  Created by Yamato on 2026/01/18.
//

import XCTest
import SwiftData
@testable import yorunote

/// 共通のセットアップとユーティリティを持つベーステストクラス
class BaseTestCase: XCTestCase {
    
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        setupTestDatabase()
    }
    
    override func tearDownWithError() throws {
        cleanupTestDatabase()
        try super.tearDownWithError()
    }
    
    // MARK: - データベースセットアップ
    
    private func setupTestDatabase() {
        do {
            let schema = Schema([NightEntry.self])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            modelContext = ModelContext(modelContainer)
        } catch {
            XCTFail("テストデータベースのセットアップに失敗しました: \(error)")
        }
    }
    
    private func cleanupTestDatabase() {
        modelContext = nil
        modelContainer = nil
    }
    
    // MARK: - ヘルパーメソッド
    
    /// テストエントリを作成して保存
    func createTestEntry(
        date: Date = Date(),
        eventText: String = "テストイベント",
        feelingText: String = "テスト感情",
        futureText: String = "テスト未来"
    ) throws -> NightEntry {
        let entry = NightEntry(
            date: date,
            eventText: eventText,
            feelingText: feelingText,
            futureText: futureText
        )
        
        modelContext.insert(entry)
        try modelContext.save()
        return entry
    }
    
    /// Creates multiple test entries
    func createTestEntries(count: Int) throws -> [NightEntry] {
        var entries: [NightEntry] = []
        let calendar = Calendar.current
        let baseDate = Date()
        
        for i in 0..<count {
            let date = calendar.date(byAdding: .day, value: -i, to: baseDate) ?? baseDate
            let entry = try createTestEntry(
                date: date,
                eventText: "エントリ \(i)",
                feelingText: "感情 \(i)",
                futureText: "未来 \(i)"
            )
            entries.append(entry)
        }
        
        return entries
    }
    
    /// Fetches all entries from the test database
    func fetchAllEntries() throws -> [NightEntry] {
        let fetchDescriptor = FetchDescriptor<NightEntry>()
        return try modelContext.fetch(fetchDescriptor)
    }
    
    /// Clears all entries from the test database
    func clearAllEntries() throws {
        let entries = try fetchAllEntries()
        for entry in entries {
            modelContext.delete(entry)
        }
        try modelContext.save()
    }
    
    /// Asserts that two dates are on the same day
    func assertSameDay(_ date1: Date, _ date2: Date, file: StaticString = #file, line: UInt = #line) {
        let calendar = Calendar.current
        XCTAssertTrue(
            calendar.isDate(date1, inSameDayAs: date2),
            "Dates should be on the same day: \(date1) vs \(date2)",
            file: file,
            line: line
        )
    }
    
    /// Asserts that an entry has the expected content
    func assertEntryContent(
        _ entry: NightEntry,
        eventText: String,
        feelingText: String,
        futureText: String,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertEqual(entry.eventText, eventText, "Event text should match", file: file, line: line)
        XCTAssertEqual(entry.feelingText, feelingText, "Feeling text should match", file: file, line: line)
        XCTAssertEqual(entry.futureText, futureText, "Future text should match", file: file, line: line)
    }
    
    /// Waits for a condition to be true with timeout
    func waitForCondition(
        timeout: TimeInterval = 5.0,
        condition: @escaping () -> Bool,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let expectation = XCTestExpectation(description: "Waiting for condition")
        
        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if condition() {
                expectation.fulfill()
                timer.invalidate()
            }
        }
        
        let result = XCTWaiter.wait(for: [expectation], timeout: timeout)
        timer.invalidate()
        
        XCTAssertEqual(result, .completed, "Condition should be met within timeout", file: file, line: line)
    }
}

// MARK: - Test Utilities

struct TestUtilities {
    
    /// Generates random Japanese text for testing
    static func randomJapaneseText(length: Int = 50) -> String {
        let characters = "あいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめもやゆよらりるれろわをん"
        return String((0..<length).map { _ in characters.randomElement()! })
    }
    
    /// Generates test text with special characters
    static func specialCharacterText() -> String {
        return "🌙✨💭\n改行\tタブ\"引用符\"'アポストロフィ'<>記号&amp;エンティティ"
    }
    
    /// Creates a date from string (yyyy-MM-dd format)
    static func dateFromString(_ dateString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateString) ?? Date()
    }
    
    /// Formats date to string for comparison
    static func stringFromDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    /// Measures execution time of a block
    static func measureTime<T>(block: () throws -> T) rethrows -> (result: T, time: TimeInterval) {
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = try block()
        let endTime = CFAbsoluteTimeGetCurrent()
        return (result, endTime - startTime)
    }
    
    /// Creates a temporary file URL for testing
    static func temporaryFileURL(withExtension ext: String = "db") -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = UUID().uuidString + "." + ext
        return tempDir.appendingPathComponent(fileName)
    }
}

// MARK: - Mock Data Generator

struct MockDataGenerator {
    
    /// Generates realistic Japanese diary entries
    static func realisticEntries(count: Int) -> [NightEntry] {
        let events = [
            "今日は仕事で新しいプロジェクトが始まった",
            "友達とカフェでゆっくり話した",
            "散歩をして桜がきれいだった",
            "本を読んで新しい発見があった",
            "料理に挑戦して美味しくできた",
            "映画を見て感動した",
            "家族と電話で話した",
            "運動をして気持ちよかった"
        ]
        
        let feelings = [
            "とても充実感があった",
            "少し疲れたけど満足している",
            "新鮮な気持ちになった",
            "心が軽やかになった",
            "達成感を感じた",
            "穏やかな気持ちだった",
            "嬉しい気持ちになった",
            "リフレッシュできた"
        ]
        
        let futures = [
            "明日も良い一日にしたい",
            "新しいことに挑戦してみよう",
            "もっと時間を大切にしよう",
            "感謝の気持ちを忘れずにいよう",
            "健康に気をつけて過ごそう",
            "人との繋がりを大切にしよう",
            "自分らしく過ごそう",
            "前向きに頑張ろう"
        ]
        
        let calendar = Calendar.current
        let baseDate = Date()
        var entries: [NightEntry] = []
        
        for i in 0..<count {
            let date = calendar.date(byAdding: .day, value: -i, to: baseDate) ?? baseDate
            let entry = NightEntry(
                date: date,
                eventText: events.randomElement() ?? "今日は良い日だった",
                feelingText: feelings.randomElement() ?? "満足している",
                futureText: futures.randomElement() ?? "明日も頑張ろう"
            )
            entries.append(entry)
        }
        
        return entries
    }
    
    /// Generates entries with various edge cases
    static func edgeCaseEntries() -> [NightEntry] {
        return [
            TestData.emptyEntry(),
            TestData.longTextEntry(),
            TestData.specialCharacterEntry(),
            TestData.whitespaceOnlyEntry(),
            TestData.singleCharacterEntry(),
            TestData.numbersOnlyEntry()
        ]
    }
}

// MARK: - Performance Measurement

class PerformanceMeasurement {
    
    private var startTime: CFAbsoluteTime = 0
    private var measurements: [String: TimeInterval] = [:]
    
    func start() {
        startTime = CFAbsoluteTimeGetCurrent()
    }
    
    func measure(_ operation: String) {
        let currentTime = CFAbsoluteTimeGetCurrent()
        measurements[operation] = currentTime - startTime
        startTime = currentTime
    }
    
    func results() -> [String: TimeInterval] {
        return measurements
    }
    
    func printResults() {
        print("Performance Measurements:")
        for (operation, time) in measurements.sorted(by: { $0.value < $1.value }) {
            print("  \(operation): \(String(format: "%.4f", time))s")
        }
    }
}

// MARK: - Test Assertions

extension XCTestCase {
    
    /// Asserts that a block throws a specific error
    func XCTAssertThrowsSpecificError<T, E: Error & Equatable>(
        _ expression: @autoclosure () throws -> T,
        expectedError: E,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertThrowsError(try expression(), file: file, line: line) { error in
            XCTAssertEqual(error as? E, expectedError, file: file, line: line)
        }
    }
    
    /// Asserts that a value is within a range
    func XCTAssertInRange<T: Comparable>(
        _ value: T,
        min: T,
        max: T,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertGreaterThanOrEqual(value, min, "Value should be >= \(min)", file: file, line: line)
        XCTAssertLessThanOrEqual(value, max, "Value should be <= \(max)", file: file, line: line)
    }
    
    /// Asserts that execution time is within acceptable limits
    func XCTAssertPerformance<T>(
        _ expression: @escaping () throws -> T,
        maxTime: TimeInterval,
        file: StaticString = #file,
        line: UInt = #line
    ) rethrows -> T {
        let (result, time) = try TestUtilities.measureTime(block: expression)
        XCTAssertLessThan(time, maxTime, "Execution should complete within \(maxTime)s", file: file, line: line)
        return result
    }
}
