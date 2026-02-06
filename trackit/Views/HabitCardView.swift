//
//  HabitCardView.swift
//  trackit
//
//  Created by Nick Glidden on 2/6/26.
//

import SwiftUI
import SwiftData

struct HabitCardView: View {
    @Environment(\.modelContext) private var modelContext
    let habit: Habit
    let settings: AppSettings
    @State private var currentDate = Date()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text(habit.name)
                    .font(AppFont.from(string: settings.fontName).font(size: 18))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            // Display content based on display mode
            switch habit.displayMode {
            case .day:
                DayView(habit: habit, settings: settings, currentDate: currentDate)
            case .week:
                WeekView(habit: habit, settings: settings, currentDate: currentDate)
            case .singleMonth:
                MonthView(habit: habit, settings: settings, currentDate: currentDate)
            case .yearly:
                YearView(habit: habit, settings: settings, currentDate: currentDate)
            }
        }
        .padding()
        .background(Theme.from(string: settings.theme).primaryColor)
        .cornerRadius(settings.roundCorners ? 16 : 0)
        .onTapGesture {
            incrementHabit()
        }
    }
    
    private func incrementHabit() {
        if settings.hapticsEnabled {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
        }
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            habit.incrementAmount(for: currentDate, in: modelContext)
        }
    }
}

// MARK: - Day View
struct DayView: View {
    let habit: Habit
    let settings: AppSettings
    let currentDate: Date
    
    var body: some View {
        VStack(spacing: 12) {
            // Top section: Large current day + darker second section
            HStack(spacing: 8) {
                // Current day large square
                Rectangle()
                    .fill(Color.white.opacity(0.9))
                    .frame(width: 165, height: 90)
                    .cornerRadius(8)
                
                // Darker rectangle
                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(height: 90)
                    .cornerRadius(8)
            }
            
            // Middle section: Week view with bars
            HStack(alignment: .bottom, spacing: 6) {
                ForEach(0..<7, id: \.self) { dayOffset in
                    let date = Calendar.current.date(byAdding: .day, value: -dayOffset, to: currentDate)!
                    let amount = habit.getCurrentAmount(for: date)
                    
                    Rectangle()
                        .fill(dayOffset == 0 ? Color.white.opacity(0.9) : Color.white.opacity(0.4))
                        .frame(height: barHeight(for: amount, maxHeight: 50))
                        .cornerRadius(4)
                }
            }
            .frame(height: 50)
            
            // Bottom section: Monthly grid
            VStack(spacing: 4) {
                ForEach(0..<4, id: \.self) { weekIndex in
                    HStack(spacing: 4) {
                        ForEach(0..<7, id: \.self) { dayIndex in
                            let offset = -((weekIndex + 1) * 7 + dayIndex)
                            let date = Calendar.current.date(byAdding: .day, value: offset, to: currentDate)!
                            let amount = habit.getCurrentAmount(for: date)
                            
                            Rectangle()
                                .fill(cellColor(for: amount))
                                .cornerRadius(3)
                        }
                    }
                    .frame(height: 16)
                }
            }
            
            // Label and count
            HStack {
                if settings.showLabels {
                    Text("← a day (day view)")
                        .font(AppFont.from(string: settings.fontName).font(size: 12))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                Text("\(habit.getCurrentAmount(for: currentDate))/\(habit.targetAmount)")
                    .font(AppFont.from(string: settings.fontName).font(size: CGFloat(settings.amountSize * 3)))
                    .foregroundColor(.white)
            }
        }
    }
    
    private func barHeight(for amount: Int, maxHeight: CGFloat) -> CGFloat {
        if amount == 0 { return maxHeight * 0.15 }
        let progress = CGFloat(amount) / CGFloat(habit.targetAmount)
        return max(maxHeight * 0.15, progress * maxHeight)
    }
    
    private func cellColor(for amount: Int) -> Color {
        if amount == 0 {
            return Color.white.opacity(0.2)
        }
        let progress = CGFloat(amount) / CGFloat(habit.targetAmount)
        return Color.white.opacity(0.3 + progress * 0.5)
    }
}

// MARK: - Week View
struct WeekView: View {
    let habit: Habit
    let settings: AppSettings
    let currentDate: Date
    
