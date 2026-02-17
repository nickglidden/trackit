
//  Habit.swift
//  trackit

import Foundation
import SwiftData
import SwiftUI

@Model
final class Habit {
    var id: UUID
    var name: String
    var targetAmount: Int
    var frequency: Frequency
    var viewType: ViewType
    var sortOrder: Int
    var createdAt: Date
    
    @Relationship(deleteRule: .cascade)
    var entries: [HabitEntry]
    
    init(name: String, targetAmount: Int, frequency: Frequency, viewType: ViewType = .single, sortOrder: Int = 0) {
        self.id = UUID()
        self.name = name
        self.targetAmount = targetAmount
        self.frequency = frequency
        self.viewType = viewType
        self.sortOrder = sortOrder
        self.createdAt = Date()
        self.entries = []
    }
    
    func getEntry(for date: Date) -> HabitEntry? {
        let calendar = Calendar.current
        let keyDate = periodStart(for: date)
        return entries.first { entry in
            calendar.isDate(entry.date, inSameDayAs: keyDate)
        }
    }
    
    func getCurrentAmount(for date: Date) -> Int {
        getEntry(for: date)?.amount ?? 0
    }
    
    func incrementAmount(for date: Date, in context: ModelContext) {
        let calendar = Calendar.current
        let keyDate = periodStart(for: date)
        let currentAmount = getCurrentAmount(for: keyDate)
        let newAmount = (currentAmount + 1) % (targetAmount + 1)
        
        if let entry = getEntry(for: keyDate) {
            entry.amount = newAmount
        } else {
            let newEntry = HabitEntry(date: calendar.startOfDay(for: keyDate), amount: newAmount)
            entries.append(newEntry)
            context.insert(newEntry)
        }
        
        try? context.save()
    }

    /// Returns the canonical date used to store/look up entries for this habit.
    /// - Daily: start of that day
    /// - Weekly: start of week (Monday)
    /// - Monthly: start of month
    /// - Yearly: start of year
    func periodStart(for date: Date) -> Date {
        let calendar = Calendar.current
        switch frequency {
        case .daily:
            return calendar.startOfDay(for: date)
        case .weekly:
            let weekday = calendar.component(.weekday, from: date)
            let daysFromMonday = (weekday + 5) % 7
            let monday = calendar.date(byAdding: .day, value: -daysFromMonday, to: date)!
            return calendar.startOfDay(for: monday)
        case .monthly:
            return calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
        case .yearly:
            return calendar.date(from: calendar.dateComponents([.year], from: date))!
        }
    }
}

enum Frequency: String, Codable, CaseIterable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case yearly = "Yearly"
    
    var displayName: String {
        self.rawValue
    }
}

enum ViewType: String, Codable, CaseIterable {
    case single = "Single"
    case multipleRow = "Multiple (Row)"
    case multipleGrid = "Multiple (Grid)"
    
    var displayName: String {
        self.rawValue
    }
    
    /// Context-aware display name based on frequency
    /// - Daily: Today / This Week / This Month
    /// - Weekly: This Week / This Month / This Year
    /// - Monthly: This Month / This Quarter / This Year
    /// - Yearly: This Year / Last 5 Years
    func displayName(for frequency: Frequency) -> String {
        switch (self, frequency) {
        case (.single, .daily):
            return "Today"
        case (.multipleRow, .daily):
            return "This Week"
        case (.multipleGrid, .daily):
            return "This Month"
            
        case (.single, .weekly):
            return "This Week"
        case (.multipleRow, .weekly):
            return "This Month"
        case (.multipleGrid, .weekly):
            return "This Year"
            
        case (.single, .monthly):
            return "This Month"
        case (.multipleRow, .monthly):
            return "This Quarter"
        case (.multipleGrid, .monthly):
            return "This Year"
            
        case (.single, .yearly):
            return "This Year"
        case (.multipleRow, .yearly):
            return "Last 5 Years"
        case (.multipleGrid, .yearly):
            return "This Year"
        }
    }
    
    /// Which view types are available for a given frequency
    static func available(for frequency: Frequency) -> [ViewType] {
        switch frequency {
        case .daily:
            // Single day, week of day bars, month grid of days
            return [.single, .multipleRow, .multipleGrid]
        case .weekly:
            // Single week, row of weeks, year grid of weeks
            return [.single, .multipleRow, .multipleGrid]
        case .monthly:
            // Single month, row of months, year grid of months
            return [.single, .multipleRow, .multipleGrid]
        case .yearly:
            // Single year, row of years (no grid — there's no larger grouping)
            return [.single, .multipleRow]
        }
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
