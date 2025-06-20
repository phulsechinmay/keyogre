// ABOUTME: Data models for typing analytics including session metrics and error tracking
// ABOUTME: Defines structures for real-time performance monitoring and historical data analysis

import Foundation
import SwiftUI

// MARK: - Typing Mode Enum
enum TypingMode: String, CaseIterable, Codable {
    case freeform = "Freeform"
    case codingPractice = "Coding Practice"
    case typingPractice = "Typing Practice"
    
    var id: String { rawValue }
}

// MARK: - Session Metrics
struct SessionMetrics {
    var startTime: Date
    var currentWPM: Double
    var currentCPM: Double
    var accuracy: Double
    var errorCount: Int
    var charactersTyped: Int
    var correctCharacters: Int
    var linesCompleted: Int
    var backspaceCount: Int
    var activeDuration: TimeInterval
    
    init() {
        self.startTime = Date()
        self.currentWPM = 0.0
        self.currentCPM = 0.0
        self.accuracy = 100.0
        self.errorCount = 0
        self.charactersTyped = 0
        self.correctCharacters = 0
        self.linesCompleted = 0
        self.backspaceCount = 0
        self.activeDuration = 0.0
    }
    
    var sessionDuration: TimeInterval {
        Date().timeIntervalSince(startTime)
    }
    
    var firstAttemptAccuracy: Double {
        guard charactersTyped > 0 else { return 100.0 }
        let firstAttemptCorrect = charactersTyped - errorCount
        return (Double(firstAttemptCorrect) / Double(charactersTyped)) * 100.0
    }
}

// MARK: - Session Summary
struct SessionSummary {
    let id: UUID
    let startTime: Date
    let endTime: Date
    let mode: TypingMode
    let language: ProgrammingLanguage?
    let duration: TimeInterval
    let finalWPM: Double
    let finalCPM: Double
    let accuracy: Double
    let firstAttemptAccuracy: Double
    let charactersTyped: Int
    let errorCount: Int
    let backspaceCount: Int
    let linesCompleted: Int
    let errorPatterns: [ErrorPattern]
    
    init(from metrics: SessionMetrics, mode: TypingMode, language: ProgrammingLanguage?, errorPatterns: [ErrorPattern]) {
        self.id = UUID()
        self.startTime = metrics.startTime
        self.endTime = Date()
        self.mode = mode
        self.language = language
        self.duration = metrics.sessionDuration
        self.finalWPM = metrics.currentWPM
        self.finalCPM = metrics.currentCPM
        self.accuracy = metrics.accuracy
        self.firstAttemptAccuracy = metrics.firstAttemptAccuracy
        self.charactersTyped = metrics.charactersTyped
        self.errorCount = metrics.errorCount
        self.backspaceCount = metrics.backspaceCount
        self.linesCompleted = metrics.linesCompleted
        self.errorPatterns = errorPatterns
    }
}

// MARK: - Error Pattern
struct ErrorPattern {
    let expectedCharacter: Character
    let typedCharacter: Character
    let frequency: Int
    let timestamp: Date
    let context: String? // Surrounding characters for context
    
    var characterPair: String {
        return "\(expectedCharacter)→\(typedCharacter)"
    }
}

// MARK: - Real-time Analytics Data
struct RealTimeAnalytics {
    let currentWPM: Double
    let currentCPM: Double
    let accuracy: Double
    let errorRate: Double
    let sessionDuration: TimeInterval
    let charactersTyped: Int
    let isActive: Bool
    
    init(from metrics: SessionMetrics) {
        self.currentWPM = metrics.currentWPM
        self.currentCPM = metrics.currentCPM
        self.accuracy = metrics.accuracy
        self.errorRate = metrics.sessionDuration > 0 ? Double(metrics.errorCount) / (metrics.sessionDuration / 60.0) : 0.0
        self.sessionDuration = metrics.sessionDuration
        self.charactersTyped = metrics.charactersTyped
        self.isActive = metrics.sessionDuration > 0
    }
}

// MARK: - Achievement
struct Achievement {
    let id: String
    let title: String
    let description: String
    let icon: String
    let threshold: Double
    let metric: AchievementMetric
    let unlockedAt: Date?
    
    var isUnlocked: Bool {
        unlockedAt != nil
    }
}

enum AchievementMetric {
    case wpm
    case accuracy
    case sessionsCompleted
    case charactersTyped
    case linesCompleted
}

// MARK: - Historical Data Period
enum TimePeriod: String, CaseIterable {
    case today = "Today"
    case week = "This Week"
    case month = "This Month"
    case all = "All Time"
}

// MARK: - Trend Data
struct TrendData {
    let period: TimePeriod
    let sessions: [SessionSummary]
    let averageWPM: Double
    let averageAccuracy: Double
    let totalCharacters: Int
    let totalSessions: Int
    let improvementRate: Double // WPM improvement over period
}