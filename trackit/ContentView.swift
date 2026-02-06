//
//  ContentView.swift
//  trackit
//
//  Created by Nick Glidden on 2/6/26.
//
//  This file is kept for reference but not used in the app.
//  The app uses HomeView as the main entry point.

import SwiftUI
import SwiftData

struct ContentView_Legacy: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        Text("Legacy ContentView - Not Used")
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
