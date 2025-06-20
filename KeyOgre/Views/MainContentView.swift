// ABOUTME: Main content container with mode switching tabbar and dynamic content display
// ABOUTME: Orchestrates between Freeform and Coding Practice modes with shared keyboard display

import SwiftUI

struct MainContentView: View {
    @State private var selectedMode: MainWindowMode = .codingPractice
    @ObservedObject var keyEventTap: KeyEventTap
    let onClose: () -> Void
    private let theme = ColorTheme.defaultTheme
    @StateObject private var keyboardLayoutManager = KeyboardLayoutManager
        .shared
    @StateObject private var codingPracticeManager = CodingPracticeManager()
    @StateObject private var typingPracticeManager = TypingPracticeManager()
    @State private var analyticsRefreshTimer: Timer?
    @State private var forceAnalyticsRefresh = false

    init(keyEventTap: KeyEventTap, onClose: @escaping () -> Void) {
        self.keyEventTap = keyEventTap
        self.onClose = onClose
        // Set initial mode
        keyEventTap.setCurrentMode(.codingPractice)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header with close button
            headerView

            // Main content area - unified layout
            VStack(spacing: 12) {

                // Language controls (only for coding practice)
                if selectedMode == .codingPractice {
                    LanguageControlBar(
                        codingPracticeManager: codingPracticeManager
                    )
                }

                // Top row - controls and typing content
                HStack {
                    // Compact mode tabbar (always visible)
                    CompactModeTabBar(selectedMode: $selectedMode)
                        .onChange(of: selectedMode) { newMode in
                            keyEventTap.setCurrentMode(newMode)
                        }

                    // Center area with conditional language controls and typing
                    VStack(spacing: 8) {

                        // Main content based on selected mode
                        contentView
                    }
                    .frame(maxWidth: 450)

                    // Compact analytics panel (always visible but content changes)
                    analyticsPanel
                }

                // Bottom row - keyboard (always visible, independent of mode)
                KeyboardView()
                    .environmentObject(keyEventTap)
                    .environmentObject(keyboardLayoutManager)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.windowBackground)
        )
        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
        .onAppear {
            setupKeyHandlers()
            startAnalyticsRefreshTimer()
        }
        .onDisappear {
            stopAnalyticsRefreshTimer()
        }
        .onChange(of: selectedMode) { newMode in
            setupKeyHandlers()
        }
    }

    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("KeyOgre")
                    .font(.headline)
                    .foregroundColor(theme.keyText)

                Text("Press ⌘` to toggle")
                    .font(.caption)
                    .foregroundColor(theme.keyText.opacity(0.7))
            }

            Spacer()

            Button(action: onClose) {
                ZStack {
                    Circle()
                        .fill(theme.keyBackground.opacity(0.8))
                        .frame(width: 24, height: 24)

                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(theme.keyText)
                }
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
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }

    @ViewBuilder
    private var contentView: some View {
        switch selectedMode {
        case .freeform:
            // Just the typing display for freeform mode
            TypingDisplayView()
                .environmentObject(keyEventTap)
        case .codingPractice:
            // Just the coding typing display for practice mode
            CodingTypingDisplayView()
                .environmentObject(codingPracticeManager)
                .environmentObject(keyEventTap)
        case .typingPractice:
            // Just the typing practice display for word practice mode
            TypingPracticeDisplayView()
                .environmentObject(typingPracticeManager)
                .environmentObject(keyEventTap)
        }
    }

    private func getCodingPracticeManager() -> CodingPracticeManager {
        return codingPracticeManager
    }
    
    private func getCurrentAnalyticsManager() -> TypingAnalyticsManager {
        switch selectedMode {
        case .codingPractice:
            return codingPracticeManager.analyticsManager
        case .typingPractice:
            return typingPracticeManager.analyticsManager
        case .freeform:
            return codingPracticeManager.analyticsManager // Fallback
        }
    }

    @ViewBuilder
    private var analyticsPanel: some View {
        VStack(spacing: 8) {
            // Hidden dependency on refresh state to trigger UI updates
            let _ = forceAnalyticsRefresh
            switch selectedMode {
            case .codingPractice, .typingPractice:
                VStack(spacing: 6) {
                    // WPM with icon - always show
                    VStack(spacing: 2) {
                        HStack(spacing: 4) {
                            Image(systemName: "speedometer")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(getWPMColor())
                            Text(
                                getCurrentAnalyticsManager().getFormattedWPM()
                            )
                            .font(
                                .system(
                                    size: 14,
                                    weight: .bold,
                                    design: .monospaced
                                )
                            )
                            .foregroundColor(.primary)
                        }
                        Text("wpm")
                            .font(.system(size: 7, weight: .medium))
                            .foregroundColor(.secondary)
                    }

                    // Divider
                    Rectangle()
                        .fill(Color.secondary.opacity(0.3))
                        .frame(height: 0.5)
                        .padding(.horizontal, 8)

                    // Accuracy with icon - always show
                    VStack(spacing: 4) {
                        HStack(spacing: 4) {
                            Image(systemName: "target")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(getAccuracyColor())
                            Text(
                                getCurrentAnalyticsManager().getFormattedAccuracy()
                            )
                            .font(
                                .system(
                                    size: 12,
                                    weight: .bold,
                                    design: .monospaced
                                )
                            )
                            .foregroundColor(.primary)
                        }
                        Text("accuracy")
                            .font(.system(size: 7, weight: .medium))
                            .foregroundColor(.secondary)
                    }

                    // Divider
                    Rectangle()
                        .fill(Color.secondary.opacity(0.3))
                        .frame(height: 0.5)
                        .padding(.horizontal, 8)

                    VStack(spacing: 4) {
                        // Timer (mm:ss format only) - always show
                        Text(getFormattedDuration())
                            .font(
                                .system(
                                    size: 10,
                                    weight: .medium,
                                    design: .monospaced
                                )
                            )
                            .foregroundColor(.secondary)
                        
                        // Status indicator - changes based on session state
                        HStack(spacing: 4) {
                            Text(getSessionStatusText())
                                .font(.system(size: 8, weight: .medium))
                                .foregroundColor(.secondary)
                            Circle()
                                .fill(getSessionStatusColor())
                                .frame(width: 5, height: 5)
                        }
                    }
                }
            case .freeform:
                Text("Freeform")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: 70)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(theme.settingsInputBackgroundColor.opacity(0.8))
                .stroke(theme.keyBorder, lineWidth: 0.5)
        )
    }

    private func getFormattedDuration() -> String {
        let activeDuration = getCurrentAnalyticsManager().currentSessionMetrics.activeDuration
        
        let minutes = Int(activeDuration) / 60
        let seconds = Int(activeDuration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    private func getWPMColor() -> Color {
        let wpm = getCurrentAnalyticsManager().currentSessionMetrics.currentWPM
        if wpm >= 60 { return .green }
        if wpm >= 40 { return .yellow }
        if wpm >= 20 { return .orange }
        return .red
    }

    private func getAccuracyColor() -> Color {
        let accuracy = getCurrentAnalyticsManager().currentSessionMetrics.accuracy
        if accuracy >= 95 { return .green }
        if accuracy >= 90 { return .yellow }
        if accuracy >= 80 { return .orange }
        return .red
    }
    
    private func getSessionStatusText() -> String {
        let analyticsManager = getCurrentAnalyticsManager()
        let hasTypedCharacters = analyticsManager.currentSessionMetrics.charactersTyped > 0
        
        if !hasTypedCharacters {
            return "ready"
        } else if analyticsManager.isSessionActive {
            return "live"
        } else {
            return "paused"
        }
    }
    
    private func getSessionStatusColor() -> Color {
        let analyticsManager = getCurrentAnalyticsManager()
        let hasTypedCharacters = analyticsManager.currentSessionMetrics.charactersTyped > 0
        
        if !hasTypedCharacters {
            return .blue
        } else if analyticsManager.isSessionActive {
            return .green
        } else {
            return .yellow
        }
    }
    
    private func startAnalyticsRefreshTimer() {
        stopAnalyticsRefreshTimer()
        analyticsRefreshTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            DispatchQueue.main.async {
                self.forceAnalyticsRefresh.toggle()
            }
        }
    }
    
    private func stopAnalyticsRefreshTimer() {
        analyticsRefreshTimer?.invalidate()
        analyticsRefreshTimer = nil
    }

    private func setupKeyHandlers() {
        switch selectedMode {
        case .codingPractice:
            // Register coding practice handlers with key event tap
            keyEventTap.registerCodingPracticeHandler { character in
                codingPracticeManager.processKeyInput(character)
            }
            keyEventTap.registerTypingPracticeHandler(nil) // Clear typing practice handler
            keyEventTap.registerBackspaceHandler {
                codingPracticeManager.processBackspace()
            }
            keyEventTap.registerEnterHandler {
                codingPracticeManager.processEnterKey()
            }
            keyEventTap.registerTabHandler {
                codingPracticeManager.processTabKey()
            }

            // Start analytics session when switching to coding practice
            if !codingPracticeManager.analyticsManager.isSessionActive {
                codingPracticeManager.startAnalyticsSession()
            }

        case .typingPractice:
            // Register typing practice handlers with key event tap
            keyEventTap.registerTypingPracticeHandler { character in
                typingPracticeManager.processKeyInput(character)
            }
            keyEventTap.registerCodingPracticeHandler(nil) // Clear coding practice handler
            keyEventTap.registerBackspaceHandler {
                typingPracticeManager.processBackspace()
            }
            keyEventTap.registerEnterHandler {
                typingPracticeManager.processEnterKey()
            }
            keyEventTap.registerTabHandler(nil) // No tab handling for typing practice

            // Start analytics session when switching to typing practice
            if !typingPracticeManager.analyticsManager.isSessionActive {
                typingPracticeManager.startAnalyticsSession()
            }

        case .freeform:
            // Clear practice handlers for freeform mode
            let nilCharacterHandler: ((Character) -> Void)? = nil
            let nilVoidHandler: (() -> Void)? = nil
            keyEventTap.registerCodingPracticeHandler(nilCharacterHandler)
            keyEventTap.registerTypingPracticeHandler(nilCharacterHandler)
            keyEventTap.registerBackspaceHandler(nilVoidHandler)
            keyEventTap.registerEnterHandler(nilVoidHandler)
            keyEventTap.registerTabHandler(nilVoidHandler)
        }
    }
}

// MARK: - Preview

#if DEBUG
    struct MainContentView_Previews: PreviewProvider {
        static var previews: some View {
            MainContentView(
                keyEventTap: createSampleKeyEventTap(),
                onClose: { print("Preview close tapped") }
            )
            .frame(width: 800, height: 600)
            .background(Color.black)
        }

        static func createSampleKeyEventTap() -> KeyEventTap {
            let keyEventTap = KeyEventTap()
            // Set up some sample state for preview
            keyEventTap.setCurrentMode(.codingPractice)
            return keyEventTap
        }
    }
#endif
