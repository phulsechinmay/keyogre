// ABOUTME: Centralized manager for keyboard layouts, handling both ANSI60 and ZMK layouts
// ABOUTME: Provides a shared instance and handles loading/switching between different keyboard types

import Foundation
import SwiftUI

protocol KeyboardLayoutProtocol {
    var keys: [Key] { get }
    var totalSize: CGSize { get }
    func keyForKeyCode(_ keyCode: CGKeyCode) -> Key?
}

extension ANSI60KeyboardLayout: KeyboardLayoutProtocol {}
extension ZMKKeyboardLayout: KeyboardLayoutProtocol {}

class KeyboardLayoutManager: ObservableObject {
    static let shared = KeyboardLayoutManager()
    
    @Published var currentLayout: KeyboardLayoutProtocol
    @Published var availableLayouts: [String] = ["ANSI 60%", "Typhon (ZMK)"]
    @Published var selectedLayoutName: String = "Typhon (ZMK)"
    
    private let ansiLayout: ANSI60KeyboardLayout
    private var zmkLayout: ZMKKeyboardLayout?
    
    private init() {
        self.ansiLayout = ANSI60KeyboardLayout(withColors: true)
        
        // Try to load ZMK layout as default
        print("🔍 KeyboardLayoutManager: Attempting to load ZMK layout...")
        
        // Try to get bundle paths first, fallback to hardcoded paths for development
        var dtsiPath: String?
        var keymapPath: String?
        
        // Check bundle resources first
        dtsiPath = Bundle.main.path(forResource: "typhon", ofType: "dtsi")
        keymapPath = Bundle.main.path(forResource: "typhon", ofType: "keymap")
        
        // Fallback to development paths with proper permissions
        if dtsiPath == nil || keymapPath == nil {
            print("   Bundle resources not found, using development paths...")
            dtsiPath = "/Users/phulsechinmay/Desktop/Projects/keyogre/KeyOgre/ZmkFiles/typhon.dtsi"
            keymapPath = "/Users/phulsechinmay/Desktop/Projects/keyogre/KeyOgre/ZmkFiles/typhon.keymap"
        }
        
        guard let finalDtsiPath = dtsiPath, let finalKeymapPath = keymapPath else {
            self.currentLayout = self.ansiLayout
            self.selectedLayoutName = "ANSI 60%"
            print("❌ KeyboardLayoutManager: Could not determine ZMK file paths")
            return
        }
        
        print("   DTSI path: \(finalDtsiPath)")
        print("   Keymap path: \(finalKeymapPath)")
        
        // Check file existence
        let dtsiExists = FileManager.default.fileExists(atPath: finalDtsiPath)
        let keymapExists = FileManager.default.fileExists(atPath: finalKeymapPath)
        
        print("   DTSI exists: \(dtsiExists)")
        print("   Keymap exists: \(keymapExists)")
        
        if !dtsiExists || !keymapExists {
            self.currentLayout = self.ansiLayout
            self.selectedLayoutName = "ANSI 60%"
            print("❌ KeyboardLayoutManager: ZMK files not found, falling back to ANSI 60%")
            return
        }
        
        do {
            print("   Parsing DTSI file...")
            let physicalLayout = try ZMKDtsiParser.parsePhysicalLayout(from: finalDtsiPath)
            print("   ✅ Successfully parsed DTSI: \(physicalLayout.displayName) with \(physicalLayout.keyPositions.count) keys")
            
            print("   Parsing keymap file...")
            let keymap = try ZMKKeymapParser.parseKeymap(from: finalKeymapPath)
            print("   ✅ Successfully parsed keymap: \(keymap.name) with \(keymap.layers.count) layers")
            
            // Validate that we have the expected data
            guard physicalLayout.keyPositions.count > 0 else {
                print("❌ KeyboardLayoutManager: No key positions found in DTSI")
                throw ZMKDtsiParser.ParseError.invalidKeyAttributes
            }
            
            guard keymap.layers.count > 0 else {
                print("❌ KeyboardLayoutManager: No layers found in keymap")
                throw ZMKKeymapParser.ParseError.noLayers
            }
            
            guard let defaultLayer = keymap.defaultLayer, defaultLayer.bindings.count > 0 else {
                print("❌ KeyboardLayoutManager: No default layer or bindings found")
                throw ZMKKeymapParser.ParseError.noLayers
            }
            
            print("   Creating ZMK keyboard layout...")
            print("   Physical layout: \(physicalLayout.keyPositions.count) keys")
            print("   Default layer: \(defaultLayer.bindings.count) bindings")
            
            self.zmkLayout = ZMKKeyboardLayout(physicalLayout: physicalLayout, keymap: keymap, withColors: false)
            
            // Set ZMK as default if successful
            if let zmkLayout = self.zmkLayout {
                // Validate the created layout
                guard zmkLayout.keys.count > 0 else {
                    print("❌ KeyboardLayoutManager: ZMK layout created but has no keys")
                    self.currentLayout = self.ansiLayout
                    self.selectedLayoutName = "ANSI 60%"
                    return
                }
                
                self.currentLayout = zmkLayout
                print("✅ KeyboardLayoutManager: Successfully loaded Typhon ZMK layout as default")
                print("   Layout: \(zmkLayout.displayName) with \(zmkLayout.keys.count) keys")
                print("   Total size: \(zmkLayout.totalSize)")
                
                // Test a few key mappings to ensure they work
                let sampleKeys = zmkLayout.keys.prefix(5)
                for (index, key) in sampleKeys.enumerated() {
                    print("   Sample key \(index): '\(key.baseLegend)' at (\(key.frame.origin.x), \(key.frame.origin.y))")
                }
            } else {
                self.currentLayout = self.ansiLayout
                self.selectedLayoutName = "ANSI 60%"
                print("⚠️ KeyboardLayoutManager: ZMK layout creation failed, falling back to ANSI 60%")
            }
        } catch {
            // Fallback to ANSI layout if ZMK fails
            self.currentLayout = self.ansiLayout
            self.selectedLayoutName = "ANSI 60%"
            print("❌ KeyboardLayoutManager: Failed to load ZMK layout: \(error)")
            
            // Print detailed error information
            if let parseError = error as? ZMKDtsiParser.ParseError {
                print("   DTSI Parse Error: \(parseError)")
            } else if let parseError = error as? ZMKKeymapParser.ParseError {
                print("   Keymap Parse Error: \(parseError)")
            } else {
                print("   Unknown error: \(error.localizedDescription)")
            }
            
            print("   Falling back to ANSI 60% layout")
        }
    }
    
