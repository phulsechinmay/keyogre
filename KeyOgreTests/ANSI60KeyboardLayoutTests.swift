// ABOUTME: Unit tests for ANSI60KeyboardLayout class verifying layout structure and key properties
// ABOUTME: Tests keyboard dimensions, key positioning, dual labels, and color assignments

import Testing
import SwiftUI
@testable import KeyOgre

struct ANSI60KeyboardLayoutTests {
    
    @Test func testLayoutInitialization() async throws {
        let layout = ANSI60KeyboardLayout(withColors: true)
        
        #expect(layout.keys.count > 0, "Layout should contain keys")
        #expect(layout.totalSize.width > 0, "Layout should have positive width")
        #expect(layout.totalSize.height > 0, "Layout should have positive height")
    }
    
    @Test func testKeyCount() async throws {
        let layout = ANSI60KeyboardLayout(withColors: true)
        
        // ANSI 60% should have exactly 61 keys (including modifiers)
        // Row 0: 13 number keys + 1 backspace = 14
        // Row 1: 1 tab + 13 QWERTY keys = 14  
        // Row 2: 1 caps + 11 ASDF keys + 1 enter = 13
        // Row 3: 1 left shift + 10 ZXCV keys + 1 right shift = 12
        // Row 4: 3 left modifiers + 1 space + 2 right modifiers = 6
        // Total: 14 + 14 + 13 + 12 + 6 = 59 keys
        
        #expect(layout.keys.count >= 58, "Should have at least 58 keys for 60% layout")
        #expect(layout.keys.count <= 62, "Should have at most 62 keys for 60% layout")
    }
    
    @Test func testRowDistribution() async throws {
        let layout = ANSI60KeyboardLayout(withColors: true)
        
        let rowCounts = Dictionary(grouping: layout.keys, by: { $0.row })
            .mapValues { $0.count }
        
        #expect(rowCounts[0] != nil, "Should have row 0 (number row)")
        #expect(rowCounts[1] != nil, "Should have row 1 (QWERTY row)")
        #expect(rowCounts[2] != nil, "Should have row 2 (ASDF row)")
        #expect(rowCounts[3] != nil, "Should have row 3 (ZXCV row)")
        #expect(rowCounts[4] != nil, "Should have row 4 (bottom row)")
        
        // Each row should have reasonable number of keys
        for (row, count) in rowCounts {
            #expect(count >= 6, "Row \(row) should have at least 6 keys")
            #expect(count <= 15, "Row \(row) should have at most 15 keys")
        }
    }
    
    @Test func testKeyCodesAreUnique() async throws {
        let layout = ANSI60KeyboardLayout(withColors: true)
        
        let keyCodes = layout.keys.map { $0.keyCode }
        let uniqueKeyCodes = Set(keyCodes)
        
        #expect(keyCodes.count == uniqueKeyCodes.count, "All key codes should be unique")
    }
    
    @Test func testKeyFramesAreValid() async throws {
        let layout = ANSI60KeyboardLayout(withColors: true)
        
        for key in layout.keys {
            #expect(key.frame.width > 0, "Key \(key.baseLegend) should have positive width")
            #expect(key.frame.height > 0, "Key \(key.baseLegend) should have positive height")
            #expect(key.frame.origin.x >= 0, "Key \(key.baseLegend) should have non-negative x position")
            #expect(key.frame.origin.y >= 0, "Key \(key.baseLegend) should have non-negative y position")
        }
    }
    
    @Test func testDualLabelKeys() async throws {
        let layout = ANSI60KeyboardLayout(withColors: true)
        
        // Find number row keys that should have dual labels
        let numberRowKeys = layout.keys.filter { $0.row == 0 && $0.baseLegend != "Backspace" }
        
        var dualLabelCount = 0
        for key in numberRowKeys {
            if key.shiftLegend != nil {
                dualLabelCount += 1
                #expect(!key.shiftLegend!.isEmpty, "Shift legend should not be empty")
                #expect(!key.baseLegend.isEmpty, "Base legend should not be empty")
            }
        }
        
        #expect(dualLabelCount >= 10, "Should have at least 10 keys with dual labels in number row")
    }
    
