//
//  ContentView.swift
//  yorunote
//
//  Created by Yamato on 2026/01/07.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \NightEntry.date, order: .reverse) private var entries: [NightEntry]
    
    @State private var showingRitualInput = false
    @State private var showingShredder = false
    @State private var selectedDate: Date = Date()
    @State private var selectedEntry: NightEntry?
    
    var body: some View {
        NavigationStack {
            VStack {
                // カレンダー表示 (簡易版: 直近のリスト表示 + カレンダー風ヘッダー)
                // 本格的なカレンダー実装は量が多いため、まずはDatePickerで代用し、
                // 下部にリストを表示する形にする。
                
                DatePicker("日付を選択", selection: $selectedDate, displayedComponents: [.date])
                    .datePickerStyle(.graphical)
                    .accentColor(.purple)
                    .onChange(of: selectedDate) { _, newValue in
                        findEntry(for: newValue)
                    }
                    .padding()
                
                Divider()
                
                if let entry = selectedEntry {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("【記録あり】")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("今日あったこと: \(entry.eventText.prefix(20))...")
                            .font(.body)
                        
                        Button("内容を確認する") {
                            showingRitualInput = true
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.purple)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(10)
                    .padding()
                } else {
                    VStack {
                        Text("この日の記録はありません")
                            .foregroundColor(.secondary)
                            .padding()
                        
                        // 選択日が今日の場合のみボタン表示
                        if Calendar.current.isDateInToday(selectedDate) {
                             Button(action: {
                                showingRitualInput = true
                            }) {
                                HStack {
                                    Image(systemName: "moon.stars.fill")
                                    Text("今日の儀式を始める")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
                                .cornerRadius(15)
                                .shadow(radius: 5)
                            }
                            .padding()
                        }
                    }
                }

                Spacer()
                
                // シュレッダー起動ボタン
                Button(action: {
                    showingShredder = true
                }) {
                    HStack {
                        Image(systemName: "trash")
                        Text("1分間書き殴りシュレッダー")
                    }
                    .font(.subheadline)
                    .foregroundColor(.red)
                }
                .padding(.bottom)
            }
            .navigationTitle("ヨルノート")
            .sheet(isPresented: $showingRitualInput) {
                RitualInputView(entry: selectedEntry)
            }
            #if os(iOS)
            .fullScreenCover(isPresented: $showingShredder) {
                ShredderView()
            }
            #else
            .sheet(isPresented: $showingShredder) {
                ShredderView()
                    .frame(minWidth: 400, minHeight: 600)
            }
            #endif
            .onAppear {
                findEntry(for: selectedDate)
            }
        }
    }
    
    private func findEntry(for date: Date) {
        // 日付だけでフィルタリング（時間は無視）
        let calendar = Calendar.current
        selectedEntry = entries.first { entry in
            calendar.isDate(entry.date, inSameDayAs: date)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: NightEntry.self, inMemory: true)
}
