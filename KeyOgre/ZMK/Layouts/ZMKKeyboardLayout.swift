// ABOUTME: ZMK keyboard layout implementation that integrates with KeyOgre's existing system
// ABOUTME: Combines physical layout from dtsi and key bindings from keymap to create renderable keyboard

import Foundation
import CoreGraphics
import SwiftUI

class ZMKKeyboardLayout: ObservableObject, KeyboardLayout {
    let keys: [Key]
    let totalSize: CGSize
    let name: String
    let displayName: String
    
    private let zmkKeys: [ZMKKey]
    private let physicalLayout: ZMKPhysicalLayout
    private let keymap: ZMKKeymap
    
    init(physicalLayout: ZMKPhysicalLayout, keymap: ZMKKeymap, withColors: Bool = false) {
        self.physicalLayout = physicalLayout
        self.keymap = keymap
        self.name = physicalLayout.name
        self.displayName = physicalLayout.displayName
        
        // Get the default layer (first layer) for key bindings
        let defaultLayer = keymap.defaultLayer ?? ZMKLayer(name: "default", displayName: "Default", bindings: [])
        
        // Create ZMK keys by combining physical positions with key bindings
        var zmkKeys: [ZMKKey] = []
        
        for (index, keyPosition) in physicalLayout.keyPositions.enumerated() {
            let binding = index < defaultLayer.bindings.count ? defaultLayer.bindings[index] : "&trans"
            let displayName = KeyCodeMapper.mapKeyBinding(binding)
            
            let zmkKey = ZMKKey(
                width: keyPosition.width,
                height: keyPosition.height,
                x: keyPosition.x,
                y: keyPosition.y,
                rotation: keyPosition.rotation,
                rotationX: keyPosition.rotationX,
                rotationY: keyPosition.rotationY,
                binding: binding,
                displayName: displayName,
                keyIndex: index
            )
            
            zmkKeys.append(zmkKey)
        }
        
        self.zmkKeys = zmkKeys
        
        // Convert ZMK keys to KeyOgre Key format
        var keys: [Key] = []
        
        for zmkKey in zmkKeys {
            // Get the proper macOS keycode from the ZMK binding
            let keyCode = KeyCodeMapper.getMacOSKeyCode(for: zmkKey.binding) ?? CGKeyCode(zmkKey.keyIndex + 1000)
            
            // Use the display name from the key binding
            let legend = zmkKey.displayName.isEmpty ? "?" : zmkKey.displayName
            
            let key = Key(
                keyCode: keyCode,
                legend: legend,
                frame: zmkKey.frame,
                row: zmkKey.keyIndex / 12, // Approximate row calculation
                column: zmkKey.keyIndex % 12, // Approximate column calculation
                backgroundColor: withColors ? .gray.opacity(0.3) : .clear
            )
            
            keys.append(key)
        }
        
        self.keys = keys
        self.totalSize = physicalLayout.totalSize
    }
    
    // Factory method to create layout from files
    static func fromFiles(dtsiPath: String, keymapPath: String, withColors: Bool = false) throws -> ZMKKeyboardLayout {
        let physicalLayout = try ZMKDtsiParser.parsePhysicalLayout(from: dtsiPath)
        let keymap = try ZMKKeymapParser.parseKeymap(from: keymapPath)
        
        return ZMKKeyboardLayout(physicalLayout: physicalLayout, keymap: keymap, withColors: withColors)
    }
    
    // Find key by keyCode (for compatibility with existing KeyOgre system)
    func keyForKeyCode(_ keyCode: CGKeyCode) -> Key? {
        return keys.first { $0.keyCode == keyCode }
    }
    
    // Find ZMK key by index
    func zmkKeyForIndex(_ index: Int) -> ZMKKey? {
        return zmkKeys.first { $0.keyIndex == index }
    }
    
    // Get layer information
    func getLayerInfo() -> String {
        let layerNames = keymap.layers.map { $0.displayName }.joined(separator: ", ")
        return "Layers: \(layerNames)"
    }
    
    // Debug information
    func debugInfo() -> String {
        return """
        ZMK Keyboard Layout: \(displayName)
        Physical Layout: \(physicalLayout.name)
        Keymap: \(keymap.name)
        Keys: \(keys.count)
        Size: \(totalSize.width) x \(totalSize.height)
        Layers: \(keymap.layers.count)
        """
    }
}