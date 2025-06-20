// ABOUTME: Vertical sidebar tab bar component for switching between Freeform and Coding Practice modes
// ABOUTME: Compact vertical design for left sidebar placement with consistent theming

import SwiftUI

struct VerticalModeTabBar: View {
    @Binding var selectedMode: MainWindowMode
    private let theme = ColorTheme.defaultTheme
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(MainWindowMode.allCases, id: \.self) { mode in
                VerticalModeTabButton(
                    mode: mode,
                    isSelected: selectedMode == mode,
                    action: { selectedMode = mode }
                )
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.settingsInputBackgroundColor.opacity(0.8))
                .stroke(theme.keyBorder, lineWidth: 0.5)
        )
    }
}

struct VerticalModeTabButton: View {
    let mode: MainWindowMode
    let isSelected: Bool
    let action: () -> Void
    @State private var isHovering = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: mode.icon)
                    .font(.system(size: 20, weight: .medium))
                    .frame(width: 28, height: 28)
                
                Text(mode.rawValue)
                    .font(.system(size: 9, weight: .medium))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(maxWidth: 60)
            }
            .foregroundColor(
                isSelected ? Color.accentColor : Color.primary.opacity(0.7)
            )
            .frame(width: 70, height: 65)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        isSelected 
                            ? Color.accentColor.opacity(0.15) 
                            : (isHovering ? Color.primary.opacity(0.05) : Color.clear)
                    )
                    .stroke(
                        isSelected ? Color.accentColor.opacity(0.6) : Color.clear,
                        lineWidth: isSelected ? 1.5 : 0
                    )
            )
            .scaleEffect(isHovering ? 1.05 : 1.0)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovering = hovering
            }
            if hovering {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }
        }
        .help(mode.rawValue)
    }
}