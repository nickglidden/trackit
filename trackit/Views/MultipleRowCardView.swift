//  MultipleRowCardView.swift
//  trackit
//
//  Shows a single horizontal row of pill bars, one per sub-period.
//  Daily  → 7 pills (Mon-Sun of the current week)
//  Weekly → N pills (configurable number of recent weeks)
//  Monthly → N pills (configurable number of recent months)
//  Yearly → N pills (configurable number of recent years)
//
//  Pills have constant height; fill increases left → right.

import SwiftUI

struct MultipleRowCardView: View {
    let habit: Habit
    let settings: AppSettings
    let currentDate: Date

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ForEach(bars.indices, id: \.self) { i in
                let item = bars[i]
                Bar(
                    progress: item.progress,
                    isCurrent: item.isCurrent,
                    roundCorners: settings.roundCorners,
                    targetAmount: habit.targetAmount
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }

    // MARK: - Bar data model

    private struct BarItem {
        let progress: CGFloat
        let isCurrent: Bool
    }

    private var bars: [BarItem] {
        switch habit.frequency {
        case .daily:
            return dailyBars()
        case .weekly:
            return weeklyBars()
        case .monthly:
            return monthlyBars()
        case .yearly:
            return yearlyBars()
        }
    }

    // MARK: - Daily → 7 day bars for current week

    private func dailyBars() -> [BarItem] {
        let cal = Calendar.current
        let weekday = cal.component(.weekday, from: currentDate)
        let daysFromMonday = (weekday + 5) % 7
        let monday = cal.date(byAdding: .day, value: -daysFromMonday, to: currentDate)!

        return (0..<7).map { offset in
            let date = cal.date(byAdding: .day, value: offset, to: monday)!
            let amount = habit.getCurrentAmount(for: date)
            let isCurrent = cal.isDate(date, inSameDayAs: currentDate)
            return BarItem(progress: progress(amount: amount, target: habit.targetAmount), isCurrent: isCurrent)
        }
    }

    // MARK: - Weekly → 4 week bars (most recent on the right - shows 1 month)

    private func weeklyBars() -> [BarItem] {
        let count = 4  // Show 4 weeks = 1 month
        let currentWeekStart = startOfWeek(for: currentDate)
        
        return (0..<count).reversed().map { offset in
            let weekStart = Calendar.current.date(byAdding: .weekOfYear, value: -offset, to: currentWeekStart)!
            let amount = habit.getCurrentAmount(for: weekStart)
            let isCurrent = Calendar.current.isDate(weekStart, equalTo: currentWeekStart, toGranularity: .weekOfYear)
            return BarItem(progress: progress(amount: amount, target: habit.targetAmount), isCurrent: isCurrent)
        }
    }

    // MARK: - Monthly → 3 month bars (shows 1 quarter)

    private func monthlyBars() -> [BarItem] {
        let count = 3  // Show 3 months = 1 quarter
        let currentMonthStart = startOfMonth(for: currentDate)
        
        return (0..<count).reversed().map { offset in
            let monthDate = Calendar.current.date(byAdding: .month, value: -offset, to: currentDate)!
            let monthStart = self.startOfMonth(for: monthDate)
            let amount = habit.getCurrentAmount(for: monthStart)
            let isCurrent = Calendar.current.isDate(monthStart, equalTo: currentMonthStart, toGranularity: .month)
            return BarItem(progress: progress(amount: amount, target: habit.targetAmount), isCurrent: isCurrent)
        }
    }

    // MARK: - Yearly → 5 year bars

    private func yearlyBars() -> [BarItem] {
        let count = 5  // Show 5 years
        let currentYearStart = startOfYear(for: currentDate)
        
        return (0..<count).reversed().map { offset in
            let yearDate = Calendar.current.date(byAdding: .year, value: -offset, to: currentDate)!
            let yearStart = self.startOfYear(for: yearDate)
            let amount = habit.getCurrentAmount(for: yearStart)
            let isCurrent = Calendar.current.isDate(yearStart, equalTo: currentYearStart, toGranularity: .year)
            return BarItem(progress: progress(amount: amount, target: habit.targetAmount), isCurrent: isCurrent)
        }
    }

    // MARK: - Visual progress mapping

    /// Ensures a small visible fill as soon as amount > 0.
    private func progress(amount: Int, target: Int) -> CGFloat {
        guard target > 0 else { return 0 }
        if amount <= 0 { return 0 }
        let raw = CGFloat(amount) / CGFloat(target)
        return min(1.0, max(raw, 0.08))
    }

    private struct Bar: View {
        let progress: CGFloat
        let isCurrent: Bool
        let roundCorners: Bool
        let targetAmount: Int

        var body: some View {
            GeometryReader { geo in
                let radius: CGFloat = roundCorners ? 10 : 0

                ZStack(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: radius, style: .continuous)
                        .fill(Color.white.opacity(0.22))

                    // Fill grows bottom → top (no crossfade)
                    RoundedRectangle(cornerRadius: radius, style: .continuous)
                        .fill(isCurrent ? Color.white.opacity(0.9) : Color.white.opacity(0.55))
                        .scaleEffect(x: 1, y: progress, anchor: .bottom)

                    // Step marks (like the single view)
                    tickMarks
                        .opacity(0.25)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: radius, style: .continuous)
                        .stroke(isCurrent ? Color.white.opacity(0.45) : Color.white.opacity(0.15), lineWidth: 2)
                        .shadow(color: isCurrent ? Color.white.opacity(0.25) : Color.clear, radius: 6)
                )
                .animation(.spring(response: 0.25, dampingFraction: 0.85), value: progress)
            }
        }

        private var tickMarks: some View {
            let divisions = max(2, min(targetAmount, 12))
            return VStack(spacing: 0) {
                ForEach(1..<divisions, id: \.self) { _ in
                    Spacer(minLength: 0)
                    Rectangle()
                        .fill(Color.white)
                        .frame(height: 1)
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 6)
            .allowsHitTesting(false)
        }
    }

    // MARK: - Date helpers

    private func startOfWeek(for date: Date) -> Date {
        let cal = Calendar.current
        let weekday = cal.component(.weekday, from: date)
        let daysFromMonday = (weekday + 5) % 7
        return cal.date(byAdding: .day, value: -daysFromMonday, to: date)!
    }

    private func startOfMonth(for date: Date) -> Date {
        let cal = Calendar.current
        return cal.date(from: cal.dateComponents([.year, .month], from: date))!
    }

    private func startOfYear(for date: Date) -> Date {
        let cal = Calendar.current
        return cal.date(from: cal.dateComponents([.year], from: date))!
    }
}
