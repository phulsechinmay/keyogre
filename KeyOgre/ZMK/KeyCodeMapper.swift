// ABOUTME: Maps ZMK key codes and behaviors to human-readable display names
// ABOUTME: Handles &kp codes, modifiers, special behaviors, and Bluetooth functions

import Foundation

class KeyCodeMapper {
    
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
        "BSLH": "\\", "SEMI": ";", "APOS": "'", "COMMA": ",", "DOT": ".", "FSLH": "/",
        
        // Special keys
        "SPACE": "", "BSPC": "⌫", "TAB": "⇥", "RET": "↩", "ESC": "⎋",
        "DEL": "⌦", "HOME": "↖", "END": "↘", "PGUP": "⇞", "PGDN": "⇟",
        
        // Modifiers
        "LSHFT": "⇧", "RSHFT": "⇧", "LCTRL": "⌃", "RCTRL": "⌃",
        "LALT": "⌥", "RALT": "⌥", "LGUI": "⌘", "RGUI": "⌘",
        "CAPS": "⇪",
        
        // Arrow keys
        "LARW": "←", "DARW": "↓", "UARW": "↑", "RARW": "→",
        
        // Function keys
        "F1": "F1", "F2": "F2", "F3": "F3", "F4": "F4", "F5": "F5", "F6": "F6",
        "F7": "F7", "F8": "F8", "F9": "F9", "F10": "F10", "F11": "F11", "F12": "F12"
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