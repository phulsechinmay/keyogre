// ABOUTME: Integration tests for ZMK keyboard loading and startup functionality
// ABOUTME: Tests end-to-end flow from file parsing to keyboard layout creation and startup

import XCTest
@testable import KeyOgre

class ZMKIntegrationTests: XCTestCase {
    
    let dtsiPath = "/Users/phulsechinmay/Desktop/Projects/keyogre/KeyOgre/ZmkFiles/typhon.dtsi"
    let keymapPath = "/Users/phulsechinmay/Desktop/Projects/keyogre/KeyOgre/ZmkFiles/typhon.keymap"
    
    override func setUp() {
        super.setUp()
        // Ensure ZMK files exist before running tests
        XCTAssertTrue(FileManager.default.fileExists(atPath: dtsiPath), "DTSI file should exist")
        XCTAssertTrue(FileManager.default.fileExists(atPath: keymapPath), "Keymap file should exist")
    }
    
    func testCommentRemovalUtility() {
        // Test the comment removal utility with various comment types
        let testContent = """
        // Line comment at start
        normal code here // Inline comment
        /* Block comment */ more code
        /* Multi-line
           block comment
           continues here */ final code
        // Final line comment
        """
        
        let cleaned = ZMKCommentRemover.removeComments(from: testContent)
        
        // Should remove all comments but preserve structure
        XCTAssertFalse(cleaned.contains("//"), "Should remove line comments")
        XCTAssertFalse(cleaned.contains("/*"), "Should remove block comment starts")
        XCTAssertFalse(cleaned.contains("*/"), "Should remove block comment ends")
        XCTAssertTrue(cleaned.contains("normal code here"), "Should preserve non-comment content")
        XCTAssertTrue(cleaned.contains("more code"), "Should preserve content after block comments")
        XCTAssertTrue(cleaned.contains("final code"), "Should preserve content after multi-line comments")
    }
    
    func testZMKFileParsingWithComments() {
        do {
            // Test DTSI parsing
            let physicalLayout = try ZMKDtsiParser.parsePhysicalLayout(from: dtsiPath)
            
            XCTAssertEqual(physicalLayout.name, "typhon_layout", "Should extract correct layout name")
            XCTAssertEqual(physicalLayout.displayName, "Typhon", "Should extract correct display name")
            XCTAssertEqual(physicalLayout.keyPositions.count, 60, "Should extract 60 key positions for Typhon")
            
            // Verify some key positions
            let firstKey = physicalLayout.keyPositions[0]
            XCTAssertEqual(firstKey.x, 0, "First key X position should be 0")
            XCTAssertEqual(firstKey.y, 50, "First key Y position should be 50")
            XCTAssertEqual(firstKey.width, 100, "Key width should be 100")
            XCTAssertEqual(firstKey.height, 100, "Key height should be 100")
            
            // Test keymap parsing
            let keymap = try ZMKKeymapParser.parseKeymap(from: keymapPath)
            
            XCTAssertEqual(keymap.name, "typhon", "Should extract correct keymap name")
            XCTAssertGreaterThanOrEqual(keymap.layers.count, 1, "Should have at least one layer")
            
            // Verify default layer
            guard let defaultLayer = keymap.defaultLayer else {
                XCTFail("Should have a default layer")
                return
            }
            
            XCTAssertEqual(defaultLayer.name, "default_layer", "Default layer should be named 'default_layer'")
            XCTAssertEqual(defaultLayer.bindings.count, 60, "Default layer should have 60 bindings")
            
            // Verify some key bindings
            XCTAssertEqual(defaultLayer.bindings[0], "&kp GRAVE", "First binding should be grave key")
            XCTAssertEqual(defaultLayer.bindings[1], "&kp N1", "Second binding should be number 1")
            XCTAssertEqual(defaultLayer.bindings[12], "&kp TAB", "Tab key should be at position 12")
            
        } catch {
            XCTFail("Failed to parse ZMK files: \(error)")
        }
    }
    
    func testZMKKeyboardLayoutCreation() {
        do {
            // Parse files
            let physicalLayout = try ZMKDtsiParser.parsePhysicalLayout(from: dtsiPath)
            let keymap = try ZMKKeymapParser.parseKeymap(from: keymapPath)
            
            // Create ZMK keyboard layout
            let zmkLayout = ZMKKeyboardLayout(physicalLayout: physicalLayout, keymap: keymap, withColors: false)
            
            // Verify layout properties
            XCTAssertEqual(zmkLayout.name, "typhon_layout", "Layout name should match")
            XCTAssertEqual(zmkLayout.displayName, "Typhon", "Display name should match")
            XCTAssertEqual(zmkLayout.keys.count, 60, "Should have 60 keys")
            
            // Verify total size is reasonable
            let totalSize = zmkLayout.totalSize
            XCTAssertGreaterThan(totalSize.width, 100, "Layout width should be reasonable")
            XCTAssertGreaterThan(totalSize.height, 100, "Layout height should be reasonable")
            
            // Verify key mapping works
            let firstKey = zmkLayout.keys[0]
            XCTAssertEqual(firstKey.baseLegend, "`", "First key should display backtick")
            
            let secondKey = zmkLayout.keys[1]
            XCTAssertEqual(secondKey.baseLegend, "1", "Second key should display 1")
            
            // Verify key positioning
            XCTAssertNotNil(zmkLayout.keyForKeyCode(0), "Should be able to find keys by code")
            
        } catch {
            XCTFail("Failed to create ZMK keyboard layout: \(error)")
        }
    }
    
