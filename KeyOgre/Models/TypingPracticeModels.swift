// ABOUTME: Data models for typing practice mode including word-based practice state and progress tracking
// ABOUTME: Defines word lines, practice state, and display data structures for word-based typing practice

import Foundation
import SwiftUI

enum DifficultyLevel: String, CaseIterable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
}

enum TypingTextType: String, CaseIterable, Identifiable {
    case randomWords = "Random words"
    case hamlet = "Hamlet"
    
    var id: String { rawValue }
    
    var displayName: String {
        return rawValue
    }
    
    var icon: String {
        switch self {
        case .randomWords: return "textformat.abc"
        case .hamlet: return "theatermasks"
        }
    }
}

extension TypingTextType: PracticeControlOption {}

struct WordLine {
    let words: [String]
    let fullText: String // Joined with spaces
    let difficulty: DifficultyLevel
    let lineIndex: Int
    
    init(words: [String], difficulty: DifficultyLevel, lineIndex: Int) {
        self.words = words
        self.fullText = words.joined(separator: " ")
        self.difficulty = difficulty
        self.lineIndex = lineIndex
    }
}

struct TypingPracticeState {
    var currentTextType: TypingTextType = .randomWords
    var currentLineIndex: Int = 0
    var currentCharIndex: Int = 0
    var wordLines: [WordLine] = []
    var wordLineProgress: [Int: WordLineProgress] = [:]
    var isComplete: Bool = false
    
    func getCurrentProgress() -> WordLineProgress {
        return wordLineProgress[currentLineIndex] ?? WordLineProgress(lineIndex: currentLineIndex)
    }
    
    mutating func updateCurrentProgress(_ progress: WordLineProgress) {
        wordLineProgress[currentLineIndex] = progress
    }
    
    mutating func ensureLineProgressExists() {
        if wordLineProgress[currentLineIndex] == nil {
            wordLineProgress[currentLineIndex] = WordLineProgress(lineIndex: currentLineIndex)
        }
    }
    
    func getCurrentWordLine() -> WordLine? {
        guard currentLineIndex < wordLines.count else { return nil }
        return wordLines[currentLineIndex]
    }
}

struct WordLineProgress {
    let lineIndex: Int
    var characterResults: [CharacterResult] = []
    var isComplete: Bool = false
    
    init(lineIndex: Int) {
        self.lineIndex = lineIndex
    }
    
    mutating func addCharacterResult(_ result: CharacterResult) {
        characterResults.append(result)
    }
    
    mutating func removeLastCharacterResult() {
        if !characterResults.isEmpty {
            characterResults.removeLast()
        }
    }
}

struct TypingDisplayData {
    let allLines: [String] // 5 lines: 2 above + current + 2 below
    let highlights: [Int: [CharacterHighlight]] // Line index -> highlights
    let showEnterIndicator: Bool
    let currentCharacter: Character?
}