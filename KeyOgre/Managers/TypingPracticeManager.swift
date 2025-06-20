// ABOUTME: State management for typing practice mode including word-based practice and progress tracking
// ABOUTME: Handles user input processing, word validation, and display data generation for word sequences

import Foundation
import SwiftUI
import Combine

class TypingPracticeManager: ObservableObject {
    @Published var state = TypingPracticeState()
    @Published var analyticsManager = TypingAnalyticsManager()
    
    init() {
        generateWordLines()
    }
    
    func processKeyInput(_ character: Character) {
        state.ensureLineProgressExists()
        guard state.currentLineIndex < state.wordLines.count else { return }
        
        let currentLine = state.wordLines[state.currentLineIndex]
        var progress = state.getCurrentProgress()
        
        guard state.currentCharIndex < currentLine.fullText.count else { return }
        
        let expectedChar = currentLine.fullText[currentLine.fullText.index(currentLine.fullText.startIndex, offsetBy: state.currentCharIndex)]
        let isCorrect = character == expectedChar
        
        // Record character result
        let characterResult = CharacterResult(character: character, isCorrect: isCorrect, timestamp: Date())
        progress.addCharacterResult(characterResult)
        
        // Send to analytics manager
        let context = getContextAroundCharacter(line: currentLine.fullText, index: state.currentCharIndex)
        analyticsManager.processCharacterInput(characterResult, expectedCharacter: expectedChar, context: context)
        
        // Always advance position regardless of correctness
        state.currentCharIndex += 1
        
        // Update state and trigger UI update
        state.updateCurrentProgress(progress)
        objectWillChange.send()
    }
    
    func processBackspace() {
        state.ensureLineProgressExists()
        var progress = state.getCurrentProgress()
        
        // Send to analytics manager
        analyticsManager.processBackspace()
        
        // Get typed results for current line to verify we have characters to delete
        let typedCharacterCount = progress.characterResults.count
        
        if state.currentCharIndex > 0 && typedCharacterCount > 0 {
            // Remove last character from current position
            progress.removeLastCharacterResult()
            state.currentCharIndex -= 1
            
            // Ensure currentCharIndex doesn't go below the number of typed characters
            let newTypedCount = progress.characterResults.count
            state.currentCharIndex = max(state.currentCharIndex, newTypedCount)
        } else if state.currentLineIndex > 0 {
            // Move to previous line
            state.currentLineIndex -= 1
            if state.currentLineIndex < state.wordLines.count {
                // Set cursor to the end of the previous line based on typed characters
                let prevProgress = state.wordLineProgress[state.currentLineIndex] ?? WordLineProgress(lineIndex: state.currentLineIndex)
                state.currentCharIndex = prevProgress.characterResults.count
            }
        }
        
        // Update state and trigger UI update
        state.updateCurrentProgress(progress)
        objectWillChange.send()
    }
    
    func processEnterKey() {
        state.ensureLineProgressExists()
        var progress = state.getCurrentProgress()
        
        // Check if we're at the end of content
        guard state.currentLineIndex < state.wordLines.count else { return }
        
        let currentLine = state.wordLines[state.currentLineIndex]
        
        // Allow enter if we've typed the complete line
        if state.currentCharIndex >= currentLine.fullText.count {
            // Send line completion to analytics
            analyticsManager.processLineCompletion()
            
            // Mark current line as complete
            progress.isComplete = true
            state.updateCurrentProgress(progress)
            
            // Move to next line
            state.currentLineIndex += 1
            state.currentCharIndex = 0
            
            // Check if all content is complete
            if state.currentLineIndex >= state.wordLines.count {
                state.isComplete = true
                // End analytics session when practice is complete
                let _ = analyticsManager.endSession()
            }
        }
        
        // Trigger UI update
        objectWillChange.send()
    }
    