    func testKeyCodeMapping() {
        // Test various ZMK key code mappings
        let testMappings: [(String, String)] = [
            ("&kp GRAVE", "`"),
            ("&kp N1", "1"),
            ("&kp Q", "Q"),
            ("&kp TAB", "⇥"),
            ("&kp BSPC", "⌫"),
            ("&kp LSHFT", "⇧"),
            ("&kp SPACE", ""),
            ("&mo 1", "MO1"),
            ("&trans", "▽"),
            ("&bt BT_SEL 0", "BT0"),
            ("&bt BT_CLR", "BT CLR")
        ]
        
        for (input, expected) in testMappings {
            let result = KeyCodeMapper.mapKeyBinding(input)
            XCTAssertEqual(result, expected, "Mapping for \(input) should be \(expected)")
        }
    }
    
    func testKeyboardLayoutManagerStartup() {
        // Test that KeyboardLayoutManager can load ZMK layout on startup
        let layoutManager = KeyboardLayoutManager.shared
        
        // Should have loaded ZMK layout as default
        XCTAssertEqual(layoutManager.selectedLayoutName, "Typhon (ZMK)", "Should default to Typhon ZMK")
        
        // Verify layout properties
        let currentLayout = layoutManager.currentLayout
        XCTAssertEqual(currentLayout.keys.count, 60, "Current layout should have 60 keys")
        
        // Verify it's actually a ZMK layout
        XCTAssertTrue(currentLayout is ZMKKeyboardLayout, "Current layout should be ZMK type")
        
        if let zmkLayout = currentLayout as? ZMKKeyboardLayout {
            XCTAssertEqual(zmkLayout.displayName, "Typhon", "Should be Typhon layout")
        }
        
        // Test layout info
        let layoutInfo = layoutManager.currentLayoutInfo
        XCTAssertTrue(layoutInfo.contains("ZMK"), "Layout info should mention ZMK")
        XCTAssertTrue(layoutInfo.contains("Typhon"), "Layout info should mention Typhon")
        XCTAssertTrue(layoutInfo.contains("60"), "Layout info should mention 60 keys")
    }
    
    func testZMKLayoutSwitching() {
        let layoutManager = KeyboardLayoutManager.shared
        
        // Start with ZMK layout
        XCTAssertEqual(layoutManager.selectedLayoutName, "Typhon (ZMK)")
        
        // Switch to ANSI
        layoutManager.switchToLayout(named: "ANSI 60%")
        XCTAssertEqual(layoutManager.selectedLayoutName, "ANSI 60%")
        XCTAssertTrue(layoutManager.currentLayout is ANSI60KeyboardLayout)
        
        // Switch back to ZMK
        layoutManager.switchToLayout(named: "Typhon (ZMK)")
        XCTAssertEqual(layoutManager.selectedLayoutName, "Typhon (ZMK)")
        XCTAssertTrue(layoutManager.currentLayout is ZMKKeyboardLayout)
    }
    
    func testZMKLayoutIntegrationWithKeyEventTap() {
        // Test that ZMK layout works with key highlighting system
        let layoutManager = KeyboardLayoutManager.shared
        let zmkLayout = layoutManager.currentLayout
        
        // Test that we can find keys by keyCode (even though ZMK uses different mapping)
        let sampleKey = zmkLayout.keyForKeyCode(0)
        XCTAssertNotNil(sampleKey, "Should be able to find keys by keyCode")
        
        // Verify key properties
        if let key = sampleKey {
            XCTAssertFalse(key.baseLegend.isEmpty, "Key should have a legend")
            XCTAssertGreaterThan(key.frame.width, 0, "Key should have valid width")
            XCTAssertGreaterThan(key.frame.height, 0, "Key should have valid height")
        }
    }
    
    func testPerformanceOfZMKLoading() {
        // Test that ZMK loading performs reasonably well
        measure {
            do {
                let physicalLayout = try ZMKDtsiParser.parsePhysicalLayout(from: dtsiPath)
                let keymap = try ZMKKeymapParser.parseKeymap(from: keymapPath)
                let _ = ZMKKeyboardLayout(physicalLayout: physicalLayout, keymap: keymap, withColors: false)
            } catch {
                XCTFail("Failed to load ZMK layout: \(error)")
            }
        }
    }
}