// ABOUTME: Data models for coding practice mode including language support and progress tracking
// ABOUTME: Defines programming languages, character results, and typing progress state structures

import Foundation
import SwiftUI

enum ProgrammingLanguage: String, CaseIterable, Identifiable {
    case python = "Python"
    case javascript = "JavaScript"
    case typescript = "TypeScript"
    case go = "Go"
    case rust = "Rust"
    
    var id: String { rawValue }
    
    var fileExtension: String {
        switch self {
        case .python: return "py"
        case .javascript: return "js"
        case .typescript: return "ts"
        case .go: return "go"
        case .rust: return "rs"
        }
    }
    
    var icon: String {
        switch self {
        case .python: return "number"
        case .javascript: return "j.square"
        case .typescript: return "t.square"
        case .go: return "g.square"
        case .rust: return "r.square"
        }
    }
}

extension ProgrammingLanguage: PracticeControlOption {
    var displayName: String {
        return rawValue
    }
}

enum MainWindowMode: String, CaseIterable {
    case freeform = "Freeform"
    case codingPractice = "Coding Practice"
    case typingPractice = "Typing Practice"
    
    var icon: String {
        switch self {
        case .freeform: return "text.cursor"
        case .codingPractice: return "chevron.left.forwardslash.chevron.right"
        case .typingPractice: return "keyboard"
        }
    }
    
    // Only show coding practice and typing practice in the tabbar
    static var visibleCases: [MainWindowMode] {
        return [.codingPractice, .typingPractice]
    }
}

struct CodingPracticeState {
    var currentLanguage: ProgrammingLanguage = .python
    var languageProgress: [ProgrammingLanguage: LanguageProgress] = [:]
    
    func getCurrentProgress() -> LanguageProgress {
        return languageProgress[currentLanguage] ?? LanguageProgress()
    }
    
    mutating func updateCurrentProgress(_ progress: LanguageProgress) {
        languageProgress[currentLanguage] = progress
    }
    
    mutating func ensureLanguageProgressExists() {
        if languageProgress[currentLanguage] == nil {
            languageProgress[currentLanguage] = LanguageProgress()
        }
    }
}

struct LanguageProgress {
    var currentLineIndex: Int = 0
    var currentCharIndex: Int = 0
    var typedResults: [LineTypingResult] = []
    var isComplete: Bool = false
    
    func getCurrentLineResult() -> LineTypingResult? {
        return typedResults.first { $0.lineIndex == currentLineIndex }
    }
    
    mutating func addCharacterResult(_ result: CharacterResult, lineIndex: Int) {
        // Find or create line result
        if let existingIndex = typedResults.firstIndex(where: { $0.lineIndex == lineIndex }) {
            var lineResult = typedResults[existingIndex]
            lineResult.characterResults.append(result)
            typedResults[existingIndex] = lineResult
        } else {
            let newLineResult = LineTypingResult(lineIndex: lineIndex, characterResults: [result])
            typedResults.append(newLineResult)
        }
    }
    
    mutating func removeLastCharacterResult(lineIndex: Int) {
        if let existingIndex = typedResults.firstIndex(where: { $0.lineIndex == lineIndex }) {
            var lineResult = typedResults[existingIndex]
            if !lineResult.characterResults.isEmpty {
                lineResult.characterResults.removeLast()
                typedResults[existingIndex] = lineResult
            }
        }
    }
}

struct LineTypingResult {
    let lineIndex: Int
    var characterResults: [CharacterResult]
}

struct CharacterResult {
    let character: Character
    let isCorrect: Bool
    let timestamp: Date
}

struct CodingDisplayData {
    let allLines: [String] // 5 lines: 2 above + current + 2 below
    let highlights: [Int: [CharacterHighlight]] // Line index -> highlights
    let showEnterIndicator: Bool
    let currentCharacter: Character?
}