    func switchToLayout(named layoutName: String) {
        switch layoutName {
        case "ANSI 60%":
            currentLayout = ansiLayout
            selectedLayoutName = "ANSI 60%"
            print("🔄 KeyboardLayoutManager: Switched to ANSI 60% layout")
            
        case "Typhon (ZMK)":
            if let zmkLayout = self.zmkLayout {
                currentLayout = zmkLayout
                selectedLayoutName = "Typhon (ZMK)"
                print("🔄 KeyboardLayoutManager: Switched to Typhon ZMK layout")
            } else {
                print("❌ KeyboardLayoutManager: ZMK layout not available")
            }
            
        default:
            print("❌ KeyboardLayoutManager: Unknown layout: \(layoutName)")
        }
    }
    
    func reloadZMKLayout() {
        do {
            // Use the same bundle/fallback logic as init
            var dtsiPath = Bundle.main.path(forResource: "typhon", ofType: "dtsi")
            var keymapPath = Bundle.main.path(forResource: "typhon", ofType: "keymap")
            
            if dtsiPath == nil || keymapPath == nil {
                dtsiPath = "/Users/phulsechinmay/Desktop/Projects/keyogre/KeyOgre/ZmkFiles/typhon.dtsi"
                keymapPath = "/Users/phulsechinmay/Desktop/Projects/keyogre/KeyOgre/ZmkFiles/typhon.keymap"
            }
            
            guard let finalDtsiPath = dtsiPath, let finalKeymapPath = keymapPath else {
                print("❌ KeyboardLayoutManager: Could not determine ZMK file paths for reload")
                return
            }
            
            self.zmkLayout = try ZMKKeyboardLayout.fromFiles(
                dtsiPath: finalDtsiPath,
                keymapPath: finalKeymapPath,
                withColors: false
            )
            
            // If currently using ZMK, update the current layout
            if selectedLayoutName == "Typhon (ZMK)", let zmkLayout = self.zmkLayout {
                currentLayout = zmkLayout
            }
            
            print("🔄 KeyboardLayoutManager: Successfully reloaded ZMK layout")
        } catch {
            print("❌ KeyboardLayoutManager: Failed to reload ZMK layout: \(error)")
        }
    }
    
    var currentLayoutInfo: String {
        if let zmkLayout = currentLayout as? ZMKKeyboardLayout {
            return "ZMK: \(zmkLayout.displayName) (\(zmkLayout.keys.count) keys)"
        } else if let ansiLayout = currentLayout as? ANSI60KeyboardLayout {
            return "ANSI 60% (\(ansiLayout.keys.count) keys)"
        } else {
            return "Unknown layout"
        }
    }
}