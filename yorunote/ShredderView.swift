//
//  ShredderView.swift
//  yorunote
//
//  Created by Yamato on 2026/01/07.
//

import SwiftUI
import Combine

struct ShredderView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var text: String = ""
    @State private var timeRemaining: Int = 60
    @State private var isTimerRunning: Bool = false
    @State private var isShredding: Bool = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.opacity(0.9).ignoresSafeArea()
                
                VStack {
                    if !isShredding {
                        Text("\(timeRemaining)秒")
                            .font(.system(size: 40, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .padding()
                        
                        TextEditor(text: $text)
                            .scrollContentBackground(.hidden)
                            .background(Color.white.opacity(0.1))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    .padding()
                            )
                            .onChange(of: text) { _, _ in
                                if !isTimerRunning && !text.isEmpty {
                                    isTimerRunning = true
                                }
                            }
                        
                        Button(action: startShredding) {
                            Text("スッキリする（破棄）")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                // macOS compatibility fix for background color
                                .background(Color.red.opacity(0.8))
                                .cornerRadius(10)
                        }
                        .padding()
                        .disabled(text.isEmpty)
                    } else {
                        ShreddingAnimationView()
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    dismiss()
                                }
                            }
                    }
                }
            }
            .navigationTitle("1分間シュレッダー")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる", action: { dismiss() })
                        .foregroundColor(.white)
                }
            }
            .onReceive(timer) { _ in
                if isTimerRunning && timeRemaining > 0 {
                    timeRemaining -= 1
                } else if isTimerRunning && timeRemaining == 0 {
                    startShredding()
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private func startShredding() {
        isTimerRunning = false
        withAnimation(.easeInOut(duration: 1.0)) {
            isShredding = true
        }
    }
}

struct ShreddingAnimationView: View {
    var body: some View {
        VStack {
            Text("🗑️")
                .font(.system(size: 100))
                .padding()
            Text("モヤモヤを消去しました")
                .foregroundColor(.white)
                .font(.headline)
        }
        .transition(.opacity)
    }
}

#Preview {
    ShredderView()
}
