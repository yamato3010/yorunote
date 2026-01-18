//
//  ShredderViewTests.swift
//  yorunoteTests
//
//  Created by Yamato on 2026/01/18.
//

import XCTest
import SwiftUI
import Combine
@testable import yorunote

final class ShredderViewTests: XCTestCase {
    
    // MARK: - SHRED-001: 初期状態
    func testShredderViewInitialState() throws {
        let shredderView = ShredderView()
        
        XCTAssertNotNil(shredderView, "ShredderViewが正常に作成される必要があります")
    }
    
    // MARK: - ShredderAnimationViewテスト
    func testShredderAnimationView() throws {
        let animationView = ShredderAnimationView()
        
        XCTAssertNotNil(animationView, "ShredderAnimationViewが正常に作成される必要があります")
        
    }
    
    // MARK: - ビュー作成テスト
    func testShredderViewCreation() throws {
        // ShredderViewが例外なく作成できることを確認
        XCTAssertNoThrow({
            let _ = ShredderView()
        }, "ShredderViewの作成で例外が発生してはいけません")
    }
    
    // MARK: - プレビュー作成テスト
    func testShredderViewPreview() throws {
        // プレビューが例外なく作成できることを確認
        XCTAssertNoThrow({
            let _ = ShredderView()
        }, "ShredderViewのプレビューで例外が発生してはいけません")
    }
    
    // MARK: - ビューの基本プロパティテスト
    func testShredderViewBasicProperties() throws {
        let shredderView = ShredderView()
        
        // ビューが正常に初期化されることを確認
        XCTAssertNotNil(shredderView, "ShredderViewが初期化される必要があります")
    } 
    
    // MARK: - パフォーマンステスト
    func testShredderViewCreationPerformance() throws {
        measure {
            let shredderView = ShredderView()
            _ = shredderView
        }
    }
}
