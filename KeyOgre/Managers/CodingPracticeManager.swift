// ABOUTME: State management for coding practice mode including character validation and progress tracking
// ABOUTME: Handles user input processing, correctness checking, and display data generation

import Foundation
import SwiftUI
import Combine

class CodingPracticeManager: ObservableObject {
    @Published var state = CodingPracticeState()
    private let practiceContent = CodingPracticeContent()
    
    func processKeyInput(_ character: Character) {
        state.ensureLanguageProgressExists()
        let currentContent = getCurrentContent()
        guard state.getCurrentProgress().currentLineIndex < currentContent.count else { return }
        
        let currentLine = currentContent[state.getCurrentProgress().currentLineIndex]
        var progress = state.getCurrentProgress()
        
        guard progress.currentCharIndex < currentLine.count else { return }
        
        let expectedChar = currentLine[currentLine.index(currentLine.startIndex, offsetBy: progress.currentCharIndex)]
        let isCorrect = character == expectedChar
        
        // Record character result
        let characterResult = CharacterResult(character: character, isCorrect: isCorrect, timestamp: Date())
        progress.addCharacterResult(characterResult, lineIndex: progress.currentLineIndex)
        
        // Always advance position regardless of correctness
        progress.currentCharIndex += 1
        
        // Check if line is complete
        if progress.currentCharIndex >= currentLine.count {
            // Move to next line
            progress.currentLineIndex += 1
            progress.currentCharIndex = 0
            
            // Check if all content is complete
            if progress.currentLineIndex >= currentContent.count {
                progress.isComplete = true
            }
        }
        
        state.updateCurrentProgress(progress)
    }
    
    func processBackspace() {
        state.ensureLanguageProgressExists()
        var progress = state.getCurrentProgress()
        
        // Get typed results for current line to verify we have characters to delete
        let lineResult = progress.typedResults.first { $0.lineIndex == progress.currentLineIndex }
        let typedCharacterCount = lineResult?.characterResults.count ?? 0
        
        if progress.currentCharIndex > 0 && typedCharacterCount > 0 {
            // Remove last character from current position
            progress.removeLastCharacterResult(lineIndex: progress.currentLineIndex)
            progress.currentCharIndex -= 1
            
            // Ensure currentCharIndex doesn't go below the number of typed characters
            let newTypedCount = (lineResult?.characterResults.count ?? 1) - 1
            progress.currentCharIndex = max(progress.currentCharIndex, newTypedCount)
        } else if progress.currentLineIndex > 0 {
            // Move to previous line
            progress.currentLineIndex -= 1
            let currentContent = getCurrentContent()
            if progress.currentLineIndex < currentContent.count {
                let previousLine = currentContent[progress.currentLineIndex]
                // Set cursor to the end of the previous line based on typed characters
                let prevLineResult = progress.typedResults.first { $0.lineIndex == progress.currentLineIndex }
                progress.currentCharIndex = prevLineResult?.characterResults.count ?? 0
            }
        }
        
        state.updateCurrentProgress(progress)
    }
    
    func processEnterKey() {
        state.ensureLanguageProgressExists()
        let currentContent = getCurrentContent()
        guard state.getCurrentProgress().currentLineIndex < currentContent.count else { return }
        
        let currentLine = currentContent[state.getCurrentProgress().currentLineIndex]
        var progress = state.getCurrentProgress()
        
        // Only allow enter if we've typed the complete line correctly
        if progress.currentCharIndex >= currentLine.count {
            progress.currentLineIndex += 1
            progress.currentCharIndex = 0
            
            // Check if all content is complete
            if progress.currentLineIndex >= currentContent.count {
                progress.isComplete = true
            }
            
            state.updateCurrentProgress(progress)
        }
    }
    