    func getDisplayData() -> TypingDisplayData {
        let progress = state.getCurrentProgress()
        
        // Generate 5 lines: 2 above + current + 2 below
        var allLines: [String] = []
        var highlights: [Int: [CharacterHighlight]] = [:]
        
        let currentLineIndex = state.currentLineIndex
        
        // Add 2 lines above (if they exist)
        for i in 0..<2 {
            let lineIndex = currentLineIndex - 2 + i
            if lineIndex >= 0 && lineIndex < state.wordLines.count {
                allLines.append(state.wordLines[lineIndex].fullText)
                highlights[i] = generateHighlightsForCompletedLine(lineIndex: lineIndex)
            } else {
                allLines.append("")
            }
        }
        
        // Add current line
        if currentLineIndex < state.wordLines.count {
            allLines.append(state.wordLines[currentLineIndex].fullText)
            highlights[2] = generateHighlightsForCurrentLine()
        } else {
            allLines.append("")
        }
        
        // Add 2 lines below (if they exist)
        for i in 0..<2 {
            let lineIndex = currentLineIndex + 1 + i
            if lineIndex < state.wordLines.count {
                allLines.append(state.wordLines[lineIndex].fullText)
                // Future lines have no highlighting
            } else {
                allLines.append("")
            }
        }
        
        let showEnterIndicator = shouldShowEnterIndicator()
        let currentChar = getCurrentCharacterToType()
        
        return TypingDisplayData(
            allLines: allLines,
            highlights: highlights,
            showEnterIndicator: showEnterIndicator,
            currentCharacter: currentChar
        )
    }
    
    func restart() {
        // End current analytics session if active
        if analyticsManager.isSessionActive {
            let _ = analyticsManager.endSession()
        }
        
        // Reset state
        state = TypingPracticeState()
        generateWordLines()
        
        // Start new analytics session
        startAnalyticsSession()
        
        // Trigger UI update
        objectWillChange.send()
    }
    
    func startAnalyticsSession() {
        analyticsManager.startSession(mode: .typingPractice, language: nil)
    }
    
    func pauseAnalytics() {
        analyticsManager.pauseSession()
    }
    
    func resumeAnalytics() {
        analyticsManager.resumeSession()
    }
    
    // MARK: - Private Methods
    
    private func generateWordLines() {
        state.wordLines = TypingPracticeContent.generateWordLines(count: 50)
    }
    
    private func generateHighlightsForCompletedLine(lineIndex: Int) -> [CharacterHighlight] {
        guard let progress = state.wordLineProgress[lineIndex] else {
            return []
        }
        
        return progress.characterResults.enumerated().map { index, result in
            CharacterHighlight(
                index: index,
                state: result.isCorrect ? .correct : .incorrect,
                isCurrentChar: false
            )
        }
    }
    
    private func generateHighlightsForCurrentLine() -> [CharacterHighlight] {
        let progress = state.getCurrentProgress()
        
        var highlights: [CharacterHighlight] = []
        
        // Add highlights for typed characters
        for (index, result) in progress.characterResults.enumerated() {
            highlights.append(CharacterHighlight(
                index: index,
                state: result.isCorrect ? .correct : .incorrect,
                isCurrentChar: false
            ))
        }
        
        // Add highlight for current character to type
        if state.currentLineIndex < state.wordLines.count {
            let currentLine = state.wordLines[state.currentLineIndex]
            if state.currentCharIndex < currentLine.fullText.count {
                highlights.append(CharacterHighlight(
                    index: state.currentCharIndex,
                    state: .current,
                    isCurrentChar: true
                ))
            }
        }
        
        return highlights
    }
    
    private func shouldShowEnterIndicator() -> Bool {
        guard state.currentLineIndex < state.wordLines.count else { return false }
        
        let currentLine = state.wordLines[state.currentLineIndex]
        // Show enter indicator if line is complete
        return state.currentCharIndex >= currentLine.fullText.count
    }
    
    private func getCurrentCharacterToType() -> Character? {
        guard state.currentLineIndex < state.wordLines.count else { return nil }
        
        let currentLine = state.wordLines[state.currentLineIndex]
        guard state.currentCharIndex < currentLine.fullText.count else { return nil }
        
        return currentLine.fullText[currentLine.fullText.index(currentLine.fullText.startIndex, offsetBy: state.currentCharIndex)]
    }
    
    private func getContextAroundCharacter(line: String, index: Int) -> String {
        let contextRange = 3 // Characters before and after
        let startIndex = max(0, index - contextRange)
        let endIndex = min(line.count, index + contextRange + 1)
        
        let start = line.index(line.startIndex, offsetBy: startIndex)
        let end = line.index(line.startIndex, offsetBy: endIndex)
        
        return String(line[start..<end])
    }
}