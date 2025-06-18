// ABOUTME: Unit tests for ZMK file parsers to validate dtsi and keymap parsing
// ABOUTME: Tests physical layout extraction, keymap parsing, and key code mapping

import XCTest
@testable import KeyOgre

class ZMKParserTests: XCTestCase {
    
    func testKeyCodeMapping() {
        // Test basic key codes
        XCTAssertEqual(KeyCodeMapper.mapKeyBinding("&kp GRAVE"), "`")
        XCTAssertEqual(KeyCodeMapper.mapKeyBinding("&kp N1"), "1")
        XCTAssertEqual(KeyCodeMapper.mapKeyBinding("&kp Q"), "Q")
        XCTAssertEqual(KeyCodeMapper.mapKeyBinding("&kp SPACE"), "")
        XCTAssertEqual(KeyCodeMapper.mapKeyBinding("&kp BSPC"), "⌫")
        
        // Test modifiers
        XCTAssertEqual(KeyCodeMapper.mapKeyBinding("&kp LSHFT"), "⇧")
        XCTAssertEqual(KeyCodeMapper.mapKeyBinding("&kp LGUI"), "⌘")
        XCTAssertEqual(KeyCodeMapper.mapKeyBinding("&kp LALT"), "⌥")
        
        // Test special behaviors
        XCTAssertEqual(KeyCodeMapper.mapKeyBinding("&mo 1"), "MO1")
        XCTAssertEqual(KeyCodeMapper.mapKeyBinding("&trans"), "▽")
        
        // Test Bluetooth
        XCTAssertEqual(KeyCodeMapper.mapKeyBinding("&bt BT_SEL 0"), "BT0")
        XCTAssertEqual(KeyCodeMapper.mapKeyBinding("&bt BT_CLR"), "BT CLR")
        
        // Test unknown codes
        XCTAssertEqual(KeyCodeMapper.mapKeyBinding("&kp UNKNOWN"), "UNKNOWN")
    }
    
    func testDtsiParserWithSampleData() {
        let sampleDtsi = """
        / {
            typhon_layout: typhon_layout_0 {
                compatible = "zmk,physical-layout";
                display-name = "Typhon";
                transform = <&default_transform>;
                kscan = <&kscan0>;
                
                keys =
                <&key_physical_attrs 100 100    0  50 0 0 0>, <&key_physical_attrs 100 100  100  50 0 0 0>,
                <&key_physical_attrs 100 100    0 150 0 0 0>, <&key_physical_attrs 100 100  100 150 0 0 0>;
            };
        }
        """
        
        do {
            let layout = try ZMKDtsiParser.parsePhysicalLayout(from: sampleDtsi, fileName: "test.dtsi")
            
            XCTAssertEqual(layout.name, "typhon_layout")
            XCTAssertEqual(layout.displayName, "Typhon")
            XCTAssertEqual(layout.keyPositions.count, 4)
            
            // Test first key position
            let firstKey = layout.keyPositions[0]
            XCTAssertEqual(firstKey.width, 100)
            XCTAssertEqual(firstKey.height, 100)
            XCTAssertEqual(firstKey.x, 0)
            XCTAssertEqual(firstKey.y, 50)
            XCTAssertEqual(firstKey.index, 0)
            
            // Test second key position
            let secondKey = layout.keyPositions[1]
            XCTAssertEqual(secondKey.x, 100)
            XCTAssertEqual(secondKey.y, 50)
            XCTAssertEqual(secondKey.index, 1)
            
        } catch {
            XCTFail("Failed to parse dtsi: \(error)")
        }
    }
    