    @Test func testSpecificKeyMappings() async throws {
        let layout = ANSI60KeyboardLayout(withColors: true)
        
        // Test some specific key mappings
        let key1 = layout.keyForKeyCode(18) // Should be '1' key
        #expect(key1?.baseLegend == "1", "Key code 18 should map to '1'")
        #expect(key1?.shiftLegend == "!", "Key code 18 shift should be '!'")
        
        let keyA = layout.keyForKeyCode(0) // Should be 'A' key
        #expect(keyA?.baseLegend == "A", "Key code 0 should map to 'A'")
        
        let spaceKey = layout.keyForKeyCode(49) // Should be space
        #expect(spaceKey?.baseLegend == "", "Space key should have empty legend")
    }
    
    @Test func testKeyColors() async throws {
        let layoutWithColors = ANSI60KeyboardLayout(withColors: true)
        let layoutWithoutColors = ANSI60KeyboardLayout(withColors: false)
        
        // With colors, most keys should have background colors
        let coloredKeys = layoutWithColors.keys.filter { $0.backgroundColor != .clear }
        #expect(coloredKeys.count > 30, "Should have many colored keys when withColors is true")
        
        // Without colors, keys should have clear background
        let clearKeys = layoutWithoutColors.keys.filter { $0.backgroundColor == .clear }
        #expect(clearKeys.count == layoutWithoutColors.keys.count, "All keys should be clear when withColors is false")
    }
    
    @Test func testLayoutBounds() async throws {
        let layout = ANSI60KeyboardLayout(withColors: true)
        
        // Find the rightmost and bottommost key positions
        let maxX = layout.keys.map { $0.frame.maxX }.max() ?? 0
        let maxY = layout.keys.map { $0.frame.maxY }.max() ?? 0
        
        #expect(layout.totalSize.width >= maxX, "Total width should encompass all keys")
        #expect(layout.totalSize.height >= maxY, "Total height should encompass all keys")
        
        // Layout should be wider than tall (keyboard aspect ratio)
        #expect(layout.totalSize.width > layout.totalSize.height, "Keyboard should be wider than tall")
    }
    
    @Test func testKeyForKeyCodeMethod() async throws {
        let layout = ANSI60KeyboardLayout(withColors: true)
        
        // Test that keyForKeyCode returns correct key
        for key in layout.keys {
            let foundKey = layout.keyForKeyCode(key.keyCode)
            #expect(foundKey?.keyCode == key.keyCode, "keyForKeyCode should return correct key")
            #expect(foundKey?.baseLegend == key.baseLegend, "Returned key should have same legend")
        }
        
        // Test with invalid key code
        let invalidKey = layout.keyForKeyCode(999)
        #expect(invalidKey == nil, "Should return nil for invalid key code")
    }
    
    @Test func testRowPositioning() async throws {
        let layout = ANSI60KeyboardLayout(withColors: true)
        
        // Group keys by row and check Y positions
        let keysByRow = Dictionary(grouping: layout.keys, by: { $0.row })
        
        for row in 0...4 {
            guard let rowKeys = keysByRow[row] else { continue }
            
            // All keys in the same row should have similar Y positions
            let yPositions = rowKeys.map { $0.frame.origin.y }
            let minY = yPositions.min() ?? 0
            let maxY = yPositions.max() ?? 0
            
            #expect(maxY - minY < 5, "Keys in row \(row) should have similar Y positions")
            
            // Keys should be positioned from left to right by column
            let sortedByColumn = rowKeys.sorted { $0.column < $1.column }
            for i in 1..<sortedByColumn.count {
                let prevKey = sortedByColumn[i-1]
                let currentKey = sortedByColumn[i]
                #expect(currentKey.frame.origin.x >= prevKey.frame.origin.x, 
                       "Keys should be positioned left to right by column in row \(row)")
            }
        }
    }
}