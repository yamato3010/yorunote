//
//  ErrorHandling.swift
//  yorunote
//
//  Created by Yamato on 2026/01/18.
//

import SwiftUI

// エラーメッセージ
struct ErrorMessages {
    static let saveFailure = "保存に失敗しました。もう一度お試しください。"
    static let loadFailure = "データの読み込みに失敗しました。"
    static let systemError = "予期しないエラーが発生しました。"
    static let networkError = "通信エラーが発生しました。"
}

// エラーログ出力
struct ErrorLogger {
    static func log(_ error: Error, context: String = "", function: String = #function, file: String = #file, line: Int = #line) {
        let fileName = (file as NSString).lastPathComponent
        let message = "[\(fileName):\(line)] \(function) - \(context): \(error.localizedDescription)"
        print("🔴 エラー: \(message)")
    }
    
    static func logInfo(_ message: String, function: String = #function, file: String = #file, line: Int = #line) {
        let fileName = (file as NSString).lastPathComponent
        print("ℹ️ 情報: [\(fileName):\(line)] \(function) - \(message)")
    }
}