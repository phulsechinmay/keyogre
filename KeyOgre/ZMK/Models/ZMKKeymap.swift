// ABOUTME: ZMK keymap model representing complete keymap with multiple layers
// ABOUTME: Parsed from .keymap file containing layer definitions and key bindings

import Foundation

struct ZMKKeymap: Identifiable {
    let id = UUID()
    let name: String           // Keymap name/identifier
    let layers: [ZMKLayer]     // Array of keymap layers
    
    init(name: String, layers: [ZMKLayer]) {
        self.name = name
        self.layers = layers
    }
    
    // Get default layer (first layer)
    var defaultLayer: ZMKLayer? {
        return layers.first
    }
    
    // Get layer by name
    func layer(named: String) -> ZMKLayer? {
        return layers.first { $0.name == named }
    }
}