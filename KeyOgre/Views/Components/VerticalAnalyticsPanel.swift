// ABOUTME: Vertical analytics panel for right sidebar displaying typing performance metrics
// ABOUTME: Compact vertical layout with real-time WPM, accuracy, and session information

import SwiftUI

struct VerticalAnalyticsPanel: View {
    @ObservedObject var analyticsManager: TypingAnalyticsManager
    @AppStorage("showTypingMetrics") private var showMetrics: Bool = true
    private let theme = ColorTheme.defaultTheme
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with toggle
            HStack {
                Text("METRICS")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showMetrics.toggle()
                    }
                }) {
                    Image(systemName: showMetrics ? "eye.fill" : "eye.slash.fill")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
                .onHover { hovering in
                    if hovering {
                        NSCursor.pointingHand.push()
                    } else {
                        NSCursor.pop()
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            
            if showMetrics && analyticsManager.isSessionActive {
                Divider()
                    .padding(.horizontal, 8)
                
                // Metrics content
                VStack(spacing: 12) {
                    // WPM
                    VerticalMetricView(
                        label: "WPM",
                        value: analyticsManager.getFormattedWPM(),
                        icon: "speedometer",
                        color: getWPMColor(),
                        subtitle: "Words/Min"
                    )
                    
                    // Accuracy
                    VerticalMetricView(
                        label: "ACC",
                        value: analyticsManager.getFormattedAccuracy(),
                        icon: "target",
                        color: getAccuracyColor(),
                        subtitle: "Accuracy"
                    )
                    
                    // CPM
                    VerticalMetricView(
                        label: "CPM",
                        value: analyticsManager.getFormattedCPM(),
                        icon: "keyboard",
                        color: .gray,
                        subtitle: "Chars/Min"
                    )
                    
                    Divider()
                        .padding(.horizontal, 8)
                    
                    // Session info
                    VStack(spacing: 6) {
                        HStack {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 6, height: 6)
                            
                            Text("LIVE SESSION")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(.secondary)
                            
                            Spacer()
                        }
                        
                        HStack {
                            Text("TIME")
                                .font(.system(size: 8, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text(getFormattedDuration())
                                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                                .foregroundColor(.primary)
                        }
                        
                        HStack {
                            Text("CHARS")
                                .font(.system(size: 8, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text("\(analyticsManager.currentSessionMetrics.charactersTyped)")
                                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                                .foregroundColor(.primary)
                        }
                        
                        HStack {
                            Text("ERRORS")
                                .font(.system(size: 8, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text("\(analyticsManager.currentSessionMetrics.errorCount)")
                                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                                .foregroundColor(analyticsManager.currentSessionMetrics.errorCount > 0 ? .red : .primary)
                        }
                    }
                    .padding(.horizontal, 8)
                }
                .padding(.vertical, 12)
            } else if !analyticsManager.isSessionActive {
                VStack(spacing: 8) {
                    Image(systemName: "chart.bar.xaxis")
                        .font(.system(size: 24, weight: .light))
                        .foregroundColor(.secondary)
                    
                    Text("No active session")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 20)
            }
            
            Spacer()
        }
        .frame(width: 100)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.settingsInputBackgroundColor.opacity(0.8))
                .stroke(theme.keyBorder, lineWidth: 0.5)
        )
    }
    
    // MARK: - Helper Methods
    
    private func getWPMColor() -> Color {
        let wpm = analyticsManager.currentSessionMetrics.currentWPM
        if wpm >= 60 { return .green }
        if wpm >= 40 { return .yellow }
        if wpm >= 20 { return .orange }
        return .red
    }
    
    private func getAccuracyColor() -> Color {
        let accuracy = analyticsManager.currentSessionMetrics.accuracy
        if accuracy >= 95 { return .green }
        if accuracy >= 90 { return .yellow }
        if accuracy >= 80 { return .orange }
        return .red
    }
    
    private func getFormattedDuration() -> String {
        let duration = analyticsManager.currentSessionMetrics.sessionDuration
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        
        if minutes > 0 {
            return String(format: "%d:%02d", minutes, seconds)
        } else {
            return String(format: "%ds", seconds)
        }
    }
}

// MARK: - Vertical Metric Component

struct VerticalMetricView: View {
    let label: String
    let value: String
    let icon: String
    let color: Color
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(color)
                .frame(height: 16)
            
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(.primary)
                .lineLimit(1)
            
            Text(subtitle)
                .font(.system(size: 7, weight: .medium))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.primary.opacity(0.02))
                .stroke(color.opacity(0.2), lineWidth: 0.5)
        )
    }
}

// MARK: - Preview

#if DEBUG
struct VerticalAnalyticsPanel_Previews: PreviewProvider {
    static var previews: some View {
        HStack(spacing: 20) {
            // Active session preview
            VerticalAnalyticsPanel(analyticsManager: createSampleManager(active: true))
            
            // Inactive session preview
            VerticalAnalyticsPanel(analyticsManager: createSampleManager(active: false))
        }
        .padding()
        .background(Color.black)
    }
    
    static func createSampleManager(active: Bool) -> TypingAnalyticsManager {
        let manager = TypingAnalyticsManager()
        if active {
            manager.startSession(mode: .codingPractice, language: .python)
            // Simulate some typing data
            manager.currentSessionMetrics.currentWPM = 45.0
            manager.currentSessionMetrics.accuracy = 92.5
            manager.currentSessionMetrics.charactersTyped = 150
            manager.currentSessionMetrics.errorCount = 12
        }
        return manager
    }
}
#endif