    func getDisplayData() -> CodingDisplayData {
        let currentContent = getCurrentContent()
        let progress = state.getCurrentProgress()
        
        // Generate 5 lines: 2 above + current + 2 below
        var allLines: [String] = []
        var highlights: [Int: [CharacterHighlight]] = [:]
        
        let currentLineIndex = progress.currentLineIndex
        
        // Add 2 lines above (if they exist)
        for i in 0..<2 {
            let lineIndex = currentLineIndex - 2 + i
            if lineIndex >= 0 && lineIndex < currentContent.count {
                allLines.append(currentContent[lineIndex])
                highlights[i] = generateHighlightsForCompletedLine(lineIndex: lineIndex)
            } else {
                allLines.append("")
            }
        }
        
        // Add current line
        if currentLineIndex < currentContent.count {
            allLines.append(currentContent[currentLineIndex])
            highlights[2] = generateHighlightsForCurrentLine()
        } else {
            allLines.append("")
        }
        
        // Add 2 lines below (if they exist)
        for i in 0..<2 {
            let lineIndex = currentLineIndex + 1 + i
            if lineIndex < currentContent.count {
                allLines.append(currentContent[lineIndex])
                // Future lines have no highlighting
            } else {
                allLines.append("")
            }
        }
        
        let showEnterIndicator = shouldShowEnterIndicator()
        let currentChar = getCurrentCharacterToType()
        
        return CodingDisplayData(
            allLines: allLines,
            highlights: highlights,
            showEnterIndicator: showEnterIndicator,
            currentCharacter: currentChar
        )
    }
    
    func restartCurrentLanguage() {
        state.languageProgress[state.currentLanguage] = LanguageProgress()
    }
    
    func switchLanguage(to language: ProgrammingLanguage) {
        state.currentLanguage = language
    }
    
    // MARK: - Private Methods
    
    private func getCurrentContent() -> [String] {
        return practiceContent.getCodeLines(for: state.currentLanguage)
    }
    
    private func generateHighlightsForCompletedLine(lineIndex: Int) -> [CharacterHighlight] {
        guard let lineResult = state.getCurrentProgress().typedResults.first(where: { $0.lineIndex == lineIndex }) else {
            return []
        }
        
        return lineResult.characterResults.enumerated().map { index, result in
            CharacterHighlight(
                index: index,
                state: result.isCorrect ? .correct : .incorrect,
                isCurrentChar: false
            )
        }
    }
    
    private func generateHighlightsForCurrentLine() -> [CharacterHighlight] {
        let progress = state.getCurrentProgress()
        guard let lineResult = progress.getCurrentLineResult() else { return [] }
        
        var highlights: [CharacterHighlight] = []
        
        // Add highlights for typed characters
        for (index, result) in lineResult.characterResults.enumerated() {
            highlights.append(CharacterHighlight(
                index: index,
                state: result.isCorrect ? .correct : .incorrect,
                isCurrentChar: false
            ))
        }
        
        // Add highlight for current character to type
        if progress.currentCharIndex < getCurrentContent()[progress.currentLineIndex].count {
            highlights.append(CharacterHighlight(
                index: progress.currentCharIndex,
                state: .current,
                isCurrentChar: true
            ))
        }
        
        return highlights
    }
    
    private func shouldShowEnterIndicator() -> Bool {
        let progress = state.getCurrentProgress()
        let currentContent = getCurrentContent()
        
        guard progress.currentLineIndex < currentContent.count else { return false }
        
        let currentLine = currentContent[progress.currentLineIndex]
        return progress.currentCharIndex >= currentLine.count
    }
    
    private func getCurrentCharacterToType() -> Character? {
        let progress = state.getCurrentProgress()
        let currentContent = getCurrentContent()
        
        guard progress.currentLineIndex < currentContent.count else { return nil }
        
        let currentLine = currentContent[progress.currentLineIndex]
        guard progress.currentCharIndex < currentLine.count else { return nil }
        
        return currentLine[currentLine.index(currentLine.startIndex, offsetBy: progress.currentCharIndex)]
    }
}