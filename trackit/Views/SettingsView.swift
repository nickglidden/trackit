//  SettingsView.swift
//  trackit

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\Habit.sortOrder, order: .forward), SortDescriptor(\Habit.createdAt, order: .forward)])
    private var habits: [Habit]
    
    @Bindable var settings: AppSettings
    @State private var editingHabit: Habit?
    @State private var showingClearDataAlert = false
    @State private var showingExportSuccess = false
    
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
                    
                    // MARK: - Appearance Section
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
                                    Text("Color Theme")
                                        .font(AppFont.from(string: settings.fontName).font(size: 16))
                                        .foregroundColor(themeColor)
                                    Spacer()
                                    Text(Theme.from(string: settings.theme).rawValue)
                                        .font(AppFont.from(string: settings.fontName).font(size: 16))
                                        .foregroundColor(themeColor.opacity(0.7))
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
                                    Text("Font Family")
                                        .font(AppFont.from(string: settings.fontName).font(size: 16))
                                        .foregroundColor(themeColor)
                                    Spacer()
                                    Text(settings.fontName)
                                        .font(AppFont.from(string: settings.fontName).font(size: 16))
                                        .foregroundColor(themeColor.opacity(0.7))
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 14))
                                        .foregroundColor(themeColor)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 16)
                            }
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
                            
                            // high contrast mode
                            HStack {
                                Text("High Contrast Mode")
                                    .font(AppFont.from(string: settings.fontName).font(size: 16))
                                    .foregroundColor(themeColor)
                                Spacer()
                                Toggle("", isOn: $settings.highContrastMode)
                                    .labelsHidden()
                                    .tint(themeColor)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .background(cardColor)
                            .cornerRadius(settings.roundCorners ? 12 : 0)
                        }
                    }
                    
                    // MARK: - Behavior Section
                    VStack(alignment: .leading, spacing: 10) {
                        
                        Text("Behavior")
                            .font(AppFont.from(string: settings.fontName).font(size: 16))
                            .fontWeight(.semibold)
                            .foregroundColor(themeColor)
                            .padding(.leading, 16)
                        
                        VStack(spacing: 8) {
                            
                            // haptics toggle
                            HStack {
                                Text("Haptic Feedback")
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
                            
                            // show streaks
                            HStack {
                                Text("Show Streaks")
                                    .font(AppFont.from(string: settings.fontName).font(size: 16))
                                    .foregroundColor(themeColor)
                                Spacer()
                                Toggle("", isOn: $settings.showStreaks)
                                    .labelsHidden()
                                    .tint(themeColor)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .background(cardColor)
                            .cornerRadius(settings.roundCorners ? 12 : 0)
                            
                            // show completion percentage
                            HStack {
                                Text("Show Completion %")
                                    .font(AppFont.from(string: settings.fontName).font(size: 16))
                                    .foregroundColor(themeColor)
                                Spacer()
                                Toggle("", isOn: $settings.showCompletionPercentage)
                                    .labelsHidden()
                                    .tint(themeColor)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .background(cardColor)
                            .cornerRadius(settings.roundCorners ? 12 : 0)
                            
                            // reduce animations
                            HStack {
                                Text("Reduce Animations")
                                    .font(AppFont.from(string: settings.fontName).font(size: 16))
                                    .foregroundColor(themeColor)
                                Spacer()
                                Toggle("", isOn: $settings.reduceAnimations)
                                    .labelsHidden()
                                    .tint(themeColor)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .background(cardColor)
                            .cornerRadius(settings.roundCorners ? 12 : 0)
                        }
                    }
                    
                    // MARK: - Accessibility Section
                    VStack(alignment: .leading, spacing: 10) {
                        
                        Text("Accessibility")
                            .font(AppFont.from(string: settings.fontName).font(size: 16))
                            .fontWeight(.semibold)
                            .foregroundColor(themeColor)
                            .padding(.leading, 16)
                        
                        VStack(spacing: 8) {
                            
                            // dynamic type info
                            HStack(alignment: .top, spacing: 12) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Dynamic Type")
                                        .font(AppFont.from(string: settings.fontName).font(size: 16))
                                        .foregroundColor(themeColor)
                                    
                                    Text("Text size respects system settings")
                                        .font(AppFont.from(string: settings.fontName).font(size: 12))
                                        .foregroundColor(themeColor.opacity(0.6))
                                }
                                
                                Spacer()
                                
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.green)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .background(cardColor)
                            .cornerRadius(settings.roundCorners ? 12 : 0)
                        }
                    }
                    
                    // MARK: - Privacy & Security Section
                    VStack(alignment: .leading, spacing: 10) {
                        
                        Text("Privacy & Security")
                            .font(AppFont.from(string: settings.fontName).font(size: 16))
                            .fontWeight(.semibold)
                            .foregroundColor(themeColor)
                            .padding(.leading, 16)
                        
                        VStack(spacing: 8) {
                            
                            // app lock
                            HStack {
                                Text("App Lock (Face ID / Touch ID)")
                                    .font(AppFont.from(string: settings.fontName).font(size: 16))
                                    .foregroundColor(themeColor)
                                Spacer()
                                Toggle("", isOn: $settings.appLockEnabled)
                                    .labelsHidden()
                                    .tint(themeColor)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .background(cardColor)
                            .cornerRadius(settings.roundCorners ? 12 : 0)
                            
                            // export habits
                            Button(action: exportHabits) {
                                HStack {
                                    Image(systemName: "arrow.up.doc")
                                        .font(.system(size: 16))
                                        .foregroundColor(themeColor)
                                    
                                    Text("Export All Habits")
                                        .font(AppFont.from(string: settings.fontName).font(size: 16))
                                        .foregroundColor(themeColor)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14))
                                        .foregroundColor(themeColor.opacity(0.5))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 16)
                            }
                            .background(cardColor)
                            .cornerRadius(settings.roundCorners ? 12 : 0)
                            
                            // clear all data
                            Button(action: { showingClearDataAlert = true }) {
                                HStack {
                                    Image(systemName: "trash.circle")
                                        .font(.system(size: 16))
                                        .foregroundColor(.red.opacity(0.7))
                                    
                                    Text("Clear All Data")
                                        .font(AppFont.from(string: settings.fontName).font(size: 16))
                                        .foregroundColor(.red.opacity(0.7))
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14))
                                        .foregroundColor(.red.opacity(0.4))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 16)
                            }
                            .background(cardColor)
                            .cornerRadius(settings.roundCorners ? 12 : 0)
                        }
                    }
                    
                    // MARK: - Habits Section
                    if !habits.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            
                            Text("Your Habits (\(habits.count))")
                                .font(AppFont.from(string: settings.fontName).font(size: 16))
                                .fontWeight(.semibold)
                                .foregroundColor(themeColor)
                                .padding(.leading, 16)
                            
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
                    
                    // MARK: - Version Info
                    VStack(spacing: 4) {
                        Text("TrackIt!")
                            .font(AppFont.from(string: settings.fontName).font(size: 14))
                            .fontWeight(.semibold)
                            .foregroundColor(.white.opacity(0.6))
                        
                        Text(resolvedSettings.appVersion)
                            .font(AppFont.from(string: settings.fontName).font(size: 12))
                            .foregroundColor(.white.opacity(0.4))
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 20)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $editingHabit) { habit in
            CreateHabitView(habitToEdit: habit, settings: settings)
                .id(habit.id)
        }
        .alert("Clear All Data?", isPresented: $showingClearDataAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete All", role: .destructive) {
                clearAllData()
            }
        } message: {
            Text("This will permanently delete all habits and their history. This cannot be undone.")
        }
        .alert("Export Successful", isPresented: $showingExportSuccess) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your habits have been saved to Files/Downloads folder.")
        }
    }
    
    private func deleteHabit(_ habit: Habit) {
        withAnimation {
            modelContext.delete(habit)
        }
    }
    
    private func exportHabits() {
        // Create a JSON representation of all habits + entries
        var habitData: [[String: Any]] = []
        
        for habit in habits {
            var entries: [[String: Any]] = []
            for entry in habit.entries {
                entries.append([
                    "date": entry.date.ISO8601Format(),
                    "amount": entry.amount
                ])
            }
            
            habitData.append([
                "id": habit.id.uuidString,
                "name": habit.name,
                "frequency": habit.frequency.rawValue,
                "targetAmount": habit.targetAmount,
                "viewType": habit.viewType.rawValue,
                "createdAt": habit.createdAt.ISO8601Format(),
                "entries": entries
            ])
        }
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: habitData, options: [.prettyPrinted, .sortedKeys]),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            
            let fileName = "TrackIt_Export_\(Date().formatted(date: .numeric, time: .omitted)).json"
            if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileURL = documentDirectory.appendingPathComponent(fileName)
                try? jsonString.write(to: fileURL, atomically: true, encoding: .utf8)
                
                showingExportSuccess = true
            }
        }
    }
    
    private func clearAllData() {
        // Delete all habits (which cascades to delete entries)
        for habit in habits {
            modelContext.delete(habit)
        }
        
        try? modelContext.save()
    }
}
