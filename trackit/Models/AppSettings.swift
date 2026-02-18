
//  AppSettings.swift
//  trackit

import Foundation
import SwiftData

@Model
final class AppSettings {
    // Appearance
    var theme: String
    var fontName: String
    var roundCorners: Bool
    var highContrastMode: Bool
    
    // Behavior
    var hapticsEnabled: Bool
    var showStreaks: Bool
    var showCompletionPercentage: Bool
    var reduceAnimations: Bool
    
    // Privacy & Security
    var appLockEnabled: Bool
    
    // Onboarding
    var hasCompletedOnboarding: Bool
    
    init(theme: String = "frostbiteBlue",
         fontName: String = "Courier",
         roundCorners: Bool = true,
         highContrastMode: Bool = false,
         hapticsEnabled: Bool = true,
         showStreaks: Bool = true,
         showCompletionPercentage: Bool = true,
         reduceAnimations: Bool = false,
         appLockEnabled: Bool = false,
         hasCompletedOnboarding: Bool = false) {
        self.theme = theme
        self.fontName = fontName
        self.roundCorners = roundCorners
        self.highContrastMode = highContrastMode
        self.hapticsEnabled = hapticsEnabled
        self.showStreaks = showStreaks
        self.showCompletionPercentage = showCompletionPercentage
        self.reduceAnimations = reduceAnimations
        self.appLockEnabled = appLockEnabled
        self.hasCompletedOnboarding = hasCompletedOnboarding
    }
    
    /// Gets the app version from the bundle
    var appVersion: String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        }
        return "1.0.0"
    }
    
    /// Gets the build number from the bundle
    var buildNumber: String {
        if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            return build
        }
        return "1"
    }
}
