//
//  HomeView.swift
//  yorunote
//
//  Created by Yamato on 2026/01/07.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \NightEntry.date, order: .reverse) private var entries: [NightEntry]
    
    @State private var showingRitualInput = false
    @State private var selectedDate: Date = Date()
    @State private var selectedEntry: NightEntry?
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            VStack {
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
            }
            .navigationTitle("ヨルノート")
            .sheet(isPresented: $showingRitualInput) {
                RitualInputView(entry: selectedEntry)
            }
            .alert("エラー", isPresented: $showingErrorAlert) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                findEntry(for: selectedDate)
            }
        }
    }
    
    private func findEntry(for date: Date) {
        // データ検索処理を実行
        guard !entries.isEmpty else {
            selectedEntry = nil
            return
        }
        
        let calendar = Calendar.current
        selectedEntry = entries.first { entry in
            calendar.isDate(entry.date, inSameDayAs: date)
        }
        
        ErrorLogger.logInfo("日付 \(date) のエントリ検索完了: \(selectedEntry != nil ? "見つかりました" : "見つかりませんでした")")
    }
}

#Preview {
    HomeView()
        .modelContainer(for: NightEntry.self, inMemory: true)
}
