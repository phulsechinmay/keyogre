// ABOUTME: Parser for ZMK .keymap files to extract key bindings and layer definitions
// ABOUTME: Parses devicetree keymap syntax to extract layer bindings and key assignments

import Foundation

class ZMKKeymapParser {
    
    enum ParseError: Error {
        case fileNotFound
        case invalidFormat
        case noKeymap
        case noLayers
    }
    
    static func parseKeymap(from filePath: String) throws -> ZMKKeymap {
        print("🔍 ZMKKeymapParser: Attempting to read file at: \(filePath)")
        
        // Check if file exists first
        guard FileManager.default.fileExists(atPath: filePath) else {
            print("❌ ZMKKeymapParser: File does not exist at path: \(filePath)")
            throw ParseError.fileNotFound
        }
        
        do {
            let content = try String(contentsOfFile: filePath, encoding: .utf8)
            print("✅ ZMKKeymapParser: Successfully read file, content length: \(content.count)")
            return try parseKeymap(from: content, fileName: URL(fileURLWithPath: filePath).lastPathComponent)
        } catch {
            print("❌ ZMKKeymapParser: Failed to read file content: \(error)")
            throw ParseError.fileNotFound
        }
    }
    
    static func parseKeymap(from content: String, fileName: String) throws -> ZMKKeymap {
        print("🔍 ZMKKeymapParser: Removing comments from content...")
        
        // Remove comments before parsing
        let cleanedContent = ZMKCommentRemover.removeComments(from: content)
        print("   Original content: \(content.count) characters")
        print("   Cleaned content: \(cleanedContent.count) characters")
        
        // Extract keymap name from file name
        let keymapName = fileName.replacingOccurrences(of: ".keymap", with: "")
        
        // Extract all layers
        let layers = try extractLayers(from: cleanedContent)
        
        if layers.isEmpty {
            throw ParseError.noLayers
        }
        
        return ZMKKeymap(name: keymapName, layers: layers)
    }
    
    private static func extractLayers(from content: String) throws -> [ZMKLayer] {
        var layers: [ZMKLayer] = []
        
        print("🔍 ZMKKeymapParser: Extracting layers from cleaned content...")
        
        // Improved pattern to match layer definitions after comment removal
        // This will match: layer_name { ... bindings = < ... >; } and stop at the first >;
        let layerPattern = #"(\w+_layer)\s*\{.*?bindings\s*=\s*<(.*?)>\s*;"#
        let layerRegex = try NSRegularExpression(pattern: layerPattern, options: [.dotMatchesLineSeparators])
        let contentRange = NSRange(content.startIndex..<content.endIndex, in: content)
        
        let matches = layerRegex.matches(in: content, options: [], range: contentRange)
        print("   Found \(matches.count) layer matches")
        
        for (index, match) in matches.enumerated() {
            guard match.numberOfRanges == 3 else { 
                print("   Skipping match \(index): invalid range count (\(match.numberOfRanges))")
                continue 
            }
            
            let layerName = String(content[Range(match.range(at: 1), in: content)!])
            let bindingsSection = String(content[Range(match.range(at: 2), in: content)!])
            
            print("   Processing layer: \(layerName)")
            print("   Bindings section length: \(bindingsSection.count)")
            
            // Parse bindings from the bindings section
            let bindings = parseBindings(from: bindingsSection)
            print("   Parsed \(bindings.count) bindings")
            
            if !bindings.isEmpty {
                let displayName = layerName.replacingOccurrences(of: "_layer", with: "")
                    .replacingOccurrences(of: "_", with: " ")
                    .capitalized
                
                let layer = ZMKLayer(name: layerName, displayName: displayName, bindings: bindings)
                layers.append(layer)
                print("   ✅ Added layer: \(displayName)")
            } else {
                print("   ⚠️ Skipping layer \(layerName): no bindings found")
            }
        }
        
        print("🔍 ZMKKeymapParser: Total layers extracted: \(layers.count)")
        return layers
    }
    
