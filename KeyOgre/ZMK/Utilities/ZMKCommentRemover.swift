// ABOUTME: Utility for removing comments from ZMK files before parsing
// ABOUTME: Handles both line comments (//) and block comments (/* */) while preserving structure

import Foundation

class ZMKCommentRemover {
    
    static func removeComments(from content: String) -> String {
        let lines = content.components(separatedBy: .newlines)
        var cleanedLines: [String] = []
        var inBlockComment = false
        
        for line in lines {
            let cleanedLine = removeCommentsFromLine(line, inBlockComment: &inBlockComment)
            cleanedLines.append(cleanedLine)
        }
        
        return cleanedLines.joined(separator: "\n")
    }
    
    private static func removeCommentsFromLine(_ line: String, inBlockComment: inout Bool) -> String {
        var result = ""
        var i = line.startIndex
        
        while i < line.endIndex {
            let currentChar = line[i]
            
            if inBlockComment {
                // Look for end of block comment */
                if currentChar == "*" && i < line.index(before: line.endIndex) {
                    let nextIndex = line.index(after: i)
                    if line[nextIndex] == "/" {
                        // End of block comment found
                        inBlockComment = false
                        i = line.index(after: nextIndex) // Skip past */
                        continue
                    }
                }
                // Skip this character as it's inside a block comment
                i = line.index(after: i)
            } else {
                // Not in block comment, check for comment starts
                if currentChar == "/" && i < line.index(before: line.endIndex) {
                    let nextIndex = line.index(after: i)
                    let nextChar = line[nextIndex]
                    
                    if nextChar == "/" {
                        // Line comment found - ignore rest of line
                        break
                    } else if nextChar == "*" {
                        // Block comment start found
                        inBlockComment = true
                        i = line.index(after: nextIndex) // Skip past /*
                        continue
                    }
                }
                
                // Regular character - add to result
                result.append(currentChar)
                i = line.index(after: i)
            }
        }
        
        return result
    }
    
    // Test function to validate comment removal
    static func test() {
        let testContent = """
        // This is a line comment
        normal code here
        /* This is a block comment */ more code
        /* Multi-line
           block comment
           continues here */ end
        // Another line comment
        """
        
        let cleaned = removeComments(from: testContent)
        print("Original:")
        print(testContent)
        print("\nCleaned:")
        print(cleaned)
        
        // Test with ZMK-like content
        let zmkTest = """
        typhon_layout: typhon_layout_0 {
            compatible = "zmk,physical-layout";
            display-name = "Typhon";
            /* Include vertical offsets of each column in key layout */
            keys =
            // Left half keys
            <&key_physical_attrs 100 100    0  50 0 0 0>, // First key
            <&key_physical_attrs 100 100  100  50 0 0 0>; // Second key
        };
        """
        
        let zmkCleaned = removeComments(from: zmkTest)
        print("\nZMK Test Original:")
        print(zmkTest)
        print("\nZMK Test Cleaned:")
        print(zmkCleaned)
    }
}