    var body: some View {
        VStack(spacing: 12) {
            // Top section: Large current week square + darker section
            HStack(spacing: 8) {
                // Current week large square
                Rectangle()
                    .fill(Color.white.opacity(0.9))
                    .frame(width: 165, height: 90)
                    .cornerRadius(8)
                
                // Darker rectangle
                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(height: 90)
                    .cornerRadius(8)
            }
            
            // Middle section: 4 week bars (last 4 weeks)
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(0..<4, id: \.self) { weekOffset in
                    let startOfWeek = Calendar.current.date(byAdding: .weekOfYear, value: -weekOffset, to: currentDate)!
                    let weekAmount = getWeekAmount(startDate: startOfWeek)
                    
                    Rectangle()
                        .fill(weekOffset == 0 ? Color.white.opacity(0.9) : Color.white.opacity(0.6))
                        .frame(width: 80, height: barHeight(for: weekAmount, maxHeight: 80))
                        .cornerRadius(6)
                }
            }
            .frame(height: 80)
            
            // Bottom section: Yearly weekly grid (52 weeks)
            VStack(spacing: 4) {
                ForEach(0..<4, id: \.self) { rowIndex in
                    HStack(spacing: 4) {
                        ForEach(0..<13, id: \.self) { colIndex in
                            let weekOffset = -(rowIndex * 13 + colIndex + 1)
                            let weekDate = Calendar.current.date(byAdding: .weekOfYear, value: weekOffset, to: currentDate)!
                            let weekAmount = getWeekAmount(startDate: weekDate)
                            
                            Rectangle()
                                .fill(weekCellColor(for: weekAmount))
                                .cornerRadius(2)
                        }
                    }
                    .frame(height: 12)
                }
            }
            
            // Label and count
            HStack {
                if settings.showLabels {
                    Text("← a week (week view)")
                        .font(AppFont.from(string: settings.fontName).font(size: 12))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                Text("\(habit.getCurrentAmount(for: currentDate))/\(habit.targetAmount)")
                    .font(AppFont.from(string: settings.fontName).font(size: CGFloat(settings.amountSize * 3)))
                    .foregroundColor(.white)
            }
        }
    }
    
    private func getWeekAmount(startDate: Date) -> Int {
        var total = 0
        for day in 0..<7 {
            if let date = Calendar.current.date(byAdding: .day, value: day, to: startDate) {
                total += habit.getCurrentAmount(for: date)
            }
        }
        return total
    }
    
    private func barHeight(for amount: Int, maxHeight: CGFloat) -> CGFloat {
        let maxPossible = habit.targetAmount * 7
        if amount == 0 { return maxHeight * 0.15 }
        let progress = CGFloat(amount) / CGFloat(maxPossible)
        return max(maxHeight * 0.15, progress * maxHeight)
    }
    
    private func weekCellColor(for amount: Int) -> Color {
        let maxPossible = habit.targetAmount * 7
        if amount == 0 {
            return Color.white.opacity(0.2)
        }
        let progress = CGFloat(amount) / CGFloat(maxPossible)
        return Color.white.opacity(0.3 + progress * 0.5)
    }
}

// MARK: - Month View
struct MonthView: View {
    let habit: Habit
    let settings: AppSettings
    let currentDate: Date
    
    var body: some View {
        VStack(spacing: 12) {
            // Top section: Large current month square + darker section
            HStack(spacing: 8) {
                // Current month large square
                Rectangle()
                    .fill(Color.white.opacity(0.9))
                    .frame(width: 165, height: 90)
                    .cornerRadius(8)
                
                // Darker rectangle
                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(height: 90)
                    .cornerRadius(8)
            }
            
            // Middle section: Thin bars for each day of the month
            HStack(alignment: .bottom, spacing: 2) {
                ForEach(0..<daysInCurrentMonth(), id: \.self) { dayIndex in
                    let date = startOfMonth().addingTimeInterval(Double(dayIndex) * 86400)
                    let amount = habit.getCurrentAmount(for: date)
                    
                    Rectangle()
                        .fill(isToday(date) ? Color.white.opacity(0.9) : Color.white.opacity(0.5))
                        .frame(width: max(2, CGFloat(340) / CGFloat(daysInCurrentMonth())), 
                               height: barHeight(for: amount, maxHeight: 60))
                        .cornerRadius(2)
                }
            }
            .frame(height: 60)
            
            // Bottom section: 3x4 grid of months
            VStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { rowIndex in
                    HStack(spacing: 4) {
                        ForEach(0..<4, id: \.self) { colIndex in
                            let monthOffset = -(rowIndex * 4 + colIndex + 1)
                            let monthDate = Calendar.current.date(byAdding: .month, value: monthOffset, to: currentDate)!
                            
                            Rectangle()
                                .fill(monthColor(for: monthDate))
                                .cornerRadius(4)
                        }
                    }
                    .frame(height: 22)
                }
            }
            
            // Label and count
            HStack {
                if settings.showLabels {
                    Text("← a month (month view)")
                        .font(AppFont.from(string: settings.fontName).font(size: 12))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                Text("\(habit.getCurrentAmount(for: currentDate))/\(habit.targetAmount)")
                    .font(AppFont.from(string: settings.fontName).font(size: CGFloat(settings.amountSize * 3)))
                    .foregroundColor(.white)
            }
        }
    }
    
    private func daysInCurrentMonth() -> Int {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: currentDate)!
        return range.count
    }
    
