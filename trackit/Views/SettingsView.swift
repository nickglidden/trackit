
//  SettingsView.swift
//  trackit

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var habits: [Habit]
    
    @Bindable var settings: AppSettings
    @State private var editingHabit: Habit?
    
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
            
            // bg
            backgroundColor
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16) {
                    
                    // appearance Section
                    VStack(alignment: .leading, spacing: 10) {
                        
                        Text("Appearance")
                            .font(AppFont.from(string: settings.fontName).font(size: 16))
                            .fontWeight(.semibold)
                            .foregroundColor(themeColor)
                            .padding(.leading, 16)
                        
                        VStack(spacing: 8) {
                            
                            // theme
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
                            
                            // font family
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
                            
                            // show labels toggle
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
                            
                            // haptics toggle
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
                            
                            // round corners toggle
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
                            
                            // amount size
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
                    
                    // habits section
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
                    
                    // version info
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
        .sheet(item: $editingHabit) { habit in
            CreateHabitView(habitToEdit: habit, settings: settings)
                .id(habit.id)
        }
    }
    
    private func deleteHabit(_ habit: Habit) {
        withAnimation {
            modelContext.delete(habit)
        }
    }
    
}
