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
    @State private var isHolding = false
    @State private var isDragging = false
    @State private var dragDirection: CGFloat = 0 // -1 for left, 1 for right, 0 for none
    @State private var navigationCount = 0
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
                    incrementHabit()
                }
            
            // Period navigation footer
            periodNavigationFooter
        }
    }

    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Row 1: Habit name and progress (fixed height)
            HStack(alignment: .center) {
                Text(habit.name)
                    .font(AppFont.from(string: settings.fontName).font(size: 24))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .lineLimit(1)

                Spacer(minLength: 8)

                Text(progressText)
                    .font(AppFont.from(string: settings.fontName).font(size: 28))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .monospacedDigit()
            }
            .frame(height: 32)
            
            // Row 2: Period label on left, stats on right (fixed height)
            HStack(alignment: .center, spacing: 8) {
                Text(periodLabel)
                    .font(AppFont.from(string: settings.fontName).font(size: 13))
                    .foregroundColor(.primary.opacity(0.6))
                    .lineLimit(1)
                
                Spacer(minLength: 8)
                
                // Show streak, completion %, and other stats
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
            .frame(height: 20)
        }
        .frame(height: 58)
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
                .frame(height: 28)
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
                .frame(height: 28)
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
        .frame(height: 36)
        .padding(.horizontal, 8)
        .padding(.top, 8)
        .contentShape(Rectangle())
        .opacity(isHolding ? 0.9 : 1.0)
        .scaleEffect(isHolding ? 0.98 : 1.0)
        .gesture(
            LongPressGesture(minimumDuration: 0.3)
                .onChanged { _ in
                    if !isHolding {
                        isHolding = true
                        navigationCount = 0
                        triggerHaptic(.medium)
                    }
                }
                .sequenced(before:
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            handleDragChanged(value)
                        }
                        .onEnded { _ in
                            handleDragEnded()
                        }
                )
        )
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
        
        // Only process if we're holding
        guard isHolding else { return }
        
        // Start dragging once we've moved 30pt in either direction
        if !isDragging && abs(translation) > 30 {
            isDragging = true
            lastNavigationTime = Date()
            navigationCount = 0
        }
        
        // Handle continuous drag navigation
        if isDragging {
            // Determine direction: left = next (future), right = previous (past)
            let currentDirection: CGFloat = translation < 0 ? -1 : (translation > 0 ? 1 : 0)
            
            // If direction changed, reset counter
            if currentDirection != dragDirection && currentDirection != 0 {
                dragDirection = currentDirection
                navigationCount = 0
                lastNavigationTime = Date()
            }
            
            // Calculate time interval based on navigation count for progressive speed
            let now = Date()
            let interval = calculateNavigationInterval()
            
            // Check if enough time has passed to navigate again
            if now.timeIntervalSince(lastNavigationTime) >= interval {
                if dragDirection < 0 {
                    // Dragging left -> next period (forward in time)
                    goToNextPeriod()
                } else if dragDirection > 0 {
                    // Dragging right -> previous period (back in time)
                    goToPreviousPeriod()
                }
                
                navigationCount += 1
                lastNavigationTime = now
            }
        }
    }
    
    private func calculateNavigationInterval() -> TimeInterval {
        // Progressive speed: starts at 2s, then speeds up
        // 2s, 2s, 1.5s, 1.5s, 1s, 1s, 1s...
        switch navigationCount {
        case 0, 1:
            return 2.0
        case 2, 3:
            return 1.5
        default:
            return 1.0
        }
    }
    
    private func handleDragEnded() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            isHolding = false
            isDragging = false
            dragDirection = 0
            navigationCount = 0
        }
    }
    
    private func triggerHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        if settings.hapticsEnabled {
            let impact = UIImpactFeedbackGenerator(style: style)
            impact.impactOccurred()
        }
    }

    private func incrementHabit() {
        // Increment the currently displayed period (not necessarily today)
        triggerHaptic(.medium)

        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            habit.incrementAmount(for: displayDate, in: modelContext)
        }
    }
}
