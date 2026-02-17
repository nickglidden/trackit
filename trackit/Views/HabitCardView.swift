//  HabitCardView.swift
//  trackit
//  Main habit card. Dispatches to SingleCardView, MultipleRowCardView,
//  or MultipleGridCardView based on the habit's viewType.
//  Now with period navigation, swipe gestures, and haptic feedback.

import SwiftUI
import SwiftData

struct HabitCardView: View {

    let habit: Habit
    let settings: AppSettings

    @State private var displayDate = Date()
    @State private var dragOffset: CGFloat = 0
    @State private var isSwipingToNavigate = false
    @State private var lastHapticTime: Date = Date()
    
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with habit name and progress
            headerSection
            
            // Card graphic (main visualization)
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
                    if !isSwipingToNavigate {
                        incrementHabit()
                    }
                }
            
            // Period navigation footer
            periodNavigationFooter
        }
        .gesture(
            LongPressGesture(minimumDuration: 0.5)
                .onEnded { _ in
                    isSwipingToNavigate = true
                }
                .simultaneously(with:
                    DragGesture()
                        .onChanged { value in
                            if isSwipingToNavigate {
                                dragOffset = value.translation.width
                                handleSwipeNavigation(translation: value.translation.width)
                            }
                        }
                        .onEnded { _ in
                            isSwipingToNavigate = false
                            dragOffset = 0
                        }
                )
        )
    }

    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(habit.name)
                        .font(AppFont.from(string: settings.fontName).font(size: 22))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text(periodLabel)
                        .font(AppFont.from(string: settings.fontName).font(size: 13))
                        .foregroundColor(.white.opacity(0.6))
                }

                Spacer()

                Text(progressText)
                    .font(AppFont.from(string: settings.fontName).font(size: 22))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .monospacedDigit()
            }
            
            // Show streak, completion %, and other stats
            if settings.showStreaks || settings.showCompletionPercentage {
                HStack(spacing: 20) {
                    if settings.showStreaks {
                        HStack(spacing: 4) {
                            Image(systemName: "droplet.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.cyan)
                            Text("\(habit.calculateStreak(for: displayDate))")
                                .font(AppFont.from(string: settings.fontName).font(size: 13))
                                .foregroundColor(.white.opacity(0.8))
                                .monospacedDigit()
                        }
                    }
                    
                    if settings.showCompletionPercentage {
                        HStack(spacing: 4) {
                            Image(systemName: "droplet.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.cyan)
                            Text("\(habit.completionPercentage(for: displayDate))%")
                                .font(AppFont.from(string: settings.fontName).font(size: 13))
                                .foregroundColor(.white.opacity(0.8))
                                .monospacedDigit()
                        }
                    }
                }
            }
        }
    }

    // MARK: - Period Navigation Footer
    
    private var periodNavigationFooter: some View {
        HStack(spacing: 16) {
            // Prev button
            Button(action: goToPreviousPeriod) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Prev")
                        .font(AppFont.from(string: settings.fontName).font(size: 14))
                }
                .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            // Center: Period indicator dots or Jump to Today
            if isViewingToday {
                HStack(spacing: 6) {
                    ForEach(0..<periodIndicatorCount, id: \.self) { index in
                        Circle()
                            .fill(index == currentPeriodIndex ? .white : .white.opacity(0.3))
                            .frame(width: 6, height: 6)
                    }
                }
            } else {
                Button(action: jumpToToday) {
                    HStack(spacing: 4) {
                        Text("Jump to Today")
                            .font(AppFont.from(string: settings.fontName).font(size: 13))
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(settings.roundCorners ? 8 : 0)
                }
            }
            
            Spacer()
            
            // Next button
            Button(action: goToNextPeriod) {
                HStack(spacing: 4) {
                    Text("Next")
                        .font(AppFont.from(string: settings.fontName).font(size: 14))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding(.horizontal, 4)
        .padding(.top, 4)
    }

    // MARK: - Card Graphic
    
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
            SingleCardView(habit: habit, settings: settings, currentDate: displayDate)
        case .multipleRow:
            MultipleRowCardView(habit: habit, settings: settings, currentDate: displayDate)
        case .multipleGrid:
            MultipleGridCardView(habit: habit, settings: settings, currentDate: displayDate)
        }
    }

    // MARK: - Text Helpers
    
    private var progressText: String {
        "\(currentPeriodAmount)/\(currentPeriodTarget)"
    }

    private var periodLabel: String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        switch habit.frequency {
        case .daily:
            if isViewingToday {
                formatter.dateFormat = "EEEE, MMM d"
                return "Today • \(formatter.string(from: displayDate))"
            } else {
                formatter.dateFormat = "EEEE, MMM d"
                return formatter.string(from: displayDate)
            }
            
        case .weekly:
            let weekStart = weekStartDate()
            let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart)!
            formatter.dateFormat = "MMM d"
            let startStr = formatter.string(from: weekStart)
            let endStr = formatter.string(from: weekEnd)
            
            if isViewingToday {
                return "This Week • \(startStr) – \(endStr)"
            } else {
                return "\(startStr) – \(endStr)"
            }
            
        case .monthly:
            formatter.dateFormat = "MMMM, yyyy"
            if isViewingToday {
                return "This Month • \(formatter.string(from: displayDate))"
            } else {
                return formatter.string(from: displayDate)
            }
            
        case .yearly:
            formatter.dateFormat = "yyyy"
            if isViewingToday {
                return "This Year • \(formatter.string(from: displayDate))"
            } else {
                return formatter.string(from: displayDate)
            }
        }
    }
    
    private func weekStartDate() -> Date {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: displayDate)
        let daysFromMonday = (weekday + 5) % 7
        return calendar.date(byAdding: .day, value: -daysFromMonday, to: displayDate)!
    }

    private var currentPeriodAmount: Int {
        habit.getCurrentAmount(for: displayDate)
    }

    private var currentPeriodTarget: Int {
        habit.targetAmount
    }
    
    private var isViewingToday: Bool {
        Calendar.current.isDate(displayDate, inSameDayAs: Date())
    }
    
    private var periodIndicatorCount: Int {
        switch habit.frequency {
        case .daily: return 7  // Show 7 days (week)
        case .weekly: return 4  // Show 4 weeks
        case .monthly: return 3  // Show 3 months
        case .yearly: return 5  // Show 5 years
        }
    }
    
    private var currentPeriodIndex: Int {
        // Calculate where we are in the indicator sequence
        let calendar = Calendar.current
        switch habit.frequency {
        case .daily:
            let weekStart = weekStartDate()
            if let days = calendar.dateComponents([.day], from: weekStart, to: displayDate).day {
                return min(days, 6)
            }
            return 0
        case .weekly:
            // Current week is at index 3 (most recent)
            return 3
        case .monthly:
            // Current month is at index 2 (most recent)
            return 2
        case .yearly:
            // Current year is at index 4 (most recent)
            return 4
        }
    }

    // MARK: - Navigation Actions
    
    private func goToPreviousPeriod() {
        withAnimation(.easeInOut(duration: 0.2)) {
            switch habit.frequency {
            case .daily:
                displayDate = Calendar.current.date(byAdding: .day, value: -1, to: displayDate)!
            case .weekly:
                displayDate = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: displayDate)!
            case .monthly:
                displayDate = Calendar.current.date(byAdding: .month, value: -1, to: displayDate)!
            case .yearly:
                displayDate = Calendar.current.date(byAdding: .year, value: -1, to: displayDate)!
            }
            triggerHaptic()
        }
    }
    
    private func goToNextPeriod() {
        withAnimation(.easeInOut(duration: 0.2)) {
            switch habit.frequency {
            case .daily:
                displayDate = Calendar.current.date(byAdding: .day, value: 1, to: displayDate)!
            case .weekly:
                displayDate = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: displayDate)!
            case .monthly:
                displayDate = Calendar.current.date(byAdding: .month, value: 1, to: displayDate)!
            case .yearly:
                displayDate = Calendar.current.date(byAdding: .year, value: 1, to: displayDate)!
            }
            triggerHaptic()
        }
    }
    
    private func jumpToToday() {
        withAnimation(.easeInOut(duration: 0.3)) {
            displayDate = Date()
        }
        triggerHaptic()
    }
    
    private func handleSwipeNavigation(translation: CGFloat) {
        // Threshold for period advancement
        let threshold: CGFloat = 40
        let now = Date()
        
        // Only trigger haptic every 100ms to avoid overwhelming haptics
        if now.timeIntervalSince(lastHapticTime) > 0.1 {
            let percentThreshold = abs(translation) / threshold
            
            if percentThreshold > 1.0 {
                triggerHaptic()
                lastHapticTime = now
                
                // Determine swipe direction and advance period(s)
                if translation < -threshold {
                    // Swiped left (towards future/next)
                    goToNextPeriod()
                } else if translation > threshold {
                    // Swiped right (towards past/previous)
                    goToPreviousPeriod()
                }
            }
        }
    }
    
    private func triggerHaptic() {
        if settings.hapticsEnabled {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
        }
    }

    private func incrementHabit() {
        // Only allow incrementing if viewing today
        guard isViewingToday else { return }
        
        if settings.hapticsEnabled {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
        }

        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            habit.incrementAmount(for: displayDate, in: modelContext)
        }
    }
}
