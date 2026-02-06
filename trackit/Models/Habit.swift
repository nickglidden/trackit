//
//  Habit.swift
//  trackit
//
//  Created by Nick Glidden on 2/6/26.
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class Habit {
    var id: UUID
    var name: String
    var targetAmount: Int
    var frequency: Frequency
    var displayMode: DisplayMode
    var createdAt: Date
    
    @Relationship(deleteRule: .cascade)
    var entries: [HabitEntry]
    
    init(name: String, targetAmount: Int, frequency: Frequency, displayMode: DisplayMode) {
        self.id = UUID()
        self.name = name
        self.targetAmount = targetAmount
        self.frequency = frequency
        self.displayMode = displayMode
        self.createdAt = Date()
        self.entries = []
    }
    
    func getEntry(for date: Date) -> HabitEntry? {
        let calendar = Calendar.current
        return entries.first { entry in
            calendar.isDate(entry.date, inSameDayAs: date)
        }
    }
    
    func getCurrentAmount(for date: Date) -> Int {
        getEntry(for: date)?.amount ?? 0
    }
    
    func incrementAmount(for date: Date, in context: ModelContext) {
        let calendar = Calendar.current
        let currentAmount = getCurrentAmount(for: date)
        let newAmount = (currentAmount + 1) % (targetAmount + 1)
        
        if let entry = getEntry(for: date) {
            entry.amount = newAmount
        } else {
            let newEntry = HabitEntry(date: calendar.startOfDay(for: date), amount: newAmount)
            entries.append(newEntry)
            context.insert(newEntry)
        }
        
        try? context.save()
    }
}

enum Frequency: String, Codable, CaseIterable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    
    var displayName: String {
        self.rawValue
    }
}

enum DisplayMode: String, Codable, CaseIterable {
    case singleMonth = "Single Month"
    case yearly = "Yearly"
    case week = "Week"
    case day = "Day"
    
    var displayName: String {
        self.rawValue
    }
}

@Model
final class HabitEntry {
    var id: UUID
    var date: Date
    var amount: Int
    
    init(date: Date, amount: Int) {
        self.id = UUID()
        self.date = date
        self.amount = amount
    }
}
