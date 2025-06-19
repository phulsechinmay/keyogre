// ABOUTME: Main content container with mode switching tabbar and dynamic content display
// ABOUTME: Orchestrates between Freeform and Coding Practice modes with shared keyboard display

import SwiftUI

struct MainContentView: View {
    @State private var selectedMode: MainWindowMode = .codingPractice
    @ObservedObject var keyEventTap: KeyEventTap
    let onClose: () -> Void
    private let theme = ColorTheme.defaultTheme
    @StateObject private var keyboardLayoutManager = KeyboardLayoutManager.shared
    
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
            
            // Mode tabbar
            ModeTabBar(selectedMode: $selectedMode)
                .onChange(of: selectedMode) { newMode in
                    keyEventTap.setCurrentMode(newMode)
                }
            
            // Content area based on selected mode
            contentView
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.windowBackground)
        )
        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
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
            FreeformModeView()
                .environmentObject(keyEventTap)
        case .codingPractice:
            CodingPracticeView()
                .environmentObject(keyEventTap)
        }
    }
}