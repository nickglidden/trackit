
//  AppSettings.swift
//  trackit

import Foundation
import SwiftData

@Model
final class AppSettings {
    var theme: String
    var fontName: String
    var hapticsEnabled: Bool
    var roundCorners: Bool
    var numberOfPeriods: Int
    
    init(theme: String = "frostbiteBlue",
         fontName: String = "Courier",
         hapticsEnabled: Bool = true,
         roundCorners: Bool = true,
         numberOfPeriods: Int = 4) {
        self.theme = theme
        self.fontName = fontName
        self.hapticsEnabled = hapticsEnabled
        self.roundCorners = roundCorners
        self.numberOfPeriods = min(10, max(3, numberOfPeriods))
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
