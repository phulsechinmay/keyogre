// ABOUTME: Color theme definitions for KeyOgre keyboard overlay
// ABOUTME: Provides muted pastel palettes matching the reference video aesthetic

import SwiftUI

struct ColorTheme {
    let keyBackground: Color
    let keyHighlight: Color
    let keyBorder: Color
    let keyText: Color
    let windowBackground: Color
    let name: String
    
    // Pastel Light theme (matches reference video)
    static let pastelLight = ColorTheme(
        keyBackground: Color(red: 0.95, green: 0.95, blue: 0.97),
        keyHighlight: Color(red: 0.85, green: 0.90, blue: 1.0),
        keyBorder: Color(red: 0.85, green: 0.85, blue: 0.88),
        keyText: Color(red: 0.3, green: 0.3, blue: 0.4),
        windowBackground: Color(red: 0.98, green: 0.98, blue: 0.99),
        name: "Pastel Light"
    )
    
    // Pastel Dark theme
    static let pastelDark = ColorTheme(
        keyBackground: Color(red: 0.25, green: 0.25, blue: 0.28),
        keyHighlight: Color(red: 0.35, green: 0.40, blue: 0.50),
        keyBorder: Color(red: 0.35, green: 0.35, blue: 0.38),
        keyText: Color(red: 0.85, green: 0.85, blue: 0.88),
        windowBackground: Color(red: 0.20, green: 0.20, blue: 0.22),
        name: "Pastel Dark"
    )
    
    // High Contrast theme
    static let highContrast = ColorTheme(
        keyBackground: Color.white,
        keyHighlight: Color.yellow,
        keyBorder: Color.black,
        keyText: Color.black,
        windowBackground: Color.white,
        name: "High Contrast"
    )
    
    static let defaultTheme = pastelLight
}