// ABOUTME: ZMK key model representing a single key with physical attributes and key binding
// ABOUTME: Stores both physical position data from dtsi and key binding from keymap file

import Foundation
import CoreGraphics
import SwiftUI

struct ZMKKey: Identifiable, Equatable {
    let id = UUID()
    
    // Physical attributes from dtsi file
    let width: Int          // Width in centi-keyunits (100 = 1u)
    let height: Int         // Height in centi-keyunits
    let x: Int             // X position in centi-keyunits
    let y: Int             // Y position in centi-keyunits
    let rotation: Int      // Rotation in degrees (positive = clockwise)
    let rotationX: Int     // Rotation origin X
    let rotationY: Int     // Rotation origin Y
    
    // Key binding from keymap file
    let binding: String    // ZMK key binding (e.g., "&kp GRAVE", "&kp N1")
    let displayName: String // Human readable key name (e.g., "`", "1")
    
    // Layout positioning
    let keyIndex: Int      // Index in the keys array
    
    init(width: Int, height: Int, x: Int, y: Int, rotation: Int = 0, rotationX: Int = 0, rotationY: Int = 0, 
         binding: String, displayName: String, keyIndex: Int) {
        self.width = width
        self.height = height
        self.x = x
        self.y = y
        self.rotation = rotation
        self.rotationX = rotationX
        self.rotationY = rotationY
        self.binding = binding
        self.displayName = displayName
        self.keyIndex = keyIndex
    }
    
    // Calculate frame in KeyOgre coordinate system (scaled down from centi-keyunits)
    var frame: CGRect {
        let scale: CGFloat = 0.4 // Scale factor to convert centi-keyunits to points
        return CGRect(
            x: CGFloat(x) * scale,
            y: CGFloat(y) * scale,
            width: CGFloat(width) * scale,
            height: CGFloat(height) * scale
        )
    }
    
    static func == (lhs: ZMKKey, rhs: ZMKKey) -> Bool {
        return lhs.keyIndex == rhs.keyIndex
    }
}