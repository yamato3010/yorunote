//
//  RitualInputView.swift
//  yorunote
//
//  Created by Yamato on 2026/01/07.
//

import SwiftUI
import SwiftData

struct RitualInputView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var eventText: String = ""
    @State private var feelingText: String = ""
    @State private var futureText: String = ""
    
    // 編集モードの場合に使用
    var existingEntry: NightEntry?
    
    init(entry: NightEntry? = nil) {
        self.existingEntry = entry
        if let entry = entry {
            _eventText = State(initialValue: entry.eventText)
            _feelingText = State(initialValue: entry.feelingText)
            _futureText = State(initialValue: entry.futureText)
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("今日あったこと")) {
                    TextField("例：仕事でプレゼンがうまくいった", text: $eventText, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section(header: Text("感じたこと")) {
                    TextField("例：緊張したけど、達成感があった！", text: $feelingText, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section(header: Text("明日の自分へ")) {
                    TextField("例：明日はゆっくりコーヒーでも飲もう", text: $futureText, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("夜の儀式")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveEntry()
                        dismiss()
                    }
                    .disabled(eventText.isEmpty && feelingText.isEmpty && futureText.isEmpty)
                }
            }
        }
    }
    
    private func saveEntry() {
        if let existing = existingEntry {
            existing.eventText = eventText
            existing.feelingText = feelingText
            existing.futureText = futureText
        } else {
            let newEntry = NightEntry(date: Date(), eventText: eventText, feelingText: feelingText, futureText: futureText)
            modelContext.insert(newEntry)
        }
    }
}

#Preview {
    RitualInputView()
}
