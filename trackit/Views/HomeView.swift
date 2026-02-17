
//  HomeView.swift
//  trackit

import SwiftUI
import SwiftData

struct HomeView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: [SortDescriptor(\Habit.sortOrder, order: .forward), SortDescriptor(\Habit.createdAt, order: .forward)])
    private var habits: [Habit]
    @Query private var settingsArray: [AppSettings]
    
    @State private var showingCreateHabit = false
    @State private var editingHabit: Habit?
    @State private var settings: AppSettings?
    
    private var backgroundColor: Color {
        Theme.from(string: resolvedSettings.theme).backgroundColor
    }
    
    private var resolvedSettings: AppSettings {
        if let settings {
            return settings
        }
        if let existing = settingsArray.first {
            return existing
        }
        return AppSettings()
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                
                // bg
                backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Date banner at top - right aligned
                    HStack {
                        Spacer()
                        Text(formattedTodayString())
                            .font(AppFont.from(string: resolvedSettings.fontName).font(size: 13))
                            .foregroundColor(Theme.from(string: resolvedSettings.theme).primaryColor.opacity(0.6))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                
                    Group {
                    if habits.isEmpty {
                        VStack(spacing: 0) {
                            Spacer()
                            
                            VStack(spacing: 24) {
                                Image(systemName: "chart.bar.fill")
                                    .font(.system(size: 64))
                                    .foregroundColor(Theme.from(string: resolvedSettings.theme).primaryColor.opacity(0.6))

                                VStack(spacing: 12) {
                                    Text("No Habits Yet")
                                        .font(AppFont.from(string: resolvedSettings.fontName).font(size: 28))
                                        .fontWeight(.bold)
                                        .foregroundColor(Theme.from(string: resolvedSettings.theme).primaryColor)

                                    Text("Start building better habits today.\nTap the + button to create your first habit.")
                                        .font(AppFont.from(string: resolvedSettings.fontName).font(size: 16))
                                        .foregroundColor(Theme.from(string: resolvedSettings.theme).primaryColor.opacity(0.7))
                                        .multilineTextAlignment(.center)
                                        .lineSpacing(2)
                                }
                            }
                            .padding(.horizontal, 32)
                            
                            Spacer()
                        }
                    } else {
                        List {
                            ForEach(habits) { habit in
                                HabitCardView(habit: habit, settings: resolvedSettings)
                                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                    .listRowSeparator(.hidden)
                                    .listRowBackground(Color.clear)
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            deleteHabit(habit)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                    .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                        Button {
                                            editingHabit = habit
                                        } label: {
                                            Label("Edit", systemImage: "pencil")
                                        }
                                        .tint(Theme.from(string: resolvedSettings.theme).primaryColor)
                                    }
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                    }
                    }
                }
                
                // create habit button (floating)
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showingCreateHabit = true
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(Theme.from(string: resolvedSettings.theme).primaryColor)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .padding()
                    }
                }
                
            }
            .navigationTitle("Habit Tracker")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView(settings: resolvedSettings)) {
                        Image(systemName: "gear")
                            .foregroundColor(Theme.from(string: resolvedSettings.theme).primaryColor)
                    }
                }
            }
            .sheet(isPresented: $showingCreateHabit) {
                CreateHabitView(settings: resolvedSettings)
            }
            .sheet(item: $editingHabit) { habit in
                CreateHabitView(habitToEdit: habit, settings: resolvedSettings)
                    .id(habit.id)
            }
            .task {
                ensureSettingsExists()
                normalizeHabitSortOrderIfNeeded()
            }
        }
    }

    private func ensureSettingsExists() {
        if let existing = settingsArray.first {
            settings = existing
            return
        }
        if settings == nil {
            let newSettings = AppSettings()
            modelContext.insert(newSettings)
            settings = newSettings
        }
    }

    private func deleteHabit(_ habit: Habit) {
        withAnimation {
            modelContext.delete(habit)
        }
    }

    private func normalizeHabitSortOrderIfNeeded() {
        guard !habits.isEmpty else { return }

        let uniqueOrders = Set(habits.map { $0.sortOrder })
        let looksUninitialized = uniqueOrders.count == 1

        guard looksUninitialized else { return }

        let byCreatedAt = habits.sorted { $0.createdAt < $1.createdAt }
        for (index, habit) in byCreatedAt.enumerated() {
            habit.sortOrder = index
        }
        try? modelContext.save()
    }
    
    private func formattedTodayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: Date())
    }
}
