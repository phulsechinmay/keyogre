// ABOUTME: Core analytics manager for real-time typing performance tracking and calculations
// ABOUTME: Handles session metrics, WPM/accuracy calculations, and error pattern analysis

import Foundation
import SwiftUI
import Combine

class TypingAnalyticsManager: ObservableObject {
    
    // MARK: - Published Properties
    @Published var currentSessionMetrics = SessionMetrics()
    @Published var realTimeAnalytics = RealTimeAnalytics(from: SessionMetrics())
    @Published var isSessionActive = false
    
    // MARK: - Private Properties
    private var currentMode: TypingMode = .codingPractice
    private var currentLanguage: ProgrammingLanguage?
    private var errorPatterns: [String: ErrorPattern] = [:]
    private var characterTimestamps: [Date] = []
    private var calculationTimer: Timer?
    private var inactivityTimer: Timer?
    private var lastActivityTime: Date = Date()
    
    // Pause tracking
    private var totalPausedTime: TimeInterval = 0
    private var pauseStartTime: Date?
    private var actualStartTime: Date?
    
    // MARK: - Constants
    private let wpmCalculationWindow: TimeInterval = 30.0 // 30 seconds rolling window
    private let standardWordLength: Int = 5 // Standard typing test word length
    private let minCharactersForWPM: Int = 10 // Minimum characters before calculating WPM
    private let inactivityTimeout: TimeInterval = 3.0 // Auto-pause after 3 seconds of inactivity
    
    // MARK: - Session Management
    
    func startSession(mode: TypingMode, language: ProgrammingLanguage?) {
        currentMode = mode
        currentLanguage = language
        currentSessionMetrics = SessionMetrics()
        characterTimestamps = []
        errorPatterns = [:]
        isSessionActive = true
        lastActivityTime = Date()
        
        // Reset pause tracking
        totalPausedTime = 0
        pauseStartTime = nil
        actualStartTime = nil
        
        // Start real-time calculation timer and inactivity monitoring
        startCalculationTimer()
        startInactivityTimer()
        
        print("📊 Analytics session started - Mode: \(mode.rawValue), Language: \(language?.rawValue ?? "None")")
    }
    
    func endSession() -> SessionSummary? {
        guard isSessionActive else { return nil }
        
        // Add any remaining pause time if session was paused when ending
        if let pauseStart = pauseStartTime {
            totalPausedTime += Date().timeIntervalSince(pauseStart)
            pauseStartTime = nil
        }
        
        isSessionActive = false
        stopCalculationTimer()
        stopInactivityTimer()
        
        // Final calculations
        updateRealTimeMetrics()
        
        // Create session summary
        let summary = SessionSummary(
            from: currentSessionMetrics,
            mode: currentMode,
            language: currentLanguage,
            errorPatterns: Array(errorPatterns.values)
        )
        
        // TODO: Save to persistent storage
        
        print("📊 Analytics session ended - Duration: \(Int(summary.duration))s, WPM: \(Int(summary.finalWPM)), Accuracy: \(Int(summary.accuracy))%")
        
        return summary
    }
    
    func pauseSession() {
        stopCalculationTimer()
        stopInactivityTimer()
        isSessionActive = false
        
        // Record pause start time
        pauseStartTime = Date()
        
        print("📊 Analytics session paused due to inactivity")
    }
    
    func resumeSession() {
        guard !isSessionActive else { return }
        
        // Add elapsed pause time to total
        if let pauseStart = pauseStartTime {
            totalPausedTime += Date().timeIntervalSince(pauseStart)
            pauseStartTime = nil
        }
        
        isSessionActive = true
        lastActivityTime = Date()
        startCalculationTimer()
        startInactivityTimer()
        print("📊 Analytics session resumed")
    }
    
    // MARK: - Character Input Processing
    
    func processCharacterInput(_ result: CharacterResult, expectedCharacter: Character, context: String? = nil) {
        // Auto-resume if session was paused
        if !isSessionActive {
            resumeSession()
        }
        
        guard isSessionActive else { return }
        
        // Set actual start time on first character input
        if actualStartTime == nil {
            actualStartTime = Date()
        }
        
        // Update activity time
        lastActivityTime = Date()
        resetInactivityTimer()
        
        currentSessionMetrics.charactersTyped += 1
        characterTimestamps.append(result.timestamp)
        
        if result.isCorrect {
            currentSessionMetrics.correctCharacters += 1
        } else {
            currentSessionMetrics.errorCount += 1
            recordErrorPattern(expected: expectedCharacter, typed: result.character, context: context)
        }
        
        // Remove old timestamps outside calculation window
        cleanupOldTimestamps()
    }
    
    func processBackspace() {
        // Auto-resume if session was paused
        if !isSessionActive {
            resumeSession()
        }
        
        guard isSessionActive else { return }
        
        // Update activity time
        lastActivityTime = Date()
        resetInactivityTimer()
        
        currentSessionMetrics.backspaceCount += 1
    }
    
    func processLineCompletion() {
        guard isSessionActive else { return }
        
        // Update activity time
        lastActivityTime = Date()
        resetInactivityTimer()
        
        currentSessionMetrics.linesCompleted += 1
    }
    
    // MARK: - Real-time Calculations
    
