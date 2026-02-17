
//  HabitCardView.swift
//  trackit
//
//  Main habit card. Dispatches to SingleCardView, MultipleRowCardView,
//  or MultipleGridCardView based on the habit's viewType.

import SwiftUI
import SwiftData

struct HabitCardView: View {

    let habit: Habit
    let settings: AppSettings

    @State private var currentDate = Date()
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Compact header row
            HStack(alignment: .center, spacing: 8) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(habit.name)
                        .font(AppFont.from(string: settings.fontName).font(size: 16))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .lineLimit(1)
                }

                Spacer()

                Text(progressText)
                    .font(AppFont.from(string: settings.fontName).font(size: 16))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .monospacedDigit()
            }
            
            // Metadata row (date + optional streak/completion)
            HStack(alignment: .center, spacing: 8) {
                Text(periodLabel)
                    .font(AppFont.from(string: settings.fontName).font(size: 11))
                    .foregroundColor(.white.opacity(0.6))
                    .lineLimit(1)
                
                Spacer(minLength: 0)
                
                // Inline streak/completion indicators
                HStack(spacing: 12) {
                    if settings.showStreaks {
                        HStack(spacing: 2) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.orange)
                            Text("\(habit.calculateStreak(for: currentDate))")
                                .font(AppFont.from(string: settings.fontName).font(size: 11))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    
                    if settings.showCompletionPercentage {
                        HStack(spacing: 2) {
                            Image(systemName: "percent")
                                .font(.system(size: 12))
                                .foregroundColor(.green)
                            Text("\(habit.completionPercentage(for: currentDate))%")
                                .font(AppFont.from(string: settings.fontName).font(size: 11))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                }
            }

            // Card graphic
            cardGraphic
                .padding(contentInset)
                .frame(height: 120)
                .frame(maxWidth: .infinity)
                .background(Theme.from(string: settings.theme).primaryColor)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: settings.roundCorners ? 16 : 0,
                        style: .continuous
                    )
                )
                .contentShape(
                    RoundedRectangle(
                        cornerRadius: settings.roundCorners ? 16 : 0,
                        style: .continuous
                    )
                )
                .onTapGesture {
                    incrementHabit()
                }
        }
    }

    private var contentInset: CGFloat {
        switch habit.viewType {
        case .single:
            return 0
        case .multipleRow, .multipleGrid:
            return 16
        }
    }

    @ViewBuilder
    private var cardGraphic: some View {
        switch habit.viewType {
        case .single:
            SingleCardView(habit: habit, settings: settings, currentDate: currentDate)
        case .multipleRow:
            MultipleRowCardView(habit: habit, settings: settings, currentDate: currentDate)
        case .multipleGrid:
            MultipleGridCardView(habit: habit, settings: settings, currentDate: currentDate)
        }
    }

    private var progressText: String {
        "\(currentPeriodAmount)/\(currentPeriodTarget) \(frequencySuffix)"
    }

    private var frequencySuffix: String {
        switch habit.frequency {
        case .daily: return "a day"
        case .weekly: return "a week"
        case .monthly: return "a month"
        case .yearly: return "a year"
        }
    }
    
    private var periodLabel: String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        switch habit.frequency {
        case .daily:
            formatter.dateFormat = "EEEE, MMM d"
            return "Today • \(formatter.string(from: currentDate))"
            
        case .weekly:
            let weekStart = weekStartDate()
            let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart)!
            formatter.dateFormat = "MMM d"
            let startStr = formatter.string(from: weekStart)
            let endStr = formatter.string(from: weekEnd)
            return "This week • \(startStr) – \(endStr)"
            
        case .monthly:
            formatter.dateFormat = "MMMM yyyy"
            return "This month • \(formatter.string(from: currentDate))"
            
        case .yearly:
            formatter.dateFormat = "yyyy"
            return "This year • \(formatter.string(from: currentDate))"
        }
    }
    
    private func weekStartDate() -> Date {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: currentDate)
        let daysFromMonday = (weekday + 5) % 7
        return calendar.date(byAdding: .day, value: -daysFromMonday, to: currentDate)!
    }

    private var currentPeriodAmount: Int {
        habit.getCurrentAmount(for: currentDate)
    }

    private var currentPeriodTarget: Int {
        habit.targetAmount
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


