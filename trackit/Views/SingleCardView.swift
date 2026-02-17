//  SingleCardView.swift
//  trackit
//
//  Shows the current period as a single large element.
//  The left portion fills with white as progress increases (left → right).
//  Works for any frequency: day, week, month, or year.

import SwiftUI

struct SingleCardView: View {
    let habit: Habit
    let settings: AppSettings
    let currentDate: Date

    var body: some View {
        GeometryReader { geo in
            let filledWidth = geo.size.width * progress
            let radius: CGFloat = settings.roundCorners ? 16 : 0

            ZStack(alignment: .leading) {

                // no need for a 'cell background color' since
                // the single cards 'cell' is the whole card

                tickMarks
                    .opacity(0.33)

                // filled portion
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(Color.white)
                    .frame(width: filledWidth)
            }
            .overlay(
                // highlight the "current" period with a brighter border and subtle glow
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(Color.white.opacity(0.5), lineWidth: 2)
            )
        }
    }

    // MARK: - Computed helpers

    /// Current accumulated amount for this period
    private var currentAmount: Int {
        habit.getCurrentAmount(for: currentDate)
    }

    /// Target for the whole period
    private var target: Int {
        habit.targetAmount
    }

    private var progress: CGFloat {
        guard target > 0 else { return 0 }
        return min(1.0, CGFloat(currentAmount) / CGFloat(target))
    }

    private var tickMarks: some View {
        let divisions = tickDivisions
        return HStack(spacing: 0) {
            ForEach(1..<divisions, id: \.self) { _ in
                Spacer(minLength: 0)
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 1)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 10)
    }

    private var tickDivisions: Int {
        // Clamp so large targets don't turn into a picket fence.
        max(2, min(habit.targetAmount, 12))
    }
}