    private func startCalculationTimer() {
        calculationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateRealTimeMetrics()
        }
    }
    
    private func stopCalculationTimer() {
        calculationTimer?.invalidate()
        calculationTimer = nil
    }
    
    private func updateRealTimeMetrics() {
        updateActiveDuration()
        calculateWPMAndCPM()
        calculateAccuracy()
        
        // Update published analytics
        realTimeAnalytics = RealTimeAnalytics(from: currentSessionMetrics)
    }
    
    private func updateActiveDuration() {
        // Only calculate duration if typing has actually started
        guard let startTime = actualStartTime else {
            currentSessionMetrics.activeDuration = 0.0
            return
        }
        
        let totalDuration = Date().timeIntervalSince(startTime)
        
        // Calculate current pause time if session is paused
        let currentPauseTime: TimeInterval
        if let pauseStart = pauseStartTime {
            currentPauseTime = Date().timeIntervalSince(pauseStart)
        } else {
            currentPauseTime = 0
        }
        
        // Active duration = total duration - all pause time
        currentSessionMetrics.activeDuration = max(0, totalDuration - totalPausedTime - currentPauseTime)
    }
    
    private func calculateWPMAndCPM() {
        guard currentSessionMetrics.charactersTyped >= minCharactersForWPM else {
            currentSessionMetrics.currentWPM = 0.0
            currentSessionMetrics.currentCPM = 0.0
            return
        }
        
        let now = Date()
        let windowStart = now.addingTimeInterval(-wpmCalculationWindow)
        
        // Count characters typed in the rolling window
        let recentCharacters = characterTimestamps.filter { $0 >= windowStart }.count
        
        if recentCharacters > 0 {
            let timeElapsed = min(currentSessionMetrics.sessionDuration, wpmCalculationWindow)
            let minutes = timeElapsed / 60.0
            
            if minutes > 0 {
                // CPM calculation (more accurate for code typing)
                currentSessionMetrics.currentCPM = Double(recentCharacters) / minutes
                
                // WPM calculation (traditional typing metric)
                currentSessionMetrics.currentWPM = Double(recentCharacters) / Double(standardWordLength) / minutes
            }
        }
        
        // Fallback: use total session data if window is too small
        if currentSessionMetrics.currentWPM == 0 && currentSessionMetrics.activeDuration > 5.0 {
            let totalMinutes = currentSessionMetrics.activeDuration / 60.0
            currentSessionMetrics.currentCPM = Double(currentSessionMetrics.charactersTyped) / totalMinutes
            currentSessionMetrics.currentWPM = Double(currentSessionMetrics.charactersTyped) / Double(standardWordLength) / totalMinutes
        }
    }
    
    private func calculateAccuracy() {
        guard currentSessionMetrics.charactersTyped > 0 else {
            currentSessionMetrics.accuracy = 100.0
            return
        }
        
        currentSessionMetrics.accuracy = (Double(currentSessionMetrics.correctCharacters) / Double(currentSessionMetrics.charactersTyped)) * 100.0
    }
    
    // MARK: - Error Pattern Analysis
    
    private func recordErrorPattern(expected: Character, typed: Character, context: String?) {
        let patternKey = "\(expected)→\(typed)"
        
        if let existingPattern = errorPatterns[patternKey] {
            errorPatterns[patternKey] = ErrorPattern(
                expectedCharacter: expected,
                typedCharacter: typed,
                frequency: existingPattern.frequency + 1,
                timestamp: Date(),
                context: context
            )
        } else {
            errorPatterns[patternKey] = ErrorPattern(
                expectedCharacter: expected,
                typedCharacter: typed,
                frequency: 1,
                timestamp: Date(),
                context: context
            )
        }
    }
    
    // MARK: - Utility Methods
    
    private func cleanupOldTimestamps() {
        let cutoffTime = Date().addingTimeInterval(-wpmCalculationWindow * 2) // Keep extra buffer
        characterTimestamps = characterTimestamps.filter { $0 >= cutoffTime }
    }
    
    // MARK: - Public Analytics Getters
    
    func getSessionMetrics() -> SessionMetrics {
        return currentSessionMetrics
    }
    
    func getRealTimeAnalytics() -> RealTimeAnalytics {
        return realTimeAnalytics
    }
    
    func getErrorPatterns() -> [ErrorPattern] {
        return Array(errorPatterns.values).sorted { $0.frequency > $1.frequency }
    }
    
    func getTopErrorPatterns(limit: Int = 5) -> [ErrorPattern] {
        return Array(getErrorPatterns().prefix(limit))
    }
    
    // MARK: - Formatted Output
    
    func getFormattedWPM() -> String {
        let wpm = Int(currentSessionMetrics.currentWPM)
        return wpm > 0 ? "\(wpm)" : "—"
    }
    
    func getFormattedAccuracy() -> String {
        let accuracy = Int(currentSessionMetrics.accuracy)
        return "\(accuracy)%"
    }
    
    func getFormattedCPM() -> String {
        let cpm = Int(currentSessionMetrics.currentCPM)
        return cpm > 0 ? "\(cpm)" : "—"
    }
    
    // MARK: - Inactivity Timer Methods
    
    private func startInactivityTimer() {
        stopInactivityTimer()
        inactivityTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.checkInactivity()
        }
    }
    
    private func stopInactivityTimer() {
        inactivityTimer?.invalidate()
        inactivityTimer = nil
    }
    
    private func resetInactivityTimer() {
        if isSessionActive {
            stopInactivityTimer()
            startInactivityTimer()
        }
    }
    
    private func checkInactivity() {
        guard isSessionActive else { return }
        
        let timeSinceActivity = Date().timeIntervalSince(lastActivityTime)
        if timeSinceActivity >= inactivityTimeout {
            pauseSession()
        }
    }
}