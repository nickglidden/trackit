//  OnboardingView.swift
//  trackit
//
//  First-time user onboarding and help documentation

import SwiftUI

struct OnboardingView: View {
    @Bindable var settings: AppSettings
    @Environment(\.dismiss) private var dismiss
    @State private var currentPage = 0
    
    let showDismissButton: Bool
    let startAtDocumentation: Bool
    
    init(settings: AppSettings, showDismissButton: Bool, startAtDocumentation: Bool = false) {
        self.settings = settings
        self.showDismissButton = showDismissButton
        self.startAtDocumentation = startAtDocumentation
        self._currentPage = State(initialValue: startAtDocumentation ? 3 : 0)
    }
    
    private var backgroundColor: Color {
        Theme.from(string: settings.theme).backgroundColor
    }
    
    private var themeColor: Color {
        Theme.from(string: settings.theme).primaryColor
    }
    
    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()
            
            if startAtDocumentation {
                // Show only documentation page
                DocumentationPageView(
                    settings: settings,
                    themeColor: themeColor,
                    showDismissButton: true,
                    onDismiss: {
                        dismiss()
                    }
                )
            } else {
                // Show full onboarding
                TabView(selection: $currentPage) {
                    // Page 1: Welcome
                    WelcomePageView(
                        settings: settings,
                        themeColor: themeColor,
                        onContinue: { currentPage = 1 }
                    )
                    .tag(0)
                    
                    // Page 2: Choose Your Look
                    ChooseThemePageView(
                        settings: settings,
                        themeColor: themeColor,
                        onContinue: { currentPage = 2 }
                    )
                    .tag(1)
                    
                    // Page 3: Notifications
                    NotificationsPageView(
                        settings: settings,
                        themeColor: themeColor,
                        onContinue: { currentPage = 3 }
                    )
                    .tag(2)
                    
                    // Page 4: How-To / Documentation
                    DocumentationPageView(
                        settings: settings,
                        themeColor: themeColor,
                        showDismissButton: showDismissButton,
                        onDismiss: {
                            settings.hasCompletedOnboarding = true
                            dismiss()
                        }
                    )
                    .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                .allowsHitTesting(true)
                .highPriorityGesture(DragGesture(minimumDistance: 1000)) // Effectively disable swipe
            }
        }
        .interactiveDismissDisabled(!showDismissButton)
    }
}

// MARK: - Welcome Page

struct WelcomePageView: View {
    let settings: AppSettings
    let themeColor: Color
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            VStack(spacing: 32) {
                Text("TrackIt!")
                    .font(AppFont.from(string: settings.fontName).font(size: 48))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Are you ready to get started?")
                    .font(AppFont.from(string: settings.fontName).font(size: 18))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            Button(action: {
                withAnimation {
                    onContinue()
                }
            }) {
                Text("Let's Go!")
                    .font(AppFont.from(string: settings.fontName).font(size: 18))
                    .fontWeight(.semibold)
                    .foregroundColor(themeColor)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(.white)
                    .cornerRadius(settings.roundCorners ? 16 : 8)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 60)
        }
    }
}

// MARK: - Choose Theme Page

