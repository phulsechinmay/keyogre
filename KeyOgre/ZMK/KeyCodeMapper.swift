// ABOUTME: Maps ZMK key codes and behaviors to human-readable display names
// ABOUTME: Handles &kp codes, modifiers, special behaviors, and Bluetooth functions

import Foundation
import CoreGraphics

class KeyCodeMapper {
    
    // Map ZMK key codes to macOS hardware keycodes
    // Reference: https://developer.apple.com/library/archive/technotes/tn2450/_index.html
    private static let zmkToMacOSKeyCode: [String: CGKeyCode] = [
        // Numbers
        "N1": 18, "N2": 19, "N3": 20, "N4": 21, "N5": 23,
        "N6": 22, "N7": 26, "N8": 28, "N9": 25, "N0": 29,
        
        // Letters
        "A": 0, "B": 11, "C": 8, "D": 2, "E": 14, "F": 3, "G": 5, "H": 4, "I": 34, "J": 38,
        "K": 40, "L": 37, "M": 46, "N": 45, "O": 31, "P": 35, "Q": 12, "R": 15, "S": 1, "T": 17,
        "U": 32, "V": 9, "W": 13, "X": 7, "Y": 16, "Z": 6,
        
        // Symbols and punctuation  
        "GRAVE": 50, "MINUS": 27, "EQUAL": 24, "LBKT": 33, "RBKT": 30,
        "BSLH": 42, "SEMI": 41, "APOS": 39, "SQT": 39, "COMMA": 43, "DOT": 47, "FSLH": 44,
        
        // Shifted symbols
        "EXCL": 18, "AT": 19, "HASH": 20, "DOLLAR": 21, "PRCNT": 23,
        "CARET": 22, "AMPS": 26, "ASTRK": 28, "LPAR": 25, "RPAR": 29,
        "PLUS": 24, "LBRC": 33, "RBRC": 30, "PIPE": 42, "TILDE": 50,
        
        // Special keys
        "SPACE": 49, "BSPC": 51, "TAB": 48, "RET": 36, "ESC": 53,
        "DEL": 117, "HOME": 115, "END": 119, "PGUP": 116, "PGDN": 121,
        
        // Modifiers
        "LSHFT": 56, "RSHFT": 60, "LCTRL": 59, "RCTRL": 62,
        "LALT": 58, "RALT": 61, "LGUI": 55, "RGUI": 54,
        "CAPS": 57,
        
        // Arrow keys
        "LARW": 123, "DARW": 125, "UARW": 126, "RARW": 124,
        "LEFT": 123, "DOWN": 125, "UP": 126, "RIGHT": 124,
        
        // Function keys
        "F1": 122, "F2": 120, "F3": 99, "F4": 118, "F5": 96, "F6": 97,
        "F7": 98, "F8": 100, "F9": 101, "F10": 109, "F11": 103, "F12": 111,
        
        // Keypad
        "KP_PLUS": 69
    ]
    
    // Map ZMK key codes to display names
    // Reference: https://zmk.dev/docs/codes/keyboard-keypad
    private static let keyCodeMap: [String: String] = [
        // Numbers
        "N1": "1", "N2": "2", "N3": "3", "N4": "4", "N5": "5",
        "N6": "6", "N7": "7", "N8": "8", "N9": "9", "N0": "0",
        
        // Letters (already correct)
        "A": "A", "B": "B", "C": "C", "D": "D", "E": "E", "F": "F", "G": "G", "H": "H", "I": "I", "J": "J",
        "K": "K", "L": "L", "M": "M", "N": "N", "O": "O", "P": "P", "Q": "Q", "R": "R", "S": "S", "T": "T",
        "U": "U", "V": "V", "W": "W", "X": "X", "Y": "Y", "Z": "Z",
        
        // Symbols and punctuation
        "GRAVE": "`", "MINUS": "-", "EQUAL": "=", "LBKT": "[", "RBKT": "]",
        "BSLH": "\\", "SEMI": ";", "APOS": "'", "SQT": "'", "COMMA": ",", "DOT": ".", "FSLH": "/",
        
        // Shifted symbols
        "EXCL": "!", "AT": "@", "HASH": "#", "DOLLAR": "$", "PRCNT": "%",
        "CARET": "^", "AMPS": "&", "ASTRK": "*", "LPAR": "(", "RPAR": ")",
        "PLUS": "+", "LBRC": "{", "RBRC": "}", "PIPE": "|", "TILDE": "~",
        
        // Special keys
        "SPACE": "", "BSPC": "⌫", "TAB": "⇥", "RET": "↩", "ESC": "⎋",
        "DEL": "⌦", "HOME": "↖", "END": "↘", "PGUP": "⇞", "PGDN": "⇟",
        
        // Modifiers
        "LSHFT": "⇧", "RSHFT": "⇧", "LCTRL": "⌃", "RCTRL": "⌃",
        "LALT": "⌥", "RALT": "⌥", "LGUI": "⌘", "RGUI": "⌘",
        "CAPS": "⇪",
        
        // Arrow keys
        "LARW": "←", "DARW": "↓", "UARW": "↑", "RARW": "→",
        "LEFT": "←", "DOWN": "↓", "UP": "↑", "RIGHT": "→",
        
        // Function keys
        "F1": "F1", "F2": "F2", "F3": "F3", "F4": "F4", "F5": "F5", "F6": "F6",
        "F7": "F7", "F8": "F8", "F9": "F9", "F10": "F10", "F11": "F11", "F12": "F12",
        
        // Keypad
        "KP_PLUS": "+"
    ]
    
