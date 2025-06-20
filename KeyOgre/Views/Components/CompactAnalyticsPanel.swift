// ABOUTME: Compact vertical analytics panel with minimal labels and essential metrics only
// ABOUTME: Streamlined design showing WPM, accuracy percentage, and session time with icons

import SwiftUI

struct CompactAnalyticsPanel: View {
    @ObservedObject var analyticsManager: TypingAnalyticsManager
    @AppStorage("showTypingMetrics") private var showMetrics: Bool = true
    private let theme = ColorTheme.defaultTheme
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with toggle
            HStack {
                Text("METRICS")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showMetrics.toggle()
                    }
                }) {
                    Image(systemName: showMetrics ? "eye.fill" : "eye.slash.fill")
                        .font(.system(size: 10, weight: .medium))
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
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            
            if showMetrics && analyticsManager.isSessionActive {
                Divider()
                    .padding(.horizontal, 6)
                
                // Compact metrics content
                VStack(spacing: 10) {
                    // WPM
                    CompactMetricView(
                        value: analyticsManager.getFormattedWPM(),
                        icon: "speedometer",
                        color: getWPMColor(),
                        subtitle: "wpm"
                    )
                    
                    // Accuracy (icon + percentage only)
                    CompactMetricView(
                        value: analyticsManager.getFormattedAccuracy(),
                        icon: "target",
                        color: getAccuracyColor(),
                        subtitle: nil
                    )
                    
                    // Time (icon only)
                    CompactMetricView(
                        value: getFormattedDuration(),
                        icon: "clock",
                        color: .gray,
                        subtitle: nil
                    )
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 6)
            } else if !analyticsManager.isSessionActive {
                VStack(spacing: 6) {
                    Image(systemName: "chart.bar.xaxis")
                        .font(.system(size: 20, weight: .light))
                        .foregroundColor(.secondary)
                    
                    Text("Paused")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 16)
            }
            
            Spacer()
        }
        .frame(width: 70) // Much more compact
        .background(
            RoundedRectangle(cornerRadius: 8)
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

// MARK: - Compact Metric Component

struct CompactMetricView: View {
    let value: String
    let icon: String
    let color: Color
    let subtitle: String?
    
    var body: some View {
        VStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(color)
                .frame(height: 14)
            
            Text(value)
                .font(.system(size: 13, weight: .bold, design: .monospaced))
                .foregroundColor(.primary)
                .lineLimit(1)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.system(size: 6, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .padding(.horizontal, 3)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.primary.opacity(0.02))
                .stroke(color.opacity(0.2), lineWidth: 0.5)
        )
    }
}

// MARK: - Preview

#if DEBUG
struct CompactAnalyticsPanel_Previews: PreviewProvider {
    static var previews: some View {
        HStack(spacing: 20) {
            // Active session preview
            CompactAnalyticsPanel(analyticsManager: createSampleManager(active: true))
            
            // Inactive session preview
            CompactAnalyticsPanel(analyticsManager: createSampleManager(active: false))
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