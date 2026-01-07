//
//  Item.swift
//  yorunote
//
//  Created by Yamato on 2026/01/07.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
