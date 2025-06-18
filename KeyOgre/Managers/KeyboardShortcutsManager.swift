// ABOUTME: KeyboardShortcuts integration for global hotkey management
// ABOUTME: Provides system-wide keyboard shortcuts with comprehensive logging for debugging

import Foundation
import KeyboardShortcuts
import os.log

// MARK: - Shortcut Definitions
extension KeyboardShortcuts.Name {
    static let toggleKeyOgre = Self("toggleKeyOgre", default: .init(.backtick, modifiers: [.command]))
}

// MARK: - KeyboardShortcuts Manager
class KeyboardShortcutsManager: ObservableObject {
    static let shared = KeyboardShortcutsManager()
    
    private let logger = Logger(subsystem: "com.keyogre.app", category: "KeyboardShortcuts")
    private var isListening = false
    
    private init() {
        setupLogging()
    }
    
    private func setupLogging() {
        logger.info("KeyboardShortcutsManager initialized")
        #if DEBUG
        print("[KeyOgre] KeyboardShortcutsManager initialized")
        #endif
    }
    
    // MARK: - Public API
    func setupGlobalHotkey(action: @escaping () -> Void) {
        logger.info("Setting up global hotkey for toggleKeyOgre")
        #if DEBUG
        print("[KeyOgre] Setting up global hotkey for toggleKeyOgre")
        #endif
        
        // Get current shortcut
        let currentShortcut = KeyboardShortcuts.getShortcut(for: .toggleKeyOgre)
        if let shortcut = currentShortcut {
            logger.info("Current shortcut: \(shortcut.description)")
            #if DEBUG
            print("[KeyOgre] Current shortcut: \(shortcut.description)")
            #endif
        } else {
            logger.warning("No shortcut currently set")
            #if DEBUG
            print("[KeyOgre] No shortcut currently set")
            #endif
        }
        
        // Set up listener with explicit options for fullscreen app compatibility
        KeyboardShortcuts.onKeyDown(for: .toggleKeyOgre) { [weak self] in
            self?.logger.info("🎯 Global hotkey triggered!")
            #if DEBUG
            print("[KeyOgre] 🎯 Global hotkey triggered!")
            #endif
            
            // Force main thread execution immediately for fullscreen app compatibility
            if Thread.isMainThread {
                action()
            } else {
                DispatchQueue.main.sync {
                    action()
                }
            }
        }
        
        isListening = true
        logger.info("✅ Global hotkey listener registered successfully")
        #if DEBUG
        print("[KeyOgre] ✅ Global hotkey listener registered successfully")
        #endif
    }
    
    func removeGlobalHotkey() {
        logger.info("Removing global hotkey listener")
        #if DEBUG
        print("[KeyOgre] Removing global hotkey listener")
        #endif
        
        KeyboardShortcuts.disable(.toggleKeyOgre)
        isListening = false
        
        logger.info("Global hotkey listener removed")
        #if DEBUG
        print("[KeyOgre] Global hotkey listener removed")
        #endif
    }
    
    // MARK: - Debug Information
    func logDebugInfo() {
        logger.info("=== KeyboardShortcuts Debug Info ===")
        #if DEBUG
        print("[KeyOgre] === KeyboardShortcuts Debug Info ===")
        #endif
        
        let shortcut = KeyboardShortcuts.getShortcut(for: .toggleKeyOgre)
        logger.info("Shortcut set: \(shortcut?.description ?? "None")")
        logger.info("Is listening: \(self.isListening)")
//        logger.info("KeyboardShortcuts enabled: \(KeyboardShortcuts.isEnabled)")
//
        #if DEBUG
        print("[KeyOgre] Shortcut set: \(shortcut?.description ?? "None")")
        print("[KeyOgre] Is listening: \(isListening)")
//        print("[KeyOgre] KeyboardShortcuts enabled: \(KeyboardShortcuts.isEnabled)")
        #endif
        
        // Check accessibility permissions
        let hasPermissions = checkAccessibilityPermissions()
        logger.info("Accessibility permissions: \(hasPermissions ? "✅ Granted" : "❌ Denied")")
        #if DEBUG
        print("[KeyOgre] Accessibility permissions: \(hasPermissions ? "✅ Granted" : "❌ Denied")")
        #endif
        
        logger.info("=== End Debug Info ===")
        #if DEBUG
        print("[KeyOgre] === End Debug Info ===")
        #endif
    }
    
    private func checkAccessibilityPermissions() -> Bool {
        let checkOptPrompt = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString
        let options = [checkOptPrompt: false]
        return AXIsProcessTrustedWithOptions(options as CFDictionary)
    }
    
    // MARK: - Shortcut Management
    func setCustomShortcut(key: KeyboardShortcuts.Key, modifiers: NSEvent.ModifierFlags) {
        let newShortcut = KeyboardShortcuts.Shortcut(key, modifiers: modifiers)
        
        logger.info("Setting custom shortcut: \(newShortcut.description)")
        #if DEBUG
        print("[KeyOgre] Setting custom shortcut: \(newShortcut.description)")
        #endif
        
        KeyboardShortcuts.setShortcut(newShortcut, for: .toggleKeyOgre)
        
        logger.info("Custom shortcut set successfully")
        #if DEBUG
        print("[KeyOgre] Custom shortcut set successfully")
        #endif
    }
    
    func resetToDefaultShortcut() {
        logger.info("Resetting to default shortcut")
        #if DEBUG
        print("[KeyOgre] Resetting to default shortcut")
        #endif
        
        KeyboardShortcuts.reset(.toggleKeyOgre)
        
        logger.info("Reset to default shortcut complete")
        #if DEBUG
        print("[KeyOgre] Reset to default shortcut complete")
        #endif
    }
}

// MARK: - Extensions for Better Logging
extension KeyboardShortcuts.Shortcut {
    var description: String {
        var parts: [String] = []
        
        if modifiers.contains(.control) { parts.append("⌃") }
        if modifiers.contains(.option) { parts.append("⌥") }
        if modifiers.contains(.shift) { parts.append("⇧") }
        if modifiers.contains(.command) { parts.append("⌘") }
        
        parts.append(key?.description ?? "No key description")
        
        return parts.joined()
    }
}

extension KeyboardShortcuts.Key {
    var description: String {
        switch self {
        case .a: return "A"
        case .b: return "B"
        case .c: return "C"
        case .d: return "D"
        case .e: return "E"
        case .f: return "F"
        case .g: return "G"
        case .h: return "H"
        case .i: return "I"
        case .j: return "J"
        case .k: return "K"
        case .l: return "L"
        case .m: return "M"
        case .n: return "N"
        case .o: return "O"
        case .p: return "P"
        case .q: return "Q"
        case .r: return "R"
        case .s: return "S"
        case .t: return "T"
        case .u: return "U"
        case .v: return "V"
        case .w: return "W"
        case .x: return "X"
        case .y: return "Y"
        case .z: return "Z"
        case .zero: return "0"
        case .one: return "1"
        case .two: return "2"
        case .three: return "3"
        case .four: return "4"
        case .five: return "5"
        case .six: return "6"
        case .seven: return "7"
        case .eight: return "8"
        case .nine: return "9"
        case .space: return "Space"
        case .tab: return "Tab"
        case .return: return "Return"
        case .escape: return "Escape"
        case .backtick: return "`"
        default: return "Unknown"
        }
    }
}
