//  MultipleGridCardView.swift
//  trackit
//
//  Shows a grid of cells representing many sub-periods.
//  Daily   → month grid (7-wide, ~5 rows for days in the current month)
//  Weekly  → year grid  (9-wide for 52 weeks)
//  Monthly → year grid  (4-wide, 3 rows for 12 months)
//
//  Cell brightness = progress. The "today / current" cell is highlighted.

import SwiftUI

struct MultipleGridCardView: View {
    let habit: Habit
    let settings: AppSettings
    let currentDate: Date

    var body: some View {
        GeometryReader { geo in
            gridContent(availableHeight: geo.size.height)
        }
    }

    // MARK: - Grid dispatch

    @ViewBuilder
    private func gridContent(availableHeight: CGFloat) -> some View {
        switch habit.frequency {
        case .daily:
            dailyMonthGrid(availableHeight: availableHeight)
        case .weekly:
            weeklyYearGrid(availableHeight: availableHeight)
        case .monthly:
            monthlyYearGrid(availableHeight: availableHeight)
        default:
            // Yearly has no grid view — fallback to single
            EmptyView()
        }
    }

    // MARK: - Daily → Month grid (7 columns)

    private func dailyMonthGrid(availableHeight: CGFloat) -> some View {
        let daysInMonth = self.daysInCurrentMonth()
        let cols = 7
        let rows = (daysInMonth + cols - 1) / cols
        let spacing: CGFloat = 4
        let rowHeight = max(10, (availableHeight - (CGFloat(rows - 1) * spacing)) / CGFloat(rows))

        return VStack(spacing: 4) {
            ForEach(0..<rows, id: \.self) { row in
                HStack(spacing: 4) {
                    ForEach(0..<cols, id: \.self) { col in
                        let dayIndex = row * cols + col
                        if dayIndex < daysInMonth {
                            let date = Calendar.current.date(byAdding: .day, value: dayIndex, to: startOfMonth())!
                            let amount = habit.getCurrentAmount(for: date)
                            let isToday = Calendar.current.isDate(date, inSameDayAs: currentDate)

                            ProgressCell(
                                progress: progress(amount: amount, target: habit.targetAmount),
                                isCurrent: isToday,
                                cornerRadius: 3,
                                roundCorners: settings.roundCorners
                            )
                        } else {
                            Rectangle()
                                .fill(Color.clear)
                        }
                    }
                }
                .frame(height: rowHeight)
            }
        }
    }

    // MARK: - Weekly → Year grid (9 columns, 52 weeks)

    private func weeklyYearGrid(availableHeight: CGFloat) -> some View {
        let totalWeeks = 52
        let cols = 9
        let rows = (totalWeeks + cols - 1) / cols
        let spacing: CGFloat = 4
        let rowHeight = max(8, (availableHeight - (CGFloat(rows - 1) * spacing)) / CGFloat(rows))

        return VStack(spacing: 4) {
            ForEach(0..<rows, id: \.self) { row in
                HStack(spacing: 4) {
                    ForEach(0..<cols, id: \.self) { col in
                        let weekIndex = row * cols + col
                        if weekIndex < totalWeeks {
                            // weekIndex 0 = current week, 1 = last week, etc.
                            let weekStart = Calendar.current.date(byAdding: .weekOfYear, value: -weekIndex, to: startOfWeek())!
                            let amount = habit.getCurrentAmount(for: weekStart)
                            let isCurrent = weekIndex == 0

                            ProgressCell(
                                progress: progress(amount: amount, target: habit.targetAmount),
                                isCurrent: isCurrent,
                                cornerRadius: 2,
                                roundCorners: settings.roundCorners
                            )
                        } else {
                            Rectangle()
                                .fill(Color.clear)
                        }
                    }
                }
                .frame(height: rowHeight)
            }
        }
    }

    // MARK: - Monthly → Year grid (4 columns, 3 rows = 12 months)

    private func monthlyYearGrid(availableHeight: CGFloat) -> some View {
        let cols = 4
        let rows = 3
        let spacing: CGFloat = 4
        let rowHeight = max(14, (availableHeight - (CGFloat(rows - 1) * spacing)) / CGFloat(rows))

        return VStack(spacing: 4) {
            ForEach(0..<rows, id: \.self) { row in
                HStack(spacing: 4) {
                    ForEach(0..<cols, id: \.self) { col in
                        let monthOffset = row * cols + col   // 0 = current, 1 = last month, …
                        let monthDate = Calendar.current.date(byAdding: .month, value: -monthOffset, to: currentDate)!
                        let mStart = startOfMonth(for: monthDate)
                        let amount = habit.getCurrentAmount(for: mStart)
                        let target = habit.targetAmount
                        let isCurrent = monthOffset == 0

                        ProgressCell(
                            progress: progress(amount: amount, target: target),
                            isCurrent: isCurrent,
                            cornerRadius: 4,
                            roundCorners: settings.roundCorners
                        )
                    }
                }
                .frame(height: rowHeight)
            }
        }
    }

    // MARK: - Progress + Cell rendering

    private func progress(amount: Int, target: Int) -> CGFloat {
        guard target > 0 else { return 0 }
        if amount <= 0 { return 0 }
        let raw = CGFloat(amount) / CGFloat(target)
        // Small minimum so “non-zero” is always visible.
        return min(1.0, max(raw, 0.08))
    }

    private struct ProgressCell: View {
        let progress: CGFloat
        let isCurrent: Bool
        let cornerRadius: CGFloat
        let roundCorners: Bool

        var body: some View {
            let radius = roundCorners ? cornerRadius : 0
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(Color.white.opacity(0.18))

                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(Color.white.opacity(0.78))
                    .scaleEffect(x: 1, y: progress, anchor: .bottom)
            }
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(isCurrent ? Color.white.opacity(0.9) : Color.white.opacity(0.10), lineWidth: isCurrent ? 2 : 1)
                    .shadow(color: isCurrent ? Color.white.opacity(0.25) : Color.clear, radius: 5)
            )
            .animation(.spring(response: 0.25, dampingFraction: 0.85), value: progress)
        }
    }

    private func startOfWeek() -> Date {
        let cal = Calendar.current
        let weekday = cal.component(.weekday, from: currentDate)
        let daysFromMonday = (weekday + 5) % 7
        return cal.date(byAdding: .day, value: -daysFromMonday, to: currentDate)!
    }

    private func startOfMonth() -> Date {
        let cal = Calendar.current
        return cal.date(from: cal.dateComponents([.year, .month], from: currentDate))!
    }

    private func startOfMonth(for date: Date) -> Date {
        let cal = Calendar.current
        return cal.date(from: cal.dateComponents([.year, .month], from: date))!
    }

    private func daysInCurrentMonth() -> Int {
        Calendar.current.range(of: .day, in: .month, for: currentDate)!.count
    }

    private func daysInMonth(for date: Date) -> Int {
        Calendar.current.range(of: .day, in: .month, for: date)!.count
    }
}
