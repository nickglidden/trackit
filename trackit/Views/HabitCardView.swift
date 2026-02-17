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
    @State private var isDragging = false
    @State private var dragStartLocation: CGFloat = 0
    @State private var accumulatedOffset: CGFloat = 0
    @State private var lastNavigationTime: Date = Date.distantPast
    
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
                    if !isDragging {
                        incrementHabit()
                    }
                }
                .opacity(isDragging ? 0.8 : 1.0)
                .scaleEffect(isDragging ? 0.98 : 1.0)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            handleDragChanged(value)
                        }
                        .onEnded { value in
                            handleDragEnded()
                        }
                )
            
            // Period navigation footer
            periodNavigationFooter
        }
    }

    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Row 1: Habit name and progress
            HStack(alignment: .firstTextBaseline) {
                Text(habit.name)
                    .font(AppFont.from(string: settings.fontName).font(size: 24))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Spacer()

                Text(progressText)
                    .font(AppFont.from(string: settings.fontName).font(size: 28))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .monospacedDigit()
            }
            
            // Row 2: Period label on left, stats on right
            HStack(alignment: .center) {
                Text(periodLabel)
                    .font(AppFont.from(string: settings.fontName).font(size: 13))
                    .foregroundColor(.primary.opacity(0.6))
                
                Spacer()
                
                // Show streak, completion %, and other stats
                if settings.showStreaks || settings.showCompletionPercentage {
                    HStack(spacing: 12) {
                        if settings.showStreaks {
                            HStack(spacing: 4) {
                                Image(systemName: "flame.fill")
                                    .font(.system(size: 13))
                                    .foregroundColor(Theme.from(string: settings.theme).primaryColor)
                                Text("\(habit.calculateStreak(for: displayDate))")
                                    .font(AppFont.from(string: settings.fontName).font(size: 14))
                                    .fontWeight(.medium)
                                    .foregroundColor(Theme.from(string: settings.theme).primaryColor)
                                    .monospacedDigit()
                            }
                        }
                        
                        if settings.showCompletionPercentage {
                            HStack(spacing: 4) {
                                Image(systemName: "drop.fill")
                                    .font(.system(size: 13))
                                    .foregroundColor(Theme.from(string: settings.theme).primaryColor)
                                Text("\(habit.completionPercentage(for: displayDate))%")
                                    .font(AppFont.from(string: settings.fontName).font(size: 14))
                                    .fontWeight(.medium)
                                    .foregroundColor(Theme.from(string: settings.theme).primaryColor)
                                    .monospacedDigit()
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Period Navigation Footer
    
    private var periodNavigationFooter: some View {
        HStack(spacing: 8) {
            // Prev button
            Button(action: goToPreviousPeriod) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 12, weight: .semibold))
                    Text("Prev")
                        .font(AppFont.from(string: settings.fontName).font(size: 13))
                        .fontWeight(.medium)
                }
                .foregroundColor(Theme.from(string: settings.theme).primaryColor.opacity(0.6))
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            // Center: Period indicator dots or Jump to Today
            if isViewingToday {
                HStack(spacing: 6) {
                    ForEach(0..<7, id: \.self) { index in
                        Circle()
                            .fill(index == 3 ? Theme.from(string: settings.theme).primaryColor : Theme.from(string: settings.theme).primaryColor.opacity(0.3))
                            .frame(width: 6, height: 6)
                    }
                }
                .transition(.opacity)
            } else {
                Button(action: jumpToToday) {
                    Text("Jump to Today")
                        .font(AppFont.from(string: settings.fontName).font(size: 13))
                        .fontWeight(.semibold)
                        .foregroundColor(Theme.from(string: settings.theme).primaryColor)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(Theme.from(string: settings.theme).primaryColor.opacity(0.15))
                        .cornerRadius(settings.roundCorners ? 12 : 4)
                }
                .buttonStyle(.plain)
                .transition(.opacity.combined(with: .scale))
            }
            
            Spacer()
            
            // Next button
            Button(action: goToNextPeriod) {
                HStack(spacing: 4) {
                    Text("Next")
                        .font(AppFont.from(string: settings.fontName).font(size: 13))
                        .fontWeight(.medium)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(Theme.from(string: settings.theme).primaryColor.opacity(0.6))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 8)
        .padding(.top, 8)
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
        withAnimation(.easeInOut(duration: 0.3)) {
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
            triggerHaptic(.light)
        }
    }
    
    private func goToNextPeriod() {
        withAnimation(.easeInOut(duration: 0.3)) {
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
            triggerHaptic(.light)
        }
    }
    
    private func jumpToToday() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            displayDate = Date()
        }
        triggerHaptic(.medium)
    }
    
    // MARK: - Gesture Handling
    
    private func handleDragChanged(_ value: DragGesture.Value) {
        let translation = value.translation.width
        
        // Only start drag navigation if we've moved a certain distance
        // This allows taps to still work
        if !isDragging && abs(translation) > 20 {
            isDragging = true
            accumulatedOffset = 0
            dragStartLocation = value.location.x
            triggerHaptic(.medium)
        }
        
        // Handle continuous drag navigation
        if isDragging {
            let currentOffset = translation
            let deltaOffset = currentOffset - accumulatedOffset
            
            // Calculate speed based on distance from start
            let distanceFromStart = abs(value.location.x - dragStartLocation)
            
            // Progressive speed: starts slow, gets faster the further you drag
            // Base threshold is 120 points per period, scales down as you drag further
            let baseThreshold: CGFloat = 120
            let speedMultiplier = min(1.0 + (distanceFromStart / 250), 2.5) // Max 2.5x speed
            let adjustedThreshold = baseThreshold / speedMultiplier
            
            // Check if we should navigate to next/prev period
            if abs(deltaOffset) >= adjustedThreshold {
                let now = Date()
                // Minimum time between navigations based on speed
                // Slower at first, faster as you keep swiping
                let minInterval = max(0.08, 0.20 / speedMultiplier)
                
                if now.timeIntervalSince(lastNavigationTime) >= minInterval {
                    if deltaOffset < 0 {
                        // Swipe left -> next period (forward in time)
                        goToNextPeriod()
                    } else {
                        // Swipe right -> previous period (back in time)
                        goToPreviousPeriod()
                    }
                    
                    accumulatedOffset = currentOffset
                    lastNavigationTime = now
                }
            }
        }
    }
    
    private func handleDragEnded() {
        if isDragging {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isDragging = false
            }
            dragOffset = 0
            accumulatedOffset = 0
            // Small delay before allowing tap again
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                // Reset complete
            }
        }
    }
    
    private func triggerHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        if settings.hapticsEnabled {
            let impact = UIImpactFeedbackGenerator(style: style)
            impact.impactOccurred()
        }
    }

    private func incrementHabit() {
        // Only allow incrementing if viewing today
        guard isViewingToday else { return }
        
        triggerHaptic(.medium)

        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            habit.incrementAmount(for: displayDate, in: modelContext)
        }
    }
}