    func testKeymapParserWithSampleData() {
        let sampleKeymap = """
        / {
            keymap {
                compatible = "zmk,keymap";
                
                default_layer {
                    bindings = <
                    &kp GRAVE  &kp N1    &kp N2    &kp N3
                    &kp TAB    &kp Q     &kp W     &kp E
                    >;
                };
                
                lower_layer {
                    bindings = <
                    &bt BT_SEL 0   &bt BT_SEL 1   &trans   &trans
                    &trans         &trans         &trans   &trans
                    >;
                };
            };
        }
        """
        
        do {
            let keymap = try ZMKKeymapParser.parseKeymap(from: sampleKeymap, fileName: "test.keymap")
            
            XCTAssertEqual(keymap.name, "test")
            XCTAssertEqual(keymap.layers.count, 2)
            
            // Test default layer
            let defaultLayer = keymap.layers[0]
            XCTAssertEqual(defaultLayer.name, "default_layer")
            XCTAssertEqual(defaultLayer.displayName, "Default")
            XCTAssertEqual(defaultLayer.bindings.count, 8)
            XCTAssertEqual(defaultLayer.bindings[0], "&kp GRAVE")
            XCTAssertEqual(defaultLayer.bindings[1], "&kp N1")
            XCTAssertEqual(defaultLayer.bindings[4], "&kp TAB")
            
            // Test lower layer
            let lowerLayer = keymap.layers[1]
            XCTAssertEqual(lowerLayer.name, "lower_layer")
            XCTAssertEqual(lowerLayer.displayName, "Lower")
            XCTAssertEqual(lowerLayer.bindings.count, 8)
            XCTAssertEqual(lowerLayer.bindings[0], "&bt BT_SEL 0")
            XCTAssertEqual(lowerLayer.bindings[2], "&trans")
            
        } catch {
            XCTFail("Failed to parse keymap: \(error)")
        }
    }
    
    func testZMKKeyboardLayoutIntegration() {
        // Test that we can combine physical layout and keymap into a working layout
        let sampleDtsi = """
        / {
            test_layout: test_layout_0 {
                compatible = "zmk,physical-layout";
                display-name = "Test Layout";
                
                keys =
                <&key_physical_attrs 100 100    0  50 0 0 0>, <&key_physical_attrs 100 100  100  50 0 0 0>;
            };
        }
        """
        
        let sampleKeymap = """
        / {
            keymap {
                compatible = "zmk,keymap";
                
                default_layer {
                    bindings = <
                    &kp Q     &kp W
                    >;
                };
            };
        }
        """
        
        do {
            let physicalLayout = try ZMKDtsiParser.parsePhysicalLayout(from: sampleDtsi, fileName: "test.dtsi")
            let keymap = try ZMKKeymapParser.parseKeymap(from: sampleKeymap, fileName: "test.keymap")
            
            let zmkLayout = ZMKKeyboardLayout(physicalLayout: physicalLayout, keymap: keymap, withColors: false)
            
            XCTAssertEqual(zmkLayout.name, "test_layout")
            XCTAssertEqual(zmkLayout.displayName, "Test Layout")
            XCTAssertEqual(zmkLayout.keys.count, 2)
            
            // Test first key
            let firstKey = zmkLayout.keys[0]
            XCTAssertEqual(firstKey.baseLegend, "Q")
            XCTAssertEqual(firstKey.keyCode, 0)
            
            // Test second key
            let secondKey = zmkLayout.keys[1]
            XCTAssertEqual(secondKey.baseLegend, "W")
            XCTAssertEqual(secondKey.keyCode, 1)
            
        } catch {
            XCTFail("Failed to create ZMK layout: \(error)")
        }
    }
    
    func testZMKKeyFrameCalculation() {
        let zmkKey = ZMKKey(
            width: 100,
            height: 100,
            x: 200,
            y: 300,
            binding: "&kp Q",
            displayName: "Q",
            keyIndex: 0
        )
        
        let frame = zmkKey.frame
        let scale: CGFloat = 0.4
        
        XCTAssertEqual(frame.origin.x, 200 * scale)
        XCTAssertEqual(frame.origin.y, 300 * scale)
        XCTAssertEqual(frame.size.width, 100 * scale)
        XCTAssertEqual(frame.size.height, 100 * scale)
    }
    
    func testPhysicalLayoutTotalSize() {
        let keyPositions = [
            ZMKKeyPosition(width: 100, height: 100, x: 0, y: 0, index: 0),
            ZMKKeyPosition(width: 100, height: 100, x: 100, y: 0, index: 1),
            ZMKKeyPosition(width: 100, height: 100, x: 0, y: 100, index: 2)
        ]
        
        let layout = ZMKPhysicalLayout(name: "test", displayName: "Test", keyPositions: keyPositions)
        
        let scale: CGFloat = 0.4
        let expectedWidth = (200 * scale) + 20 // max x + width + padding
        let expectedHeight = (200 * scale) + 20 // max y + height + padding
        
        XCTAssertEqual(layout.totalSize.width, expectedWidth, accuracy: 1.0)
        XCTAssertEqual(layout.totalSize.height, expectedHeight, accuracy: 1.0)
    }
}