// ABOUTME: ANSI 60% keyboard layout implementation with column-based color scheme
// ABOUTME: Matches the reference screenshot with dual-label keys and muted pastel colors

import Foundation
import CoreGraphics
import SwiftUI

class ANSI60KeyboardLayout: ObservableObject {
    let keys: [Key]
    let totalSize: CGSize
    
    init(withColors: Bool = true) {
        // ANSI 60% layout dimensions and positioning
        let keyWidth: CGFloat = 40
        let keyHeight: CGFloat = 40
        let keySpacing: CGFloat = 4
        let rowSpacing: CGFloat = 4
        
        var keys: [Key] = []
        
        // Column colors based on the screenshot
        let columnColors: [Color] = [
            Color(red: 0.7, green: 0.8, blue: 0.7),   // Column 0: Light green
            Color(red: 0.7, green: 0.8, blue: 0.7),   // Column 1: Light green
            Color(red: 0.9, green: 0.85, blue: 0.6),  // Column 2: Yellow
            Color(red: 0.85, green: 0.7, blue: 0.5),  // Column 3: Orange
            Color(red: 0.75, green: 0.75, blue: 0.75), // Column 4: Gray
            Color(red: 0.85, green: 0.65, blue: 0.65), // Column 5: Pink/Red
            Color(red: 0.85, green: 0.65, blue: 0.65), // Column 6: Pink/Red
            Color(red: 0.9, green: 0.85, blue: 0.6),  // Column 7: Yellow
            Color(red: 0.9, green: 0.85, blue: 0.6),  // Column 8: Yellow
            Color(red: 0.85, green: 0.7, blue: 0.5),  // Column 9: Orange
            Color(red: 0.7, green: 0.8, blue: 0.7),   // Column 10: Light green
            Color(red: 0.7, green: 0.8, blue: 0.7),   // Column 11: Light green
            Color(red: 0.7, green: 0.8, blue: 0.7),   // Column 12: Light green
            Color(red: 0.7, green: 0.8, blue: 0.7),   // Column 13: Light green (backspace)
        ]
        
        // Row 0: Number row with dual labels
        let numberRowKeys: [(CGKeyCode, String, String?)] = [
            (50, "`", "~"),
            (18, "1", "!"),
            (19, "2", "@"),
            (20, "3", "#"),
            (21, "4", "$"),
            (23, "5", "%"),
            (22, "6", "^"),
            (26, "7", "&"),
            (28, "8", "*"),
            (25, "9", "("),
            (29, "0", ")"),
            (27, "-", "_"),
            (24, "=", "+")
        ]
        
        for (index, (keyCode, base, shift)) in numberRowKeys.enumerated() {
            let x = CGFloat(index) * (keyWidth + keySpacing)
            let y: CGFloat = 0
            let frame = CGRect(x: x, y: y, width: keyWidth, height: keyHeight)
            let color = withColors ? columnColors[min(index, columnColors.count - 1)] : .clear
            keys.append(Key(keyCode: keyCode, baseLegend: base, shiftLegend: shift, frame: frame, row: 0, column: index, backgroundColor: color))
        }
        
        // Backspace key (wider)
        let backspaceX = CGFloat(numberRowKeys.count) * (keyWidth + keySpacing)
        let backspaceFrame = CGRect(x: backspaceX, y: 0, width: keyWidth * 1.75, height: keyHeight)
        let backspaceColor = withColors ? columnColors[min(13, columnColors.count - 1)] : .clear
        keys.append(Key(keyCode: 51, legend: "Backspace", frame: backspaceFrame, row: 0, column: numberRowKeys.count, backgroundColor: backspaceColor))
        
        // Row 1: QWERTY row
        let qwertyRowKeys: [(CGKeyCode, String, String?)] = [
            (12, "Q", nil), (13, "W", nil), (14, "E", nil), (15, "R", nil), (17, "T", nil),
            (16, "Y", nil), (32, "U", nil), (34, "I", nil), (31, "O", nil), (35, "P", nil),
            (33, "[", "{"), (30, "]", "}"), (42, "\\", "|")
        ]
        
        // Tab key
        let tabFrame = CGRect(x: 0, y: keyHeight + rowSpacing, width: keyWidth * 1.25, height: keyHeight)
        let tabColor = withColors ? columnColors[0] : .clear
        keys.append(Key(keyCode: 48, legend: "Tab", frame: tabFrame, row: 1, column: 0, backgroundColor: tabColor))
        
        for (index, (keyCode, base, shift)) in qwertyRowKeys.enumerated() {
            let x = keyWidth * 1.25 + keySpacing + CGFloat(index) * (keyWidth + keySpacing)
            let y = keyHeight + rowSpacing
            let frame = CGRect(x: x, y: y, width: keyWidth, height: keyHeight)
            let colorIndex = min(index + 1, columnColors.count - 1)
            let color = withColors ? columnColors[colorIndex] : .clear
            keys.append(Key(keyCode: keyCode, baseLegend: base, shiftLegend: shift, frame: frame, row: 1, column: index + 1, backgroundColor: color))
        }
        
        // Row 2: ASDF row
        let asdfRowKeys: [(CGKeyCode, String, String?)] = [
            (0, "A", nil), (1, "S", nil), (2, "D", nil), (3, "F", nil), (5, "G", nil),
            (4, "H", nil), (38, "J", nil), (40, "K", nil), (37, "L", nil),
            (41, ";", ":"), (39, "'", "\"")
        ]
        
        // Caps Lock
        let capsFrame = CGRect(x: 0, y: 2 * (keyHeight + rowSpacing), width: keyWidth * 1.5, height: keyHeight)
        let capsColor = withColors ? columnColors[0] : .clear
        keys.append(Key(keyCode: 57, legend: "Caps Lock", frame: capsFrame, row: 2, column: 0, backgroundColor: capsColor))
        
        for (index, (keyCode, base, shift)) in asdfRowKeys.enumerated() {
            let x = keyWidth * 1.5 + keySpacing + CGFloat(index) * (keyWidth + keySpacing)
            let y = 2 * (keyHeight + rowSpacing)
            let frame = CGRect(x: x, y: y, width: keyWidth, height: keyHeight)
            let colorIndex = min(index + 1, columnColors.count - 1)
            let color = withColors ? columnColors[colorIndex] : .clear
            keys.append(Key(keyCode: keyCode, baseLegend: base, shiftLegend: shift, frame: frame, row: 2, column: index + 1, backgroundColor: color))
        }
        
        // Enter key
        let enterX = keyWidth * 1.5 + keySpacing + CGFloat(asdfRowKeys.count) * (keyWidth + keySpacing)
        let enterFrame = CGRect(x: enterX, y: 2 * (keyHeight + rowSpacing), width: keyWidth * 1.75, height: keyHeight)
        let enterColor = withColors ? columnColors[min(12, columnColors.count - 1)] : .clear
        keys.append(Key(keyCode: 36, legend: "Enter", frame: enterFrame, row: 2, column: asdfRowKeys.count + 1, backgroundColor: enterColor))
        
        // Row 3: ZXCV row
        let zxcvRowKeys: [(CGKeyCode, String, String?)] = [
            (6, "Z", nil), (7, "X", nil), (8, "C", nil), (9, "V", nil), (11, "B", nil),
            (45, "N", nil), (46, "M", nil), (43, ",", "<"), (47, ".", ">"), (44, "/", "?")
        ]
        
        // Left Shift
        let lshiftFrame = CGRect(x: 0, y: 3 * (keyHeight + rowSpacing), width: keyWidth * 2, height: keyHeight)
        let lshiftColor = withColors ? columnColors[0] : .clear
        keys.append(Key(keyCode: 56, legend: "Shift", frame: lshiftFrame, row: 3, column: 0, backgroundColor: lshiftColor))
        
        for (index, (keyCode, base, shift)) in zxcvRowKeys.enumerated() {
            let x = keyWidth * 2 + keySpacing + CGFloat(index) * (keyWidth + keySpacing)
            let y = 3 * (keyHeight + rowSpacing)
            let frame = CGRect(x: x, y: y, width: keyWidth, height: keyHeight)
            let colorIndex = min(index + 1, columnColors.count - 1)
            let color = withColors ? columnColors[colorIndex] : .clear
            keys.append(Key(keyCode: keyCode, baseLegend: base, shiftLegend: shift, frame: frame, row: 3, column: index + 1, backgroundColor: color))
        }
        
        // Right Shift
        let rshiftX = keyWidth * 2 + keySpacing + CGFloat(zxcvRowKeys.count) * (keyWidth + keySpacing)
        let rshiftFrame = CGRect(x: rshiftX, y: 3 * (keyHeight + rowSpacing), width: keyWidth * 2.25, height: keyHeight)
        let rshiftColor = withColors ? columnColors[min(11, columnColors.count - 1)] : .clear
        keys.append(Key(keyCode: 60, legend: "Shift", frame: rshiftFrame, row: 3, column: zxcvRowKeys.count + 1, backgroundColor: rshiftColor))
        
        // Row 4: Bottom row
        let bottomRowY = 4 * (keyHeight + rowSpacing)
        
        // Control, Option, Command keys
        let ctrlFrame = CGRect(x: 0, y: bottomRowY, width: keyWidth * 1.25, height: keyHeight)
        let ctrlColor = withColors ? columnColors[0] : .clear
        keys.append(Key(keyCode: 59, legend: "Ctrl", frame: ctrlFrame, row: 4, column: 0, backgroundColor: ctrlColor))
        
        let optFrame = CGRect(x: keyWidth * 1.25 + keySpacing, y: bottomRowY, width: keyWidth * 1.25, height: keyHeight)
        let optColor = withColors ? columnColors[1] : .clear
        keys.append(Key(keyCode: 58, legend: "Alt", frame: optFrame, row: 4, column: 1, backgroundColor: optColor))
        
        let cmdFrame = CGRect(x: keyWidth * 2.5 + 2 * keySpacing, y: bottomRowY, width: keyWidth * 1.25, height: keyHeight)
        let cmdColor = withColors ? columnColors[2] : .clear
        keys.append(Key(keyCode: 55, legend: "⌘", frame: cmdFrame, row: 4, column: 2, backgroundColor: cmdColor))
        
        // Spacebar - spanning multiple columns, use the red/pink color
        let spaceX = keyWidth * 3.75 + 3 * keySpacing
        let spaceFrame = CGRect(x: spaceX, y: bottomRowY, width: keyWidth * 6, height: keyHeight)
        let spaceColor = withColors ? Color(red: 0.85, green: 0.65, blue: 0.65) : .clear
        keys.append(Key(keyCode: 49, legend: "", frame: spaceFrame, row: 4, column: 3, backgroundColor: spaceColor))
        
        // Right Command, Option, Control
        let rcmdX = spaceX + keyWidth * 6 + keySpacing
        let rcmdFrame = CGRect(x: rcmdX, y: bottomRowY, width: keyWidth * 1.25, height: keyHeight)
        let rcmdColor = withColors ? columnColors[min(10, columnColors.count - 1)] : .clear
        keys.append(Key(keyCode: 54, legend: "Alt", frame: rcmdFrame, row: 4, column: 4, backgroundColor: rcmdColor))
        
        let roptX = rcmdX + keyWidth * 1.25 + keySpacing
        let roptFrame = CGRect(x: roptX, y: bottomRowY, width: keyWidth * 1.25, height: keyHeight)
        let roptColor = withColors ? columnColors[min(11, columnColors.count - 1)] : .clear
        keys.append(Key(keyCode: 61, legend: "Ctrl", frame: roptFrame, row: 4, column: 5, backgroundColor: roptColor))
        
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