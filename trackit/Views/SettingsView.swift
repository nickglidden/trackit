//
//  SettingsView.swift
//  trackit
//
//  Created by Nick Glidden on 2/6/26.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var habits: [Habit]
    
    @Bindable var settings: AppSettings
    @State private var editingHabit: Habit?
    @State private var showingEditHabit = false
    
    private var themeColor: Color {
        Theme.from(string: settings.theme).primaryColor
    }
    
    private var backgroundColor: Color {
        Theme.from(string: settings.theme).backgroundColor
    }
    
    private var cardColor: Color {
        Color.white.opacity(0.15)
    }
    
    var body: some View {
        ZStack {
            // Background matches theme
            backgroundColor
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16) {
                    // Appearance Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Appearance")
                            .font(AppFont.from(string: settings.fontName).font(size: 16))
                            .fontWeight(.semibold)
                            .foregroundColor(themeColor)
                            .padding(.leading, 16)
                        
                        VStack(spacing: 8) {
                            // Theme
                            Menu {
                                ForEach(Theme.allCases, id: \.self) { theme in
                                    Button(action: {
                                        withAnimation {
                                            settings.theme = theme.rawValue.lowercased().replacingOccurrences(of: " ", with: "")
                                        }
                                    }) {
                                        HStack {
                                            Text(theme.rawValue)
                                            if Theme.from(string: settings.theme) == theme {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(Theme.from(string: settings.theme).rawValue)
                                        .font(AppFont.from(string: settings.fontName).font(size: 16))
                                        .foregroundColor(themeColor)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 14))
                                        .foregroundColor(themeColor)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 16)
                            }
                            .background(cardColor)
                            .cornerRadius(settings.roundCorners ? 12 : 0)
                            
                            // Font
                            Menu {
                                ForEach(AppFont.allCases, id: \.self) { font in
                                    Button(action: {
                                        settings.fontName = font.rawValue
                                    }) {
                                        HStack {
                                            Text(font.rawValue)
                                            if AppFont.from(string: settings.fontName) == font {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(settings.fontName)
                                        .font(AppFont.from(string: settings.fontName).font(size: 16))
                                        .foregroundColor(themeColor)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 14))
                                        .foregroundColor(themeColor)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 16)
                            }
                            .background(cardColor)
                            .cornerRadius(settings.roundCorners ? 12 : 0)
                            
                            // Show Labels Toggle
                            HStack {
                                Text("Show Labels")
                                    .font(AppFont.from(string: settings.fontName).font(size: 16))
                                    .foregroundColor(themeColor)
                                Spacer()
                                Toggle("", isOn: $settings.showLabels)
                                    .labelsHidden()
                                    .tint(themeColor)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .background(cardColor)
                            .cornerRadius(settings.roundCorners ? 12 : 0)
                            
                            // Haptics Toggle
                            HStack {
                                Text("Haptics")
                                    .font(AppFont.from(string: settings.fontName).font(size: 16))
                                    .foregroundColor(themeColor)
                                Spacer()
                                Toggle("", isOn: $settings.hapticsEnabled)
                                    .labelsHidden()
                                    .tint(themeColor)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .background(cardColor)
                            .cornerRadius(settings.roundCorners ? 12 : 0)
                            
                            // Round Corners Toggle
                            HStack {
                                Text("Round Corners")
                                    .font(AppFont.from(string: settings.fontName).font(size: 16))
                                    .foregroundColor(themeColor)
                                Spacer()
                                Toggle("", isOn: $settings.roundCorners)
                                    .labelsHidden()
                                    .tint(themeColor)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .background(cardColor)
                            .cornerRadius(settings.roundCorners ? 12 : 0)
                            
                            // Amount Size
                            VStack(spacing: 10) {
                                HStack {
                                    Text("Amount Size")
                                        .font(AppFont.from(string: settings.fontName).font(size: 16))
                                        .foregroundColor(themeColor)
                                    Spacer()
                                    Text(String(format: "%.0fpx", settings.amountSize))
                                        .font(AppFont.from(string: settings.fontName).font(size: 16))
                                        .foregroundColor(themeColor.opacity(0.7))
                                }
                                
                                Slider(value: $settings.amountSize, in: 3...10, step: 0.5)
                                    .tint(themeColor)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .background(cardColor)
                            .cornerRadius(settings.roundCorners ? 12 : 0)
                        }
                    }
                    
                    // Habits Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Habits")
                            .font(AppFont.from(string: settings.fontName).font(size: 16))
                            .fontWeight(.semibold)
                            .foregroundColor(themeColor)
                            .padding(.leading, 16)
                        
                        if habits.isEmpty {
                            Text("No habits created yet")
                                .font(AppFont.from(string: settings.fontName).font(size: 16))
                                .foregroundColor(themeColor.opacity(0.6))
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(cardColor)
                                .cornerRadius(settings.roundCorners ? 12 : 0)
                        } else {
                            VStack(spacing: 8) {
                                ForEach(habits) { habit in
                                    HStack(spacing: 12) {
                                        Circle()
                                            .fill(themeColor)
                                            .frame(width: 16, height: 16)
                                        
                                        Text(habit.name)
                                            .font(AppFont.from(string: settings.fontName).font(size: 16))
                                            .foregroundColor(themeColor)
                                        
                                        Spacer()
                                        
                                        Button(action: {
                                            editingHabit = habit
                                            showingEditHabit = true
                                        }) {
                                            Image(systemName: "pencil")
                                                .font(.system(size: 16))
                                                .foregroundColor(themeColor.opacity(0.6))
                                        }
                                        .padding(.trailing, 4)
                                        
                                        Button(action: {
                                            deleteHabit(habit)
                                        }) {
                                            Image(systemName: "trash")
                                                .font(.system(size: 16))
                                                .foregroundColor(.red.opacity(0.6))
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 16)
                                    .background(cardColor)
                                    .cornerRadius(settings.roundCorners ? 12 : 0)
                                }
                            }
                        }
                    }
                    
                    // Version Info
                    Text("Version 1.2.1")
                        .font(AppFont.from(string: settings.fontName).font(size: 12))
                        .foregroundColor(.white.opacity(0.4))
                        .padding(.top, 40)
                        .padding(.bottom, 20)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingEditHabit) {
            if let habit = editingHabit {
                CreateHabitView(habitToEdit: habit, settings: settings)
            }
        }
    }
    
    private func deleteHabit(_ habit: Habit) {
        withAnimation {
            modelContext.delete(habit)
        }
    }
}
