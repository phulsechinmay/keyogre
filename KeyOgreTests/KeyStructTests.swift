// ABOUTME: Unit tests for Key struct verifying initialization, equality, and property behavior
// ABOUTME: Tests both convenience and full initializers for dual-label keys and color support

import Testing
import SwiftUI
import CoreGraphics
@testable import KeyOgre

struct KeyStructTests {
    
    @Test func testConvenienceInitializer() async throws {
        let frame = CGRect(x: 10, y: 20, width: 40, height: 40)
        let key = Key(keyCode: 18, legend: "1", frame: frame, row: 0, column: 1)
        
        #expect(key.keyCode == 18, "Key code should be set correctly")
        #expect(key.baseLegend == "1", "Base legend should be set correctly")
        #expect(key.shiftLegend == nil, "Shift legend should be nil for convenience initializer")
        #expect(key.frame == frame, "Frame should be set correctly")
        #expect(key.row == 0, "Row should be set correctly")
        #expect(key.column == 1, "Column should be set correctly")
        #expect(key.backgroundColor == .clear, "Default background color should be clear")
    }
    
    @Test func testConvenienceInitializerWithColor() async throws {
        let frame = CGRect(x: 10, y: 20, width: 40, height: 40)
        let color = Color.red
        let key = Key(keyCode: 18, legend: "1", frame: frame, row: 0, column: 1, backgroundColor: color)
        
        #expect(key.keyCode == 18, "Key code should be set correctly")
        #expect(key.baseLegend == "1", "Base legend should be set correctly")
        #expect(key.shiftLegend == nil, "Shift legend should be nil for convenience initializer")
        #expect(key.frame == frame, "Frame should be set correctly")
        #expect(key.row == 0, "Row should be set correctly")
        #expect(key.column == 1, "Column should be set correctly")
        #expect(key.backgroundColor == color, "Background color should be set correctly")
    }
    
    @Test func testFullInitializer() async throws {
        let frame = CGRect(x: 10, y: 20, width: 40, height: 40)
        let color = Color.blue
        let key = Key(keyCode: 18, baseLegend: "1", shiftLegend: "!", frame: frame, row: 0, column: 1, backgroundColor: color)
        
        #expect(key.keyCode == 18, "Key code should be set correctly")
        #expect(key.baseLegend == "1", "Base legend should be set correctly")
        #expect(key.shiftLegend == "!", "Shift legend should be set correctly")
        #expect(key.frame == frame, "Frame should be set correctly")
        #expect(key.row == 0, "Row should be set correctly")
        #expect(key.column == 1, "Column should be set correctly")
        #expect(key.backgroundColor == color, "Background color should be set correctly")
    }
    
    @Test func testFullInitializerWithNilShift() async throws {
        let frame = CGRect(x: 10, y: 20, width: 40, height: 40)
        let key = Key(keyCode: 0, baseLegend: "A", shiftLegend: nil, frame: frame, row: 2, column: 0)
        
        #expect(key.keyCode == 0, "Key code should be set correctly")
        #expect(key.baseLegend == "A", "Base legend should be set correctly")
        #expect(key.shiftLegend == nil, "Shift legend should be nil when explicitly set")
        #expect(key.frame == frame, "Frame should be set correctly")
        #expect(key.row == 2, "Row should be set correctly")
        #expect(key.column == 0, "Column should be set correctly")
        #expect(key.backgroundColor == .clear, "Default background color should be clear")
    }
    
    @Test func testKeyEquality() async throws {
        let frame1 = CGRect(x: 10, y: 20, width: 40, height: 40)
        let frame2 = CGRect(x: 50, y: 60, width: 40, height: 40)
        
        let key1 = Key(keyCode: 18, legend: "1", frame: frame1, row: 0, column: 1)
        let key2 = Key(keyCode: 18, legend: "Different", frame: frame2, row: 5, column: 10, backgroundColor: .red)
        let key3 = Key(keyCode: 19, legend: "2", frame: frame1, row: 0, column: 2)
        
        // Keys with same keyCode should be equal regardless of other properties
        #expect(key1 == key2, "Keys with same keyCode should be equal")
        
        // Keys with different keyCode should not be equal
        #expect(key1 != key3, "Keys with different keyCode should not be equal")
        #expect(key2 != key3, "Keys with different keyCode should not be equal")
    }
    
    @Test func testKeyIdentifiable() async throws {
        let frame = CGRect(x: 10, y: 20, width: 40, height: 40)
        let key1 = Key(keyCode: 18, legend: "1", frame: frame, row: 0, column: 1)
        let key2 = Key(keyCode: 19, legend: "2", frame: frame, row: 0, column: 2)
        
        // Each key should have a unique ID
        #expect(key1.id != key2.id, "Each key should have a unique ID")
        
        // ID should be consistent for the same key instance
        #expect(key1.id == key1.id, "Key ID should be consistent")
    }
    
