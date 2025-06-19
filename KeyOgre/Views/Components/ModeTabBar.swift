// ABOUTME: Tab bar component for switching between Freeform and Coding Practice modes
// ABOUTME: Matches SettingsView styling with floating rounded background and consistent theming

import SwiftUI

struct ModeTabBar: View {
    @Binding var selectedMode: MainWindowMode
    private let theme = ColorTheme.defaultTheme
    
    var body: some View {
        HStack {
            Spacer()
            
            HStack(spacing: 0) {
                ForEach(MainWindowMode.allCases, id: \.self) { mode in
                    ModeTabButton(
                        mode: mode,
                        isSelected: selectedMode == mode,
                        action: { selectedMode = mode }
                    )
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(red: 0.274, green: 0.274, blue: 0.274))
                    .background(.ultraThinMaterial)
            )
            
            Spacer()
        }
        .padding(.vertical, 10)
    }
}

struct ModeTabButton: View {
    let mode: MainWindowMode
    let isSelected: Bool
    let action: () -> Void
    @State private var isHovering = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                Image(systemName: mode.icon)
                    .font(.system(size: 18, weight: .medium))
                    .frame(width: 24, height: 24)
                
                // Show text only on hover
                if isHovering {
                    Text(mode.rawValue)
                        .font(.system(size: 10, weight: .medium))
                        .transition(.opacity)
                        .padding(.top, 2)
                }
            }
            .foregroundColor(
                isSelected ? Color.accentColor : Color.white.opacity(0.6)
            )
            .frame(width: 50, height: isHovering ? 50 : 36)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        isSelected
                            ? Color.accentColor.opacity(0.2) : Color.clear
                    )
                    .stroke(
                        isSelected ? Color.accentColor : Color.clear,
                        lineWidth: 1
                    )
            )
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
    }
}