    // Map modifier behaviors
    // Reference: https://zmk.dev/docs/behaviors/layers
    private static let behaviorMap: [String: String] = [
        "mo": "MO",     // Momentary layer
        "to": "TO",     // Toggle layer
        "lt": "LT",     // Layer tap
        "sl": "SL",     // Sticky layer
        "bt": "BT",     // Bluetooth
        "trans": "▽",   // Transparent key
        "none": "✗"     // No operation
    ]
    
    // Map Bluetooth commands
    // Reference: https://zmk.dev/docs/behaviors/bluetooth
    private static let bluetoothMap: [String: String] = [
        "BT_SEL": "BT",
        "BT_CLR": "BT CLR",
        "BT_NXT": "BT →",
        "BT_PRV": "BT ←"
    ]
    
    static func getMacOSKeyCode(for binding: String) -> CGKeyCode? {
        let trimmed = binding.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Handle basic key press: &kp KEY_CODE
        if trimmed.hasPrefix("&kp ") {
            let keyCode = String(trimmed.dropFirst(4)).trimmingCharacters(in: .whitespaces)
            return zmkToMacOSKeyCode[keyCode]
        }
        
        // For other behaviors (layers, BT, etc.), return nil as these don't have direct macOS mappings
        return nil
    }
    
    static func mapKeyBinding(_ binding: String) -> String {
        let trimmed = binding.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Handle empty or whitespace-only bindings
        if trimmed.isEmpty {
            return ""
        }
        
        // Handle transparent key
        if trimmed == "&trans" {
            return "▽"
        }
        
        // Handle basic key press: &kp KEY_CODE
        if trimmed.hasPrefix("&kp ") {
            let keyCode = String(trimmed.dropFirst(4)).trimmingCharacters(in: .whitespaces)
            return keyCodeMap[keyCode] ?? keyCode
        }
        
        // Handle momentary layer: &mo N
        if trimmed.hasPrefix("&mo ") {
            let layerNum = String(trimmed.dropFirst(4)).trimmingCharacters(in: .whitespaces)
            return "MO\(layerNum)"
        }
        
        // Handle Bluetooth: &bt BT_SEL N or &bt BT_CLR
        if trimmed.hasPrefix("&bt ") {
            let btCommand = String(trimmed.dropFirst(4)).trimmingCharacters(in: .whitespaces)
            let parts = btCommand.split(separator: " ")
            
            if parts.count >= 1 {
                let command = String(parts[0])
                if command == "BT_SEL" && parts.count >= 2 {
                    let deviceNum = String(parts[1])
                    return "BT\(deviceNum)"
                } else if let mapped = bluetoothMap[command] {
                    return mapped
                }
            }
            return "BT"
        }
        
        // Handle other behaviors
        if trimmed.hasPrefix("&") {
            let parts = trimmed.dropFirst().split(separator: " ")
            if let behavior = parts.first {
                let behaviorName = String(behavior)
                if let mapped = behaviorMap[behaviorName] {
                    if parts.count > 1 {
                        return "\(mapped)\(parts[1])"
                    }
                    return mapped
                }
                return String(behavior).uppercased()
            }
        }
        
        // Handle studio_unlock (special ZMK command)
        if trimmed == "&studio_unlock" {
            return "STUDIO"
        }
        
        // Return original if no mapping found
        return trimmed
    }
    
    // Test function to validate key mappings
    static func testMapping() {
        let testBindings = [
            "&kp GRAVE", "&kp N1", "&kp TAB", "&kp Q",
            "&mo 1", "&bt BT_SEL 0", "&bt BT_CLR", "&trans",
            "&studio_unlock", "&kp LSHFT", "&kp SPACE"
        ]
        
        print("Testing ZMK key mappings:")
        for binding in testBindings {
            let mapped = mapKeyBinding(binding)
            print("\(binding) -> \(mapped)")
        }
    }
}