struct ChooseThemePageView: View {
    @Bindable var settings: AppSettings
    let themeColor: Color
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 12) {
                Text("Choose")
                    .font(AppFont.from(string: settings.fontName).font(size: 42))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Your Look")
                    .font(AppFont.from(string: settings.fontName).font(size: 42))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Who doesn't like to customize?")
                    .font(AppFont.from(string: settings.fontName).font(size: 16))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.top, 4)
            }
            .padding(.top, 80)
            
            // Theme picker
            Menu {
                ForEach(Theme.allCases, id: \.self) { theme in
                    Button(action: {
                        withAnimation {
                            settings.theme = theme.rawValue.lowercased().replacingOccurrences(of: " ", with: "")
                        }
                    }) {
                        HStack {
                            Text(theme.rawValue)
                            if Theme.from(string: settings.theme) == theme {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    Text(Theme.from(string: settings.theme).rawValue)
                        .font(AppFont.from(string: settings.fontName).font(size: 16))
                        .foregroundColor(themeColor)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 14))
                        .foregroundColor(themeColor)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(.white)
                .cornerRadius(settings.roundCorners ? 16 : 8)
            }
            .padding(.horizontal, 40)
            
            // Example habit card
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Drink Water")
                        .font(AppFont.from(string: settings.fontName).font(size: 18))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    Spacer()
                    Text("4 / 8")
                        .font(AppFont.from(string: settings.fontName).font(size: 18))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .monospacedDigit()
                }
                .padding(.horizontal, 16)
                
                HStack {
                    Text("Today • Monday, Feb 16")
                        .font(AppFont.from(string: settings.fontName).font(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 12))
                            .foregroundColor(themeColor)
                        Text("3")
                            .font(AppFont.from(string: settings.fontName).font(size: 13))
                            .fontWeight(.medium)
                            .foregroundColor(themeColor)
                    }
                    HStack(spacing: 4) {
                        Image(systemName: "drop.fill")
                            .font(.system(size: 12))
                            .foregroundColor(themeColor)
                        Text("87%")
                            .font(AppFont.from(string: settings.fontName).font(size: 13))
                            .fontWeight(.medium)
                            .foregroundColor(themeColor)
                    }
                }
                .padding(.horizontal, 16)
                
                // Progress bar
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: settings.roundCorners ? 12 : 0)
                        .fill(Color.white.opacity(0.22))
                        .frame(height: 120)
                    
                    RoundedRectangle(cornerRadius: settings.roundCorners ? 12 : 0)
                        .fill(Color.white.opacity(0.9))
                        .frame(width: 140, height: 120)
                }
                .padding(.top, 8)
            }
            .padding(16)
            .background(themeColor)
            .cornerRadius(settings.roundCorners ? 20 : 8)
            .padding(.horizontal, 40)
            
            Spacer()
            
            Button(action: {
                withAnimation {
                    onContinue()
                }
            }) {
                Text("Continue")
                    .font(AppFont.from(string: settings.fontName).font(size: 18))
                    .fontWeight(.semibold)
                    .foregroundColor(themeColor)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(.white)
                    .cornerRadius(settings.roundCorners ? 16 : 8)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 60)
        }
    }
}

// MARK: - Notifications Page

struct NotificationsPageView: View {
    let settings: AppSettings
    let themeColor: Color
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 12) {
                Text("Allow")
                    .font(AppFont.from(string: settings.fontName).font(size: 42))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Notifications")
                    .font(AppFont.from(string: settings.fontName).font(size: 42))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Receive reminders to complete your habits,\ntrack activity, and more.")
                    .font(AppFont.from(string: settings.fontName).font(size: 16))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)
            }
            .padding(.top, 80)
            
            Spacer()
            
            // Mock notification prompt
            VStack(spacing: 16) {
                VStack(spacing: 8) {
                    Text("\"TrackIt!\" Would Like to Send")
                        .font(AppFont.from(string: settings.fontName).font(size: 14))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    Text("You Notifications")
                        .font(AppFont.from(string: settings.fontName).font(size: 14))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                
                Text("Notifications may include alerts,\nsounds, and icon badges. These can\nbe configured in Settings.")
                    .font(AppFont.from(string: settings.fontName).font(size: 12))
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
                
                HStack(spacing: 16) {
                    Button(action: {}) {
                        Text("Don't Allow")
                            .font(AppFont.from(string: settings.fontName).font(size: 16))
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(settings.roundCorners ? 12 : 6)
                    }
                    
                    Button(action: {}) {
                        Text("Allow")
                            .font(AppFont.from(string: settings.fontName).font(size: 16))
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.white.opacity(0.3))
                            .cornerRadius(settings.roundCorners ? 12 : 6)
                    }
                }
            }
            .padding(24)
            .background(Color.white.opacity(0.15))
            .cornerRadius(settings.roundCorners ? 20 : 8)
            .padding(.horizontal, 40)
            
            Spacer()
            
            Button(action: {
                withAnimation {
                    onContinue()
                }
            }) {
                Text("Grant Access")
                    .font(AppFont.from(string: settings.fontName).font(size: 18))
                    .fontWeight(.semibold)
                    .foregroundColor(themeColor)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(.white)
                    .cornerRadius(settings.roundCorners ? 16 : 8)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 60)
        }
    }
}

// MARK: - Documentation Page

