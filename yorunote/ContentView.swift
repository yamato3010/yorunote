//
//  ContentView.swift
//  yorunote
//
//  Created by Yamato on 2026/01/07.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selection = 0
    
    var body: some View {
        TabView(selection: $selection) {
            HomeView()
                .tabItem {
                    Label("ホーム", systemImage: "calendar")
                }
                .tag(0)
            
            ShredderView()
                .tabItem {
                    Label("シュレッダー", systemImage: "trash")
                }
                .tag(1)
        }
        .preferredColorScheme(selection == 1 ? .dark : .none)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: NightEntry.self, inMemory: true)
}
