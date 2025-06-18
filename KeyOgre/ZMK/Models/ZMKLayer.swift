// ABOUTME: ZMK layer model representing a keymap layer with key bindings
// ABOUTME: Contains collection of key bindings for a specific layer (e.g., default_layer, lower_layer)

import Foundation

struct ZMKLayer: Identifiable {
    let id = UUID()
    let name: String           // Layer name (e.g., "default_layer", "lower_layer")
    let displayName: String    // Human readable name (e.g., "Default", "Lower")
    let bindings: [String]     // Array of key bindings in order
    
    init(name: String, displayName: String, bindings: [String]) {
        self.name = name
        self.displayName = displayName
        self.bindings = bindings
    }
}