struct DocumentationPageView: View {
    let settings: AppSettings
    let themeColor: Color
    let showDismissButton: Bool
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("How-To")
                    .font(AppFont.from(string: settings.fontName).font(size: 42))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                if showDismissButton {
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                            .frame(width: 32, height: 32)
                    }
                }
            }
            .padding(.horizontal, 40)
            .padding(.top, 60)
            .padding(.bottom, 32)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 32) {
                    // Tap to Track
                    HStack(alignment: .top, spacing: 16) {
                        Image(systemName: "hand.tap.fill")
                            .font(.system(size: 28))
                            .foregroundColor(themeColor)
                            .frame(width: 40)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Tap to Track")
                                .font(AppFont.from(string: settings.fontName).font(size: 20))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Tapping on a habit allows you to track activity right from the home screen!")
                                .font(AppFont.from(string: settings.fontName).font(size: 16))
                                .foregroundColor(.white.opacity(0.7))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding(.horizontal, 40)
                    
                    // Hold & Drag to Reorder
                    HStack(alignment: .top, spacing: 16) {
                        Image(systemName: "hand.draw.fill")
                            .font(.system(size: 28))
                            .foregroundColor(themeColor)
                            .frame(width: 40)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Hold & Drag to Reorder")
                                .font(AppFont.from(string: settings.fontName).font(size: 20))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Hold and drag a habit to reorder how they are displayed!")
                                .font(AppFont.from(string: settings.fontName).font(size: 16))
                                .foregroundColor(.white.opacity(0.7))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding(.horizontal, 40)
                    
                    // Swipe Left or Right
                    HStack(alignment: .top, spacing: 16) {
                        Image(systemName: "hand.point.left.fill")
                            .font(.system(size: 28))
                            .foregroundColor(themeColor)
                            .frame(width: 40)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Swipe Left or Right")
                                .font(AppFont.from(string: settings.fontName).font(size: 20))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Swiping left on a habit allows you to edit it, while swiping right on a habit lets you delete it!")
                                .font(AppFont.from(string: settings.fontName).font(size: 16))
                                .foregroundColor(.white.opacity(0.7))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 24)
                    
                    // Visual demonstrations
                    VStack(spacing: 16) {
                        // Swipe left to Edit
                        ZStack(alignment: .leading) {
                            // Edit action button on left
                            HStack {
                                VStack(spacing: 8) {
                                    Image(systemName: "pencil")
                                        .font(.system(size: 20, weight: .medium))
                                        .foregroundColor(.white)
                                        .frame(width: 56, height: 56)
                                        .background(themeColor)
                                        .clipShape(Circle())
                                    
                                    Text("Edit")
                                        .font(AppFont.from(string: settings.fontName).font(size: 14))
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                .padding(.leading, 32)
                                
                                Spacer()
                            }
                            
                            // Mock habit card
                            HStack {
                                Spacer()
                                RoundedRectangle(cornerRadius: settings.roundCorners ? 16 : 0)
                                    .fill(.white)
                                    .frame(width: 320, height: 160)
                                    .shadow(color: .black.opacity(0.3), radius: 10, x: -5, y: 0)
                            }
                        }
                        .frame(height: 160)
                        
                        // Swipe right to Delete
                        ZStack(alignment: .trailing) {
                            // Mock habit card
                            HStack {
                                RoundedRectangle(cornerRadius: settings.roundCorners ? 16 : 0)
                                    .fill(.white)
                                    .frame(width: 200, height: 160)
                                    .shadow(color: .black.opacity(0.3), radius: 10, x: 5, y: 0)
                                Spacer()
                            }
                            
                            // Delete action button on right
                            HStack {
                                Spacer()
                                VStack(spacing: 8) {
                                    Image(systemName: "trash.fill")
                                        .font(.system(size: 20, weight: .medium))
                                        .foregroundColor(.white)
                                        .frame(width: 56, height: 56)
                                        .background(themeColor)
                                        .clipShape(Circle())
                                    
                                    Text("Delete")
                                        .font(AppFont.from(string: settings.fontName).font(size: 14))
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                .padding(.trailing, 32)
                            }
                        }
                        .frame(height: 160)
                    }
                    .padding(.bottom, 32)
                }
            }
            
            // Dismiss button
            Button(action: onDismiss) {
                Text("Dismiss")
                    .font(AppFont.from(string: settings.fontName).font(size: 18))
                    .fontWeight(.semibold)
                    .foregroundColor(Theme.from(string: settings.theme).backgroundColor)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(.white)
                    .cornerRadius(settings.roundCorners ? 16 : 8)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 60)
        }
    }
}

struct HowToCard: View {
    let icon: String
    let title: String
    let description: String
    let iconColor: Color
    let settings: AppSettings
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(iconColor)
                .frame(width: 44, height: 44)
                .background(Color.white.opacity(0.15))
                .cornerRadius(settings.roundCorners ? 12 : 6)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(AppFont.from(string: settings.fontName).font(size: 18))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(AppFont.from(string: settings.fontName).font(size: 14))
                    .foregroundColor(.white.opacity(0.7))
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(20)
        .background(Color.white.opacity(0.1))
        .cornerRadius(settings.roundCorners ? 16 : 8)
    }
}