    @Test func testKeyWithEmptyLegends() async throws {
        let frame = CGRect(x: 10, y: 20, width: 40, height: 40)
        
        // Test empty base legend
        let key1 = Key(keyCode: 49, legend: "", frame: frame, row: 4, column: 3) // Space key
        #expect(key1.baseLegend == "", "Should allow empty base legend")
        #expect(key1.shiftLegend == nil, "Shift legend should be nil")
        
        // Test empty shift legend
        let key2 = Key(keyCode: 0, baseLegend: "A", shiftLegend: "", frame: frame, row: 2, column: 0)
        #expect(key2.baseLegend == "A", "Base legend should be set")
        #expect(key2.shiftLegend == "", "Should allow empty shift legend")
    }
    
    @Test func testKeyFrameProperties() async throws {
        let frame = CGRect(x: 15.5, y: 25.7, width: 45.2, height: 35.8)
        let key = Key(keyCode: 18, legend: "1", frame: frame, row: 0, column: 1)
        
        #expect(key.frame.origin.x == 15.5, "Frame X should be preserved with decimals")
        #expect(key.frame.origin.y == 25.7, "Frame Y should be preserved with decimals")
        #expect(key.frame.width == 45.2, "Frame width should be preserved with decimals")
        #expect(key.frame.height == 35.8, "Frame height should be preserved with decimals")
    }
    
    @Test func testKeyWithSpecialCharacters() async throws {
        let frame = CGRect(x: 10, y: 20, width: 40, height: 40)
        
        // Test unicode characters
        let key1 = Key(keyCode: 48, legend: "⇥", frame: frame, row: 1, column: 0) // Tab
        #expect(key1.baseLegend == "⇥", "Should support unicode symbols")
        
        // Test dual labels with special characters
        let key2 = Key(keyCode: 33, baseLegend: "[", shiftLegend: "{", frame: frame, row: 1, column: 10)
        #expect(key2.baseLegend == "[", "Should support bracket characters")
        #expect(key2.shiftLegend == "{", "Should support brace characters")
        
        // Test emoji (though not typical for keyboards)
        let key3 = Key(keyCode: 999, baseLegend: "😀", shiftLegend: "😎", frame: frame, row: 0, column: 0)
        #expect(key3.baseLegend == "😀", "Should support emoji in base legend")
        #expect(key3.shiftLegend == "😎", "Should support emoji in shift legend")
    }
    
    @Test func testKeyColorVariations() async throws {
        let frame = CGRect(x: 10, y: 20, width: 40, height: 40)
        
        // Test different color types
        let clearKey = Key(keyCode: 18, legend: "1", frame: frame, row: 0, column: 1, backgroundColor: .clear)
        let redKey = Key(keyCode: 19, legend: "2", frame: frame, row: 0, column: 2, backgroundColor: .red)
        let customKey = Key(keyCode: 20, legend: "3", frame: frame, row: 0, column: 3, 
                           backgroundColor: Color(red: 0.5, green: 0.7, blue: 0.9))
        
        #expect(clearKey.backgroundColor == .clear, "Should support clear color")
        #expect(redKey.backgroundColor == .red, "Should support system colors")
        #expect(customKey.backgroundColor == Color(red: 0.5, green: 0.7, blue: 0.9), "Should support custom colors")
    }
    
    @Test func testKeyRowAndColumnBoundaries() async throws {
        let frame = CGRect(x: 10, y: 20, width: 40, height: 40)
        
        // Test boundary values
        let minKey = Key(keyCode: 0, legend: "Min", frame: frame, row: 0, column: 0)
        let maxKey = Key(keyCode: 65535, legend: "Max", frame: frame, row: 999, column: 999)
        
        #expect(minKey.row == 0, "Should support row 0")
        #expect(minKey.column == 0, "Should support column 0") 
        #expect(maxKey.row == 999, "Should support large row values")
        #expect(maxKey.column == 999, "Should support large column values")
        #expect(maxKey.keyCode == 65535, "Should support max CGKeyCode value")
    }
    
    @Test func testKeyCodeTypes() async throws {
        let frame = CGRect(x: 10, y: 20, width: 40, height: 40)
        
        // Test different key code ranges
        let lowKey = Key(keyCode: 0, legend: "A", frame: frame, row: 0, column: 0)
        let midKey = Key(keyCode: 50, legend: "`", frame: frame, row: 0, column: 0)  
        let highKey = Key(keyCode: 126, legend: "Up", frame: frame, row: 0, column: 0)
        
        #expect(lowKey.keyCode == 0, "Should support keyCode 0")
        #expect(midKey.keyCode == 50, "Should support mid-range keyCodes")
        #expect(highKey.keyCode == 126, "Should support high keyCodes (arrows, etc.)")
    }
}