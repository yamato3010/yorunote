//
//  NightEntry.swift
//  yorunote
//
//  Created by Yamato on 2026/01/07.
//

import Foundation
import SwiftData

@Model
final class NightEntry {
    var id: UUID
    var date: Date
    var eventText: String // 今日あったこと
    var feelingText: String // 感じたこと
    var futureText: String // 明日の自分へ
    
    init(date: Date = Date(), eventText: String = "", feelingText: String = "", futureText: String = "") {
        self.id = UUID()
        self.date = date
        self.eventText = eventText
        self.feelingText = feelingText
        self.futureText = futureText
    }
}