    private func startOfMonth() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: currentDate)
        return calendar.date(from: components)!
    }
    
    private func isToday(_ date: Date) -> Bool {
        Calendar.current.isDate(date, inSameDayAs: currentDate)
    }
    
    private func barHeight(for amount: Int, maxHeight: CGFloat) -> CGFloat {
        if amount == 0 { return maxHeight * 0.1 }
        let progress = CGFloat(amount) / CGFloat(habit.targetAmount)
        return max(maxHeight * 0.1, progress * maxHeight)
    }
    
    private func monthColor(for date: Date) -> Color {
        let calendar = Calendar.current
        let daysInMonth = calendar.range(of: .day, in: .month, for: date)!.count
        var totalAmount = 0
        var totalPossible = 0
        
        for day in 0..<daysInMonth {
            if let dayDate = calendar.date(byAdding: .day, value: day, to: startOfMonth(for: date)) {
                totalAmount += habit.getCurrentAmount(for: dayDate)
                totalPossible += habit.targetAmount
            }
        }
        
        if totalPossible == 0 { return Color.white.opacity(0.2) }
        let progress = CGFloat(totalAmount) / CGFloat(totalPossible)
        return Color.white.opacity(0.3 + progress * 0.5)
    }
    
    private func startOfMonth(for date: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: components)!
    }
}

// MARK: - Year View
struct YearView: View {
    let habit: Habit
    let settings: AppSettings
    let currentDate: Date
    
    var body: some View {
        VStack(spacing: 12) {
            // Top section: Large current year square + darker section
            HStack(spacing: 8) {
                // Current year large square
                Rectangle()
                    .fill(Color.white.opacity(0.9))
                    .frame(width: 165, height: 90)
                    .cornerRadius(8)
                
                // Darker rectangle
                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(height: 90)
                    .cornerRadius(8)
            }
            
            // Middle section: 10 year bars
            HStack(alignment: .bottom, spacing: 6) {
                ForEach(0..<10, id: \.self) { yearOffset in
                    let date = Calendar.current.date(byAdding: .year, value: -yearOffset, to: currentDate)!
                    
                    Rectangle()
                        .fill(yearOffset == 0 ? Color.white.opacity(0.9) : Color.white.opacity(0.5))
                        .frame(height: yearBarHeight(for: date, maxHeight: 70))
                        .cornerRadius(4)
                }
            }
            .frame(height: 70)
            
            // Bottom section: 3x4 yearly grid
            VStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { rowIndex in
                    HStack(spacing: 4) {
                        ForEach(0..<4, id: \.self) { colIndex in
                            let yearOffset = -(rowIndex * 4 + colIndex + 1)
                            let yearDate = Calendar.current.date(byAdding: .year, value: yearOffset, to: currentDate)!
                            
                            Rectangle()
                                .fill(yearColor(for: yearDate))
                                .cornerRadius(4)
                        }
                    }
                    .frame(height: 22)
                }
            }
            
            // Label and count
            HStack {
                if settings.showLabels {
                    Text("← a year (year view)")
                        .font(AppFont.from(string: settings.fontName).font(size: 12))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                Text("\(habit.getCurrentAmount(for: currentDate))/\(habit.targetAmount)")
                    .font(AppFont.from(string: settings.fontName).font(size: CGFloat(settings.amountSize * 3)))
                    .foregroundColor(.white)
            }
        }
    }
    
    private func yearBarHeight(for date: Date, maxHeight: CGFloat) -> CGFloat {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let startOfYear = calendar.date(from: DateComponents(year: year, month: 1, day: 1))!
        let daysInYear = calendar.range(of: .day, in: .year, for: date)!.count
        
        var totalAmount = 0
        var totalPossible = 0
        
        for day in 0..<daysInYear {
            if let dayDate = calendar.date(byAdding: .day, value: day, to: startOfYear) {
                totalAmount += habit.getCurrentAmount(for: dayDate)
                totalPossible += habit.targetAmount
            }
        }
        
        if totalPossible == 0 { return maxHeight * 0.1 }
        let progress = CGFloat(totalAmount) / CGFloat(totalPossible)
        return max(maxHeight * 0.1, progress * maxHeight)
    }
    
    private func yearColor(for date: Date) -> Color {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let startOfYear = calendar.date(from: DateComponents(year: year, month: 1, day: 1))!
        let daysInYear = calendar.range(of: .day, in: .year, for: date)!.count
        
        var totalAmount = 0
        var totalPossible = 0
        
        for day in 0..<daysInYear {
            if let dayDate = calendar.date(byAdding: .day, value: day, to: startOfYear) {
                totalAmount += habit.getCurrentAmount(for: dayDate)
                totalPossible += habit.targetAmount
            }
        }
        
        if totalPossible == 0 { return Color.white.opacity(0.2) }
        let progress = CGFloat(totalAmount) / CGFloat(totalPossible)
        return Color.white.opacity(0.3 + progress * 0.5)
    }
}
