// ABOUTME: Unified provider for creating keyboard layouts from configurations
// ABOUTME: Handles both preset keyboards and ZMK keyboards with proper error handling

import Foundation
import SwiftUI

protocol KeyboardLayout: AnyObject {
    var keys: [Key] { get }
    var totalSize: CGSize { get }
    var name: String { get }
    var displayName: String { get }
    
    func keyForKeyCode(_ keyCode: CGKeyCode) -> Key?
}

enum KeyboardProviderError: LocalizedError {
    case invalidConfiguration
    case missingZMKFiles
    case parseError(String)
    case unsupportedPresetModel
    
    var errorDescription: String? {
        switch self {
        case .invalidConfiguration:
            return "Invalid keyboard configuration"
        case .missingZMKFiles:
            return "Missing ZMK files (dtsi or keymap)"
        case .parseError(let message):
            return "Parse error: \(message)"
        case .unsupportedPresetModel:
            return "Unsupported preset keyboard model"
        }
    }
}

class KeyboardProvider {
    static let shared = KeyboardProvider()
    
    private init() {}
    
    func createKeyboardLayout(from config: KeyboardConfiguration) throws -> any KeyboardLayout {
        switch config.type {
        case .preset:
            return try createPresetKeyboard(config: config)
        case .zmk:
            return try createZMKKeyboard(config: config)
        }
    }
    
    private func createPresetKeyboard(config: KeyboardConfiguration) throws -> any KeyboardLayout {
        guard let presetModel = config.presetModel else {
            throw KeyboardProviderError.invalidConfiguration
        }
        
        switch presetModel {
        case .ansi60:
            return ANSI60KeyboardLayout()
        case .ansi87:
            // For now, fallback to ANSI60 - we can implement ANSI87 later
            return ANSI60KeyboardLayout()
        case .ansi104:
            // For now, fallback to ANSI60 - we can implement ANSI104 later
            return ANSI60KeyboardLayout()
        }
    }
    
    private func createZMKKeyboard(config: KeyboardConfiguration) throws -> any KeyboardLayout {
        guard let dtsiContent = config.dtsiContent,
              let keymapContent = config.keymapContent,
              !dtsiContent.isEmpty,
              !keymapContent.isEmpty else {
            throw KeyboardProviderError.missingZMKFiles
        }
        
        do {
            // Create temporary files for parsing
            let tempDir = NSTemporaryDirectory()
            let dtsiPath = tempDir + "\(config.id.uuidString).dtsi"
            let keymapPath = tempDir + "\(config.id.uuidString).keymap"
            
            try dtsiContent.write(toFile: dtsiPath, atomically: true, encoding: .utf8)
            try keymapContent.write(toFile: keymapPath, atomically: true, encoding: .utf8)
            
            let zmkLayout = try ZMKKeyboardLayout.fromFiles(dtsiPath: dtsiPath, keymapPath: keymapPath)
            
            // Clean up temp files
            try? FileManager.default.removeItem(atPath: dtsiPath)
            try? FileManager.default.removeItem(atPath: keymapPath)
            
            return zmkLayout
            
        } catch {
            throw KeyboardProviderError.parseError(error.localizedDescription)
        }
    }
    
    func validateZMKFiles(dtsiContent: String, keymapContent: String) -> Bool {
        guard !dtsiContent.isEmpty, !keymapContent.isEmpty else {
            return false
        }
        
        // Basic validation - check for required ZMK patterns
        let hasPhysicalLayout = dtsiContent.contains("compatible = \"zmk,physical-layout\"")
        let hasKeymap = keymapContent.contains("keymap") && keymapContent.contains("bindings")
        
        return hasPhysicalLayout && hasKeymap
    }
    
    func getAvailablePresetModels() -> [PresetKeyboardModel] {
        return PresetKeyboardModel.allCases
    }
}