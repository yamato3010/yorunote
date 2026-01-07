//
//  ContentView.swift
//  yorunote
//
//  Created by Yamato on 2026/01/07.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("ホーム", systemImage: "calendar")
                }
            
            ShredderView()
                .tabItem {
                    Label("シュレッダー", systemImage: "trash")
                }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: NightEntry.self, inMemory: true)
}
