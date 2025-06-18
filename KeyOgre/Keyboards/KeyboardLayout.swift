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

class KeyboardLayout: ObservableObject {
    let keys: [Key]
    let totalSize: CGSize
    
    init() {
        // ANSI 60% layout dimensions and positioning
        let keyWidth: CGFloat = 40
        let keyHeight: CGFloat = 40
        let keySpacing: CGFloat = 4
        let rowSpacing: CGFloat = 4
        
        var keys: [Key] = []
        
        // Row 0: Number row
        let numberRowKeys: [(CGKeyCode, String)] = [
            (50, "`"), (18, "1"), (19, "2"), (20, "3"), (21, "4"), (22, "6"), (23, "5"),
            (26, "7"), (28, "8"), (25, "9"), (29, "0"), (27, "-"), (24, "=")
        ]
        
        for (index, (keyCode, legend)) in numberRowKeys.enumerated() {
            let x = CGFloat(index) * (keyWidth + keySpacing)
            let y: CGFloat = 0
            let frame = CGRect(x: x, y: y, width: keyWidth, height: keyHeight)
            keys.append(Key(keyCode: keyCode, legend: legend, frame: frame, row: 0, column: index))
        }
        
        // Backspace key (wider)
        let backspaceX = CGFloat(numberRowKeys.count) * (keyWidth + keySpacing)
        let backspaceFrame = CGRect(x: backspaceX, y: 0, width: keyWidth * 1.75, height: keyHeight)
        keys.append(Key(keyCode: 51, legend: "⌫", frame: backspaceFrame, row: 0, column: numberRowKeys.count))
        
        // Row 1: QWERTY row
        let qwertyRowKeys: [(CGKeyCode, String)] = [
            (12, "Q"), (13, "W"), (14, "E"), (15, "R"), (17, "T"), (16, "Y"),
            (32, "U"), (34, "I"), (31, "O"), (35, "P"), (33, "["), (30, "]"), (42, "\\")
        ]
        
        // Tab key
        let tabFrame = CGRect(x: 0, y: keyHeight + rowSpacing, width: keyWidth * 1.25, height: keyHeight)
        keys.append(Key(keyCode: 48, legend: "⇥", frame: tabFrame, row: 1, column: 0))
        
        for (index, (keyCode, legend)) in qwertyRowKeys.enumerated() {
            let x = keyWidth * 1.25 + keySpacing + CGFloat(index) * (keyWidth + keySpacing)
            let y = keyHeight + rowSpacing
            let frame = CGRect(x: x, y: y, width: keyWidth, height: keyHeight)
            keys.append(Key(keyCode: keyCode, legend: legend, frame: frame, row: 1, column: index + 1))
        }
        
        // Row 2: ASDF row
        let asdfRowKeys: [(CGKeyCode, String)] = [
            (0, "A"), (1, "S"), (2, "D"), (3, "F"), (5, "G"), (4, "H"),
            (38, "J"), (40, "K"), (37, "L"), (41, ";"), (39, "'")
        ]
        
        // Caps Lock
        let capsFrame = CGRect(x: 0, y: 2 * (keyHeight + rowSpacing), width: keyWidth * 1.5, height: keyHeight)
        keys.append(Key(keyCode: 57, legend: "⇪", frame: capsFrame, row: 2, column: 0))
        
        for (index, (keyCode, legend)) in asdfRowKeys.enumerated() {
            let x = keyWidth * 1.5 + keySpacing + CGFloat(index) * (keyWidth + keySpacing)
            let y = 2 * (keyHeight + rowSpacing)
            let frame = CGRect(x: x, y: y, width: keyWidth, height: keyHeight)
            keys.append(Key(keyCode: keyCode, legend: legend, frame: frame, row: 2, column: index + 1))
        }
        
        // Enter key
        let enterX = keyWidth * 1.5 + keySpacing + CGFloat(asdfRowKeys.count) * (keyWidth + keySpacing)
        let enterFrame = CGRect(x: enterX, y: 2 * (keyHeight + rowSpacing), width: keyWidth * 1.75, height: keyHeight)
        keys.append(Key(keyCode: 36, legend: "⏎", frame: enterFrame, row: 2, column: asdfRowKeys.count + 1))
        
        // Row 3: ZXCV row
        let zxcvRowKeys: [(CGKeyCode, String)] = [
            (6, "Z"), (7, "X"), (8, "C"), (9, "V"), (11, "B"), (45, "N"),
            (46, "M"), (43, ","), (47, "."), (44, "/")
        ]
        
        // Left Shift
        let lshiftFrame = CGRect(x: 0, y: 3 * (keyHeight + rowSpacing), width: keyWidth * 2, height: keyHeight)
        keys.append(Key(keyCode: 56, legend: "⇧", frame: lshiftFrame, row: 3, column: 0))
        
        for (index, (keyCode, legend)) in zxcvRowKeys.enumerated() {
            let x = keyWidth * 2 + keySpacing + CGFloat(index) * (keyWidth + keySpacing)
            let y = 3 * (keyHeight + rowSpacing)
            let frame = CGRect(x: x, y: y, width: keyWidth, height: keyHeight)
            keys.append(Key(keyCode: keyCode, legend: legend, frame: frame, row: 3, column: index + 1))
        }
        
        // Right Shift
        let rshiftX = keyWidth * 2 + keySpacing + CGFloat(zxcvRowKeys.count) * (keyWidth + keySpacing)
        let rshiftFrame = CGRect(x: rshiftX, y: 3 * (keyHeight + rowSpacing), width: keyWidth * 2.25, height: keyHeight)
        keys.append(Key(keyCode: 60, legend: "⇧", frame: rshiftFrame, row: 3, column: zxcvRowKeys.count + 1))
        
        // Row 4: Bottom row
        let bottomRowY = 4 * (keyHeight + rowSpacing)
        
        // Control, Option, Command keys
        let ctrlFrame = CGRect(x: 0, y: bottomRowY, width: keyWidth * 1.25, height: keyHeight)
        keys.append(Key(keyCode: 59, legend: "⌃", frame: ctrlFrame, row: 4, column: 0))
        
        let optFrame = CGRect(x: keyWidth * 1.25 + keySpacing, y: bottomRowY, width: keyWidth * 1.25, height: keyHeight)
        keys.append(Key(keyCode: 58, legend: "⌥", frame: optFrame, row: 4, column: 1))
        
        let cmdFrame = CGRect(x: keyWidth * 2.5 + 2 * keySpacing, y: bottomRowY, width: keyWidth * 1.25, height: keyHeight)
        keys.append(Key(keyCode: 55, legend: "⌘", frame: cmdFrame, row: 4, column: 2))
        
        // Spacebar
        let spaceX = keyWidth * 3.75 + 3 * keySpacing
        let spaceFrame = CGRect(x: spaceX, y: bottomRowY, width: keyWidth * 6, height: keyHeight)
        keys.append(Key(keyCode: 49, legend: "", frame: spaceFrame, row: 4, column: 3))
        
        // Right Command, Option, Control
        let rcmdX = spaceX + keyWidth * 6 + keySpacing
        let rcmdFrame = CGRect(x: rcmdX, y: bottomRowY, width: keyWidth * 1.25, height: keyHeight)
        keys.append(Key(keyCode: 54, legend: "⌘", frame: rcmdFrame, row: 4, column: 4))
        
        let roptX = rcmdX + keyWidth * 1.25 + keySpacing
        let roptFrame = CGRect(x: roptX, y: bottomRowY, width: keyWidth * 1.25, height: keyHeight)
        keys.append(Key(keyCode: 61, legend: "⌥", frame: roptFrame, row: 4, column: 5))
        
        self.keys = keys
        
        // Calculate total size
        let maxX = keys.map { $0.frame.maxX }.max() ?? 0
        let maxY = keys.map { $0.frame.maxY }.max() ?? 0
        self.totalSize = CGSize(width: maxX + keySpacing, height: maxY + keySpacing)
    }
    
    func keyForKeyCode(_ keyCode: CGKeyCode) -> Key? {
        return keys.first { $0.keyCode == keyCode }
    }
}