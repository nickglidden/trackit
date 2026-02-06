//
//  AppSettings.swift
//  trackit
//
//  Created by Nick Glidden on 2/6/26.
//

import Foundation
import SwiftData

@Model
final class AppSettings {
    var theme: String
    var fontName: String
    var showLabels: Bool
    var hapticsEnabled: Bool
    var roundCorners: Bool
    var amountSize: Double
    
    init(theme: String = "frostbiteBlue",
         fontName: String = "Courier",
         showLabels: Bool = true,
         hapticsEnabled: Bool = true,
         roundCorners: Bool = true,
         amountSize: Double = 5.0) {
        self.theme = theme
        self.fontName = fontName
        self.showLabels = showLabels
        self.hapticsEnabled = hapticsEnabled
        self.roundCorners = roundCorners
        self.amountSize = amountSize
    }
}
