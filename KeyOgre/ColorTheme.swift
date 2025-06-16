// ABOUTME: Color theme definitions for KeyOgre keyboard overlay
// ABOUTME: Provides muted pastel palettes with translucent support for overlay functionality

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
    
    // Translucent Pastel Light theme (enhanced visibility with 50% window opacity)
    static let translucentLight = ColorTheme(
        keyBackground: Color(red: 0.98, green: 0.98, blue: 1.0, opacity: 0.85),
        keyHighlight: Color(red: 0.75, green: 0.85, blue: 1.0, opacity: 0.95),
        keyBorder: Color(red: 0.6, green: 0.6, blue: 0.7, opacity: 0.8),
        keyText: Color(red: 0.15, green: 0.15, blue: 0.25, opacity: 0.9),
        windowBackground: Color(red: 0.95, green: 0.95, blue: 0.98, opacity: 0.5),
        name: "Translucent Light"
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
    
    // Translucent Pastel Dark theme (enhanced visibility with 50% window opacity)
    static let translucentDark = ColorTheme(
        keyBackground: Color(red: 0.15, green: 0.15, blue: 0.18, opacity: 0.85),
        keyHighlight: Color(red: 0.25, green: 0.35, blue: 0.55, opacity: 0.95),
        keyBorder: Color(red: 0.45, green: 0.45, blue: 0.5, opacity: 0.8),
        keyText: Color(red: 0.9, green: 0.9, blue: 0.95, opacity: 0.95),
        windowBackground: Color(red: 0.1, green: 0.1, blue: 0.12, opacity: 0.5),
        name: "Translucent Dark"
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
    
    static let defaultTheme = translucentLight
}