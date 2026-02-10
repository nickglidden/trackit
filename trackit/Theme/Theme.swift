
//  Theme.swift
//  trackit

import SwiftUI

enum Theme: String, CaseIterable {
    case frostbiteBlue = "Frostbite Blue"
    case crimsonWave = "Crimson Wave"
    case limeWater = "Lime Water"
    case sunsetOrange = "Sunset Orange"
    case lavenderMist = "Lavender Mist"
    case mintGreen = "Mint Green"
    case midnightIndigo = "Midnight Indigo"
    case oceanTeal = "Ocean Teal"
    case roseQuartz = "Rose Quartz"
    case forestPine = "Forest Pine"
    case goldenHour = "Golden Hour"
    case slateStorm = "Slate Storm"
    case cherryBlossom = "Cherry Blossom"
    case ember = "Ember"
    
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
        case .midnightIndigo:
            return Color(red: 0.33, green: 0.35, blue: 0.86)
        case .oceanTeal:
            return Color(red: 0.20, green: 0.78, blue: 0.72)
        case .roseQuartz:
            return Color(red: 0.95, green: 0.53, blue: 0.70)
        case .forestPine:
            return Color(red: 0.18, green: 0.64, blue: 0.45)
        case .goldenHour:
            return Color(red: 0.98, green: 0.78, blue: 0.20)
        case .slateStorm:
            return Color(red: 0.55, green: 0.63, blue: 0.72)
        case .cherryBlossom:
            return Color(red: 0.98, green: 0.67, blue: 0.78)
        case .ember:
            return Color(red: 0.95, green: 0.33, blue: 0.24)
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
    case systemRounded = "System Rounded"
    case systemSerif = "System Serif"
    case systemMonospaced = "System Monospaced"
    case courier = "Courier"
    case menlo = "Menlo"
    case monaco = "Monaco"
    case helveticaNeue = "Helvetica Neue"
    case avenirNext = "Avenir Next"
    case georgia = "Georgia"
    case palatino = "Palatino"
    
    func font(size: CGFloat) -> Font {
        switch self {
        case .system:
            return .system(size: size)
        case .systemRounded:
            return .system(size: size, design: .rounded)
        case .systemSerif:
            return .system(size: size, design: .serif)
        case .systemMonospaced:
            return .system(size: size, design: .monospaced)
        case .courier:
            return .custom("Courier", size: size)
        case .menlo:
            return .custom("Menlo", size: size)
        case .monaco:
            return .custom("Monaco", size: size)
        case .helveticaNeue:
            return .custom("HelveticaNeue", size: size)
        case .avenirNext:
            return .custom("AvenirNext-Regular", size: size)
        case .georgia:
            return .custom("Georgia", size: size)
        case .palatino:
            return .custom("Palatino-Roman", size: size)
        }
    }
    
    static func from(string: String) -> AppFont {
        AppFont.allCases.first { $0.rawValue == string } ?? .courier
    }
}
