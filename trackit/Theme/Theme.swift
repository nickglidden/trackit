//
//  Theme.swift
//  trackit
//
//  Created by Nick Glidden on 2/6/26.
//

import SwiftUI

enum Theme: String, CaseIterable {
    case frostbiteBlue = "Frostbite Blue"
    case crimsonWave = "Crimson Wave"
    case limeWater = "Lime Water"
    case sunsetOrange = "Sunset Orange"
    case lavenderMist = "Lavender Mist"
    case mintGreen = "Mint Green"
    
    var primaryColor: Color {
        switch self {
        case .frostbiteBlue:
            return Color(red: 0.42, green: 0.68, blue: 0.89)
        case .crimsonWave:
            return Color(red: 0.86, green: 0.26, blue: 0.38)
        case .limeWater:
            return Color(red: 0.68, green: 0.93, blue: 0.51)
        case .sunsetOrange:
            return Color(red: 0.95, green: 0.61, blue: 0.26)
        case .lavenderMist:
            return Color(red: 0.73, green: 0.63, blue: 0.89)
        case .mintGreen:
            return Color(red: 0.60, green: 0.89, blue: 0.75)
        }
    }
    
    var secondaryColor: Color {
        primaryColor.opacity(0.6)
    }
    
    var backgroundColor: Color {
        primaryColor.opacity(0.3)
    }
    
    static func from(string: String) -> Theme {
        Theme.allCases.first { $0.rawValue.lowercased().replacingOccurrences(of: " ", with: "") == string.lowercased() } ?? .frostbiteBlue
    }
}

extension Color {
    static func habitTheme(from string: String) -> Color {
        Theme.from(string: string).primaryColor
    }
}

enum AppFont: String, CaseIterable {
    case system = "System"
    case courier = "Courier"
    case menlo = "Menlo"
    case monaco = "Monaco"
    
    func font(size: CGFloat) -> Font {
        switch self {
        case .system:
            return .system(size: size)
        case .courier:
            return .custom("Courier", size: size)
        case .menlo:
            return .custom("Menlo", size: size)
        case .monaco:
            return .custom("Monaco", size: size)
        }
    }
    
    static func from(string: String) -> AppFont {
        AppFont.allCases.first { $0.rawValue == string } ?? .courier
    }
}
