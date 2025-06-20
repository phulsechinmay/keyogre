// ABOUTME: Compact vertical mode tabbar with icons only, positioned near typing view
// ABOUTME: Minimal design for space-efficient mode switching without text labels

import SwiftUI

struct CompactModeTabBar: View {
    @Binding var selectedMode: MainWindowMode
    private let theme = ColorTheme.defaultTheme
    
    var body: some View {
        VStack(spacing: 6) {
            ForEach(MainWindowMode.allCases, id: \.self) { mode in
                CompactModeTabButton(
                    mode: mode,
                    isSelected: selectedMode == mode,
                    action: { selectedMode = mode }
                )
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(theme.settingsInputBackgroundColor.opacity(0.8))
                .stroke(theme.keyBorder, lineWidth: 0.5)
        )
    }
}

struct CompactModeTabButton: View {
    let mode: MainWindowMode
    let isSelected: Bool
    let action: () -> Void
    @State private var isHovering = false
    
    var body: some View {
        Button(action: action) {
            Image(systemName: mode.icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(
                    isSelected ? Color.accentColor : Color.primary.opacity(0.6)
                )
                .frame(width: 32, height: 32)
                .background(
                    RoundedRectangle(cornerRadius: 6)
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