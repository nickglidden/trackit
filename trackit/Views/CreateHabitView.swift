
//  CreateHabitView.swift
//  trackit

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
    @State private var selectedViewType: ViewType
    
    private var themeColor: Color {
        Theme.from(string: settings.theme).primaryColor
    }
    
    init(habitToEdit: Habit? = nil, settings: AppSettings) {
        self.habitToEdit = habitToEdit
        self.settings = settings
        
        _name = State(initialValue: habitToEdit?.name ?? "")
        _targetAmount = State(initialValue: habitToEdit?.targetAmount ?? 24)
        _selectedFrequency = State(initialValue: habitToEdit?.frequency ?? .daily)
        _selectedViewType = State(initialValue: habitToEdit?.viewType ?? .single)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                
                // bg
                themeColor
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            
                            // habit name
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
                            
                            // habit amount
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
                            
                            // habit frequency
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Frequency")
                                    .font(AppFont.from(string: settings.fontName).font(size: 14))
                                    .foregroundColor(.white.opacity(0.8))
                                
                                HStack(spacing: 12) {
                                    ForEach(Frequency.allCases, id: \.self) { frequency in
                                        Button(action: {
                                            selectedFrequency = frequency
                                            // Reset view type when frequency changes
                                            selectedViewType = .single
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
                            
                            // habit view type
                            VStack(alignment: .leading, spacing: 8) {
                                Text("View Type")
                                    .font(AppFont.from(string: settings.fontName).font(size: 14))
                                    .foregroundColor(.white.opacity(0.8))
                                
                                VStack(spacing: 8) {
                                    ForEach(availableViewTypes(), id: \.self) { viewType in
                                        Button(action: {
                                            selectedViewType = viewType
                                        }) {
                                            Text(viewType.displayName)
                                                .font(AppFont.from(string: settings.fontName).font(size: 14))
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 12)
                                                .background(selectedViewType == viewType ? Color.white : Color.white.opacity(0.2))
                                                .foregroundColor(selectedViewType == viewType ? themeColor : .white)
                                                .cornerRadius(settings.roundCorners ? 8 : 0)
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                    
                    // action buttons
                    VStack(spacing: 12) {
                        
                        // create/update
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
                        
                        // cancel
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
            habitToEdit.viewType = selectedViewType
        } else {
            let newHabit = Habit(
                name: name,
                targetAmount: targetAmount,
                frequency: selectedFrequency,
                viewType: selectedViewType
            )
            modelContext.insert(newHabit)
        }
        
        dismiss()
    }
    
    private func availableViewTypes() -> [ViewType] {
        ViewType.available(for: selectedFrequency)
    }
    
}
