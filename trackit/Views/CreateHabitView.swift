//
//  CreateHabitView.swift
//  trackit
//
//  Created by Nick Glidden on 2/6/26.
//

import SwiftUI
import SwiftData

struct CreateHabitView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let habitToEdit: Habit?
    let settings: AppSettings
    
    @State private var name: String
    @State private var targetAmount: Int
    @State private var selectedFrequency: Frequency
    @State private var selectedDisplayMode: DisplayMode
    
    private var themeColor: Color {
        Theme.from(string: settings.theme).primaryColor
    }
    
    init(habitToEdit: Habit? = nil, settings: AppSettings) {
        self.habitToEdit = habitToEdit
        self.settings = settings
        
        _name = State(initialValue: habitToEdit?.name ?? "")
        _targetAmount = State(initialValue: habitToEdit?.targetAmount ?? 24)
        _selectedFrequency = State(initialValue: habitToEdit?.frequency ?? .daily)
        _selectedDisplayMode = State(initialValue: habitToEdit?.displayMode ?? .singleMonth)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                themeColor
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Content
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            // Name Section
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Name")
                                    .font(AppFont.from(string: settings.fontName).font(size: 14))
                                    .foregroundColor(.white.opacity(0.8))
                                
                                TextField("Go For A Run", text: $name)
                                    .font(AppFont.from(string: settings.fontName).font(size: 16))
                                    .padding()
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(settings.roundCorners ? 12 : 0)
                                    .foregroundColor(.white)
                            }
                            
                            // Amount Section
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Amount")
                                        .font(AppFont.from(string: settings.fontName).font(size: 14))
                                        .foregroundColor(.white.opacity(0.8))
                                    
                                    Spacer()
                                    
                                    Text("\(targetAmount)")
                                        .font(AppFont.from(string: settings.fontName).font(size: 20))
                                        .foregroundColor(.white)
                                }
                                
                                Slider(value: Binding(
                                    get: { Double(targetAmount) },
                                    set: { targetAmount = Int($0) }
                                ), in: 1...100, step: 1)
                                .accentColor(.white)
                            }
                            
                            // Frequency Section
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Frequency")
                                    .font(AppFont.from(string: settings.fontName).font(size: 14))
                                    .foregroundColor(.white.opacity(0.8))
                                
                                HStack(spacing: 12) {
                                    ForEach(Frequency.allCases, id: \.self) { frequency in
                                        Button(action: {
                                            selectedFrequency = frequency
                                        }) {
                                            Text(frequency.displayName)
                                                .font(AppFont.from(string: settings.fontName).font(size: 14))
                                                .padding(.horizontal, 20)
                                                .padding(.vertical, 12)
                                                .background(selectedFrequency == frequency ? Color.white : Color.white.opacity(0.2))
                                                .foregroundColor(selectedFrequency == frequency ? themeColor : .white)
                                                .cornerRadius(settings.roundCorners ? 20 : 0)
                                        }
                                    }
                                }
                            }
                            
                            // Display Section
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Display")
                                    .font(AppFont.from(string: settings.fontName).font(size: 14))
                                    .foregroundColor(.white.opacity(0.8))
                                
                                VStack(spacing: 8) {
                                    ForEach(DisplayMode.allCases, id: \.self) { mode in
                                        Button(action: {
                                            selectedDisplayMode = mode
                                        }) {
                                            HStack {
                                                Text(mode.displayName)
                                                    .font(AppFont.from(string: settings.fontName).font(size: 14))
                                                
                                                Spacer()
                                                
                                                if selectedDisplayMode == mode {
                                                    Image(systemName: "checkmark")
                                                }
                                            }
                                            .padding()
                                            .background(Color.white.opacity(selectedDisplayMode == mode ? 0.3 : 0.15))
                                            .cornerRadius(settings.roundCorners ? 12 : 0)
                                            .foregroundColor(.white)
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                    
                    // Bottom Buttons
                    VStack(spacing: 12) {
                        Button(action: createOrUpdateHabit) {
                            Text(habitToEdit == nil ? "Create Habit" : "Update Habit")
                                .font(AppFont.from(string: settings.fontName).font(size: 16))
                                .fontWeight(.semibold)
                                .foregroundColor(themeColor)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(settings.roundCorners ? 12 : 0)
                        }
                        .disabled(name.isEmpty)
                        .opacity(name.isEmpty ? 0.5 : 1.0)
                        
                        Button(action: { dismiss() }) {
                            Text("Cancel")
                                .font(AppFont.from(string: settings.fontName).font(size: 16))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(settings.roundCorners ? 12 : 0)
                        }
                    }
                    .padding()
                    .background(themeColor)
                }
            }
            .navigationTitle(habitToEdit == nil ? "Create Habit" : "Edit Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(themeColor, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
    
    private func createOrUpdateHabit() {
        if let habitToEdit = habitToEdit {
            habitToEdit.name = name
            habitToEdit.targetAmount = targetAmount
            habitToEdit.frequency = selectedFrequency
            habitToEdit.displayMode = selectedDisplayMode
        } else {
            let newHabit = Habit(
                name: name,
                targetAmount: targetAmount,
                frequency: selectedFrequency,
                displayMode: selectedDisplayMode
            )
            modelContext.insert(newHabit)
        }
        
        dismiss()
    }
}
