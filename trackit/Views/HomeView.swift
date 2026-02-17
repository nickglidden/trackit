
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
                            
                            // MARK: - Version Info (Empty State)
                            VStack(spacing: 4) {
                                Text("TrackIt")
                                    .font(AppFont.from(string: resolvedSettings.fontName).font(size: 14))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white.opacity(0.6))
                                
                                Text("v\(resolvedSettings.appVersion) (Build \(resolvedSettings.buildNumber))")
                                    .font(AppFont.from(string: resolvedSettings.fontName).font(size: 12))
                                    .foregroundColor(.white.opacity(0.4))
                            }
                            .padding(.bottom, 20)
                        }
                    } else {
                        habitsList
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
            .navigationTitle("TrackIt!")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView(settings: resolvedSettings)) {
                        Image(systemName: "gear")
                            .foregroundColor(.primary)
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

    // MARK: - Habits List
    
    private var habitsList: some View {
        List {
            ForEach(habits) { habit in
                habitRow(for: habit)
            }
            .onMove(perform: moveHabit)
            
            versionFooter
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color.clear)
    }
    
    private func habitRow(for habit: Habit) -> some View {
        HabitCardView(habit: habit, settings: resolvedSettings)
            .listRowInsets(EdgeInsets(top: 20, leading: 16, bottom: 10, trailing: 16))
            .listRowSeparator(habit.id == habits.last?.id ? .hidden : .automatic, edges: .bottom)
            .listRowSeparatorTint(Theme.from(string: resolvedSettings.theme).primaryColor.opacity(0.2))
            .listRowBackground(Color.clear)
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button {
                    deleteHabit(habit)
                } label: {
                    Label("Delete", systemImage: "trash")
                }
                .tint(Theme.from(string: resolvedSettings.theme).primaryColor)
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
    
    private var versionFooter: some View {
        Section {
            VStack(spacing: 4) {
                Text("TrackIt")
                    .font(AppFont.from(string: resolvedSettings.fontName).font(size: 14))
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.6))
                
                Text("v\(resolvedSettings.appVersion) (Build \(resolvedSettings.buildNumber))")
                    .font(AppFont.from(string: resolvedSettings.fontName).font(size: 12))
                    .foregroundColor(.white.opacity(0.4))
            }
            .frame(maxWidth: .infinity)
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
        }
        .padding(.top, 40)
        .padding(.bottom, 20)
    }
    
    // MARK: - Helper Methods
    
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
    
    private func moveHabit(from source: IndexSet, to destination: Int) {
        var revisedHabits = habits.map { $0 }
        revisedHabits.move(fromOffsets: source, toOffset: destination)
        
        for (index, habit) in revisedHabits.enumerated() {
            habit.sortOrder = index
        }
        
        try? modelContext.save()
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
