
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
        VStack(alignment: .leading, spacing: 10) {
            // Header sits ABOVE the card
            HStack(alignment: .firstTextBaseline) {
                Text(habit.name)
                    .font(AppFont.from(string: settings.fontName).font(size: 18))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                Spacer()

                Text(progressText)
                    .font(AppFont.from(string: settings.fontName).font(size: 18))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .monospacedDigit()
            }

            // Card is ONLY the graphic
            cardGraphic
                .padding(contentInset)
                .frame(height: 150)
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


