// ABOUTME: Compact metrics display bar showing real-time typing performance data
// ABOUTME: Non-intrusive UI component for WPM, accuracy, and session status with toggle functionality

import SwiftUI

struct TypingMetricsBar: View {
    @ObservedObject var analyticsManager: TypingAnalyticsManager
    @AppStorage("showTypingMetrics") private var showMetrics: Bool = true
    private let theme = ColorTheme.defaultTheme
    
    var body: some View {
        if showMetrics && analyticsManager.isSessionActive {
            HStack(spacing: 16) {
                // WPM Metric
                MetricView(
                    label: "WPM",
                    value: analyticsManager.getFormattedWPM(),
                    icon: "speedometer",
                    color: getWPMColor()
                )
                
                Divider()
                    .frame(height: 20)
                    .foregroundColor(theme.keyBorder)
                
                // Accuracy Metric
                MetricView(
                    label: "ACC",
                    value: analyticsManager.getFormattedAccuracy(),
                    icon: "target",
                    color: getAccuracyColor()
                )
                
                Divider()
                    .frame(height: 20)
                    .foregroundColor(theme.keyBorder)
                
                // Session Duration
                MetricView(
                    label: "TIME",
                    value: getFormattedDuration(),
                    icon: "clock",
                    color: .gray
                )
                
                Spacer()
                
                // Session Status Indicator
                SessionStatusView()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(theme.settingsInputBackgroundColor.opacity(0.8))
                    .stroke(theme.keyBorder, lineWidth: 0.5)
            )
            .transition(.opacity.combined(with: .scale(scale: 0.9)))
            .animation(.easeInOut(duration: 0.2), value: showMetrics)
        }
    }
    
    // MARK: - Metric Components
    
    private struct MetricView: View {
        let label: String
        let value: String
        let icon: String
        let color: Color
        
        var body: some View {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(color)
                    .frame(width: 14)
                
                VStack(alignment: .leading, spacing: 1) {
                    Text(label)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text(value)
                        .font(.system(size: 14, weight: .semibold, design: .monospaced))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                }
            }
        }
    }
    
    private struct SessionStatusView: View {
        var body: some View {
            HStack(spacing: 4) {
                Circle()
                    .fill(Color.green)
                    .frame(width: 6, height: 6)
                    .opacity(0.8)
                
                Text("LIVE")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.secondary)
            }
        }
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

// MARK: - Metrics Toggle Button

struct MetricsToggleButton: View {
    @AppStorage("showTypingMetrics") private var showMetrics: Bool = true
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                showMetrics.toggle()
            }
        }) {
            Image(systemName: showMetrics ? "chart.bar.fill" : "chart.bar")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
                .frame(width: 20, height: 20)
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            if hovering {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }
        }
        .help(showMetrics ? "Hide metrics" : "Show metrics")
    }
}

// MARK: - Preview

#if DEBUG
struct TypingMetricsBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Active session preview
            TypingMetricsBar(analyticsManager: createSampleManager(active: true))
            
            // Toggle button preview
            MetricsToggleButton()
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
        }
        return manager
    }
}
#endif