
//  HomeView.swift
//  trackit

import SwiftUI
import SwiftData

struct HomeView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    @Query private var habits: [Habit]
    @Query private var settingsArray: [AppSettings]
    
    @State private var showingCreateHabit = false
    
    private var backgroundColor: Color {
        Theme.from(string: settings.theme).backgroundColor
    }
    
    private var settings: AppSettings {
        if let existing = settingsArray.first {
            return existing
        }
        let newSettings = AppSettings()
        modelContext.insert(newSettings)
        return newSettings
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                
                // bg
                backgroundColor
                    .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 16) {
                        if habits.isEmpty {
                            VStack(spacing: 20) {
                                Image(systemName: "chart.bar.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(Theme.from(string: settings.theme).primaryColor.opacity(0.5))
                                    .padding(.top, 60)
                                
                                Text("No Habits Yet!")
                                    .font(AppFont.from(string: settings.fontName).font(size: 24))
                                    .fontWeight(.semibold)
                                    .foregroundColor(Theme.from(string: settings.theme).primaryColor)
                                
                                Text("Tap the + button to create your first habit")
                                    .font(AppFont.from(string: settings.fontName).font(size: 16))
                                    .foregroundColor(Theme.from(string: settings.theme).primaryColor.opacity(0.7))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                        } else {
                            ForEach(habits) { habit in
                                HabitCardView(habit: habit, settings: settings)
                            }
                        }
                    }
                    .padding()
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
                                .background(Theme.from(string: settings.theme).primaryColor)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .padding()
                    }
                }
                
            }
            .navigationTitle("Habit Tracker")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView(settings: settings)) {
                        Image(systemName: "gear")
                            .foregroundColor(Theme.from(string: settings.theme).primaryColor)
                    }
                }
            }
            .sheet(isPresented: $showingCreateHabit) {
                CreateHabitView(settings: settings)
            }
        }
    }
}