    private static func parseBindings(from bindingsSection: String) -> [String] {
        var bindings: [String] = []
        
        print("     Parsing bindings from section...")
        
        // The content should already be comment-free, so we just need to normalize whitespace
        let normalizedSection = bindingsSection
            .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        print("     Normalized section: \(normalizedSection.prefix(100))...")
        
        // Split by whitespace and filter out empty strings
        let tokens = normalizedSection.split(separator: " ").map { String($0) }
        print("     Found \(tokens.count) tokens")
        
        var currentBinding = ""
        
        for token in tokens {
            if token.hasPrefix("&") {
                // Start of a new binding
                if !currentBinding.isEmpty {
                    bindings.append(currentBinding.trimmingCharacters(in: .whitespaces))
                }
                currentBinding = token
            } else if !currentBinding.isEmpty {
                // Continue current binding
                currentBinding += " " + token
            }
        }
        
        // Add the last binding
        if !currentBinding.isEmpty {
            bindings.append(currentBinding.trimmingCharacters(in: .whitespaces))
        }
        
        print("     Extracted \(bindings.count) bindings")
        if !bindings.isEmpty {
            print("     First few bindings: \(bindings.prefix(5).joined(separator: ", "))")
        }
        
        return bindings
    }
    
    // Test function to validate parsing
    static func testParsing(filePath: String) {
        do {
            let keymap = try parseKeymap(from: filePath)
            print("Successfully parsed keymap: \(keymap.name)")
            print("Number of layers: \(keymap.layers.count)")
            
            for layer in keymap.layers {
                print("\nLayer: \(layer.displayName) (\(layer.name))")
                print("Number of bindings: \(layer.bindings.count)")
                
                // Print first few bindings with their mapped display names
                for (index, binding) in layer.bindings.prefix(10).enumerated() {
                    let displayName = KeyCodeMapper.mapKeyBinding(binding)
                    print("  Key \(index): \(binding) -> \(displayName)")
                }
                
                if layer.bindings.count > 10 {
                    print("  ... and \(layer.bindings.count - 10) more bindings")
                }
            }
        } catch {
            print("Failed to parse keymap: \(error)")
        }
    }
    
    // Specific test for lily58 keymap
    static func testLily58Keymap() {
        let lily58Path = "/Users/phulsechinmay/Desktop/Projects/keyogre/KeyOgre/ZmkFiles/lily58.keymap"
        print("🧪 Testing lily58.keymap parsing...")
        testParsing(filePath: lily58Path)
    }
    
    // Validation test to ensure no sensor-bindings contamination
    static func validateKeymapFile(_ filePath: String, expectedLayers: Int? = nil, expectedBindingsPerLayer: Int? = nil) -> Bool {
        do {
            let keymap = try parseKeymap(from: filePath)
            print("✅ Successfully parsed keymap: \(keymap.name)")
            print("   Layers: \(keymap.layers.count)")
            
            // Check expected layer count
            if let expected = expectedLayers {
                if keymap.layers.count == expected {
                    print("✅ Layer count matches expected (\(expected))")
                } else {
                    print("❌ Layer count mismatch - expected \(expected), got \(keymap.layers.count)")
                    return false
                }
            }
            
            // Check each layer
            for (index, layer) in keymap.layers.enumerated() {
                print("   Layer \(index + 1): \(layer.displayName) - \(layer.bindings.count) bindings")
                
                // Check for sensor-bindings contamination
                for binding in layer.bindings {
                    if binding.contains("sensor-bindings") {
                        print("❌ sensor-bindings contamination found in layer \(layer.displayName)")
                        return false
                    }
                }
                
                // Check expected bindings count if provided
                if let expectedCount = expectedBindingsPerLayer {
                    if layer.bindings.count != expectedCount {
                        print("❌ Layer \(layer.displayName) binding count mismatch - expected \(expectedCount), got \(layer.bindings.count)")
                        return false
                    }
                }
            }
            
            print("✅ No sensor-bindings contamination found")
            return true
        } catch {
            print("❌ Failed to parse keymap: \(error)")
            return false
        }
    }
}