// ABOUTME: Model defining keyboard physical layout with key positions and legends
// ABOUTME: Currently implements ANSI 60% layout for Milestone 1, extensible for custom layouts

import Foundation
import CoreGraphics
import SwiftUI

struct Key: Identifiable, Equatable {
    let id = UUID()
    let keyCode: CGKeyCode
    let baseLegend: String
    let shiftLegend: String?
    let frame: CGRect
    let row: Int
    let column: Int
    let backgroundColor: Color
    
    // Convenience initializer for single-label keys
    init(keyCode: CGKeyCode, legend: String, frame: CGRect, row: Int, column: Int, backgroundColor: Color = .clear) {
        self.keyCode = keyCode
        self.baseLegend = legend
        self.shiftLegend = nil
        self.frame = frame
        self.row = row
        self.column = column
        self.backgroundColor = backgroundColor
    }
    
    // Full initializer for dual-label keys
    init(keyCode: CGKeyCode, baseLegend: String, shiftLegend: String?, frame: CGRect, row: Int, column: Int, backgroundColor: Color = .clear) {
        self.keyCode = keyCode
        self.baseLegend = baseLegend
        self.shiftLegend = shiftLegend
        self.frame = frame
        self.row = row
        self.column = column
        self.backgroundColor = backgroundColor
    }
    
    static func == (lhs: Key, rhs: Key) -> Bool {
        return lhs.keyCode == rhs.keyCode
    }
}