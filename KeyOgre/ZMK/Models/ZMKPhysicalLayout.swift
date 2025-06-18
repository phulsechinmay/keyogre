// ABOUTME: ZMK physical layout model representing keyboard geometry and key positions
// ABOUTME: Parsed from .dtsi file containing physical_layout configuration

import Foundation
import CoreGraphics

struct ZMKPhysicalLayout: Identifiable {
    let id = UUID()
    let name: String                    // Layout name (e.g., "typhon_layout")
    let displayName: String             // Human readable name (e.g., "Typhon")
    let keyPositions: [ZMKKeyPosition]  // Physical key positions from dtsi
    
    init(name: String, displayName: String, keyPositions: [ZMKKeyPosition]) {
        self.name = name
        self.displayName = displayName
        self.keyPositions = keyPositions
    }
    
    // Calculate total layout size
    var totalSize: CGSize {
        let scale: CGFloat = 0.4 // Scale factor to convert centi-keyunits to points
        
        guard !keyPositions.isEmpty else {
            return CGSize(width: 480, height: 200) // Default size
        }
        
        let maxX = keyPositions.map { $0.x + $0.width }.max() ?? 0
        let maxY = keyPositions.map { $0.y + $0.height }.max() ?? 0
        
        return CGSize(
            width: CGFloat(maxX) * scale + 20, // Add padding
            height: CGFloat(maxY) * scale + 20
        )
    }
}

// Physical key position from dtsi file
struct ZMKKeyPosition {
    let width: Int          // Width in centi-keyunits
    let height: Int         // Height in centi-keyunits
    let x: Int             // X position in centi-keyunits
    let y: Int             // Y position in centi-keyunits
    let rotation: Int      // Rotation in degrees
    let rotationX: Int     // Rotation origin X
    let rotationY: Int     // Rotation origin Y
    let index: Int         // Index in the keys array
    
    init(width: Int, height: Int, x: Int, y: Int, rotation: Int = 0, rotationX: Int = 0, rotationY: Int = 0, index: Int) {
        self.width = width
        self.height = height
        self.x = x
        self.y = y
        self.rotation = rotation
        self.rotationX = rotationX
        self.rotationY = rotationY
        self.index = index
    }
}