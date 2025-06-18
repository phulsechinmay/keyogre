// ABOUTME: Parser for ZMK .dtsi files to extract physical keyboard layout configuration
// ABOUTME: Parses devicetree syntax to extract key_physical_attrs and layout metadata

import Foundation

class ZMKDtsiParser {
    
    enum ParseError: Error {
        case fileNotFound
        case invalidFormat
        case noPhysicalLayout
        case invalidKeyAttributes
    }
    
    static func parsePhysicalLayout(from filePath: String) throws -> ZMKPhysicalLayout {
        print("🔍 ZMKDtsiParser: Attempting to read file at: \(filePath)")
        
        // Check if file exists first
        guard FileManager.default.fileExists(atPath: filePath) else {
            print("❌ ZMKDtsiParser: File does not exist at path: \(filePath)")
            throw ParseError.fileNotFound
        }
        
        do {
            let content = try String(contentsOfFile: filePath, encoding: .utf8)
            print("✅ ZMKDtsiParser: Successfully read file, content length: \(content.count)")
            return try parsePhysicalLayout(from: content, fileName: URL(fileURLWithPath: filePath).lastPathComponent)
        } catch {
            print("❌ ZMKDtsiParser: Failed to read file content: \(error)")
            throw ParseError.fileNotFound
        }
    }
    
    static func parsePhysicalLayout(from content: String, fileName: String) throws -> ZMKPhysicalLayout {
        print("🔍 ZMKDtsiParser: Removing comments from content...")
        
        // Remove comments before parsing
        let cleanedContent = ZMKCommentRemover.removeComments(from: content)
        print("   Original content: \(content.count) characters")
        print("   Cleaned content: \(cleanedContent.count) characters")
        
        // Extract layout name and display name
        let (layoutName, displayName) = try extractLayoutInfo(from: cleanedContent)
        
        // Extract key positions
        let keyPositions = try extractKeyPositions(from: cleanedContent)
        
        return ZMKPhysicalLayout(
            name: layoutName,
            displayName: displayName,
            keyPositions: keyPositions
        )
    }
    
    private static func extractLayoutInfo(from content: String) throws -> (String, String) {
        // Look for layout definition: layoutname: layoutname_0 {
        let layoutPattern = #"(\w+_layout):\s*(\w+_layout_\d+)\s*\{"#
        let layoutRegex = try NSRegularExpression(pattern: layoutPattern, options: [])
        let contentRange = NSRange(content.startIndex..<content.endIndex, in: content)
        
        guard let layoutMatch = layoutRegex.firstMatch(in: content, options: [], range: contentRange) else {
            throw ParseError.noPhysicalLayout
        }
        
        let layoutName = String(content[Range(layoutMatch.range(at: 1), in: content)!])
        
        // Look for display-name property
        let displayNamePattern = #"display-name\s*=\s*"([^"]+)""#
        let displayNameRegex = try NSRegularExpression(pattern: displayNamePattern, options: [])
        
        var displayName = layoutName.replacingOccurrences(of: "_layout", with: "").capitalized
        
        if let displayMatch = displayNameRegex.firstMatch(in: content, options: [], range: contentRange) {
            displayName = String(content[Range(displayMatch.range(at: 1), in: content)!])
        }
        
        return (layoutName, displayName)
    }
    
    private static func extractKeyPositions(from content: String) throws -> [ZMKKeyPosition] {
        // Find the keys section
        let keysPattern = #"keys\s*=\s*\n(.*?);"#
        let keysRegex = try NSRegularExpression(pattern: keysPattern, options: [.dotMatchesLineSeparators])
        let contentRange = NSRange(content.startIndex..<content.endIndex, in: content)
        
        guard let keysMatch = keysRegex.firstMatch(in: content, options: [], range: contentRange) else {
            throw ParseError.noPhysicalLayout
        }
        
        let keysSection = String(content[Range(keysMatch.range(at: 1), in: content)!])
        
        // Extract individual key definitions
        let keyPattern = #"<&key_physical_attrs\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)>"#
        let keyRegex = try NSRegularExpression(pattern: keyPattern, options: [])
        let keysSectionRange = NSRange(keysSection.startIndex..<keysSection.endIndex, in: keysSection)
        
        let matches = keyRegex.matches(in: keysSection, options: [], range: keysSectionRange)
        
        var keyPositions: [ZMKKeyPosition] = []
        
        for (index, match) in matches.enumerated() {
            guard match.numberOfRanges == 8 else { // 7 capture groups + full match
                continue
            }
            
            let width = Int(String(keysSection[Range(match.range(at: 1), in: keysSection)!])) ?? 100
            let height = Int(String(keysSection[Range(match.range(at: 2), in: keysSection)!])) ?? 100
            let x = Int(String(keysSection[Range(match.range(at: 3), in: keysSection)!])) ?? 0
            let y = Int(String(keysSection[Range(match.range(at: 4), in: keysSection)!])) ?? 0
            let rotation = Int(String(keysSection[Range(match.range(at: 5), in: keysSection)!])) ?? 0
            let rotationX = Int(String(keysSection[Range(match.range(at: 6), in: keysSection)!])) ?? 0
            let rotationY = Int(String(keysSection[Range(match.range(at: 7), in: keysSection)!])) ?? 0
            
            let keyPosition = ZMKKeyPosition(
                width: width,
                height: height,
                x: x,
                y: y,
                rotation: rotation,
                rotationX: rotationX,
                rotationY: rotationY,
                index: index
            )
            
            keyPositions.append(keyPosition)
        }
        
        if keyPositions.isEmpty {
            throw ParseError.invalidKeyAttributes
        }
        
        return keyPositions
    }
    
    // Test function to validate parsing
    static func testParsing(filePath: String) {
        do {
            let layout = try parsePhysicalLayout(from: filePath)
            print("Successfully parsed layout: \(layout.displayName)")
            print("Layout name: \(layout.name)")
            print("Number of keys: \(layout.keyPositions.count)")
            print("Total size: \(layout.totalSize)")
            
            // Print first few key positions
            for (index, key) in layout.keyPositions.prefix(5).enumerated() {
                print("Key \(index): pos(\(key.x), \(key.y)) size(\(key.width)x\(key.height))")
            }
        } catch {
            print("Failed to parse layout: \(error)")
        }
    }
}