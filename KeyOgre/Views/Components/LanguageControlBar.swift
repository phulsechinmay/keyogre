// ABOUTME: Generic practice control bar component for language/text selection and restart functionality
// ABOUTME: Horizontal layout with picker and restart button, reusable for coding and typing practice modes

import SwiftUI

struct PracticeControlBar<T: PracticeControlOption & Hashable & CaseIterable & Identifiable>: View {
    @Binding var selectedOption: T
    let onRestart: () -> Void
    let showIcons: Bool
    private let theme = ColorTheme.defaultTheme
    
    init(selectedOption: Binding<T>, onRestart: @escaping () -> Void, showIcons: Bool = true) {
        self._selectedOption = selectedOption
        self.onRestart = onRestart
        self.showIcons = showIcons
    }
    
    var body: some View {
        HStack(spacing: 4) {
            // Option selection
            HStack(spacing: 8) {
                Picker("", selection: $selectedOption) {
                    ForEach(Array(T.allCases), id: \.self) { option in
                        HStack {
                            if showIcons {
                                Image(systemName: option.icon)
                                    .font(.system(size: 12))
                            }
                            Text(option.displayName)
                                .font(.system(size: 13))
                        }
                        .tag(option)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(maxWidth: 150)
            }
            
            Spacer()
            
            // Restart button
            Button(action: onRestart) {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 13, weight: .medium))
                }
                .foregroundColor(.blue.opacity(0.8))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.blue.opacity(0.1))
                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                )
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
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(theme.settingsInputBackgroundColor.opacity(0.6))
                .stroke(theme.keyBorder, lineWidth: 0.5)
        )
        .frame(width: 200)
    }
}

struct LanguageControlBar: View {
    @ObservedObject var codingPracticeManager: CodingPracticeManager
    
    var body: some View {
        PracticeControlBar(
            selectedOption: Binding(
                get: { codingPracticeManager.state.currentLanguage },
                set: { newLanguage in
                    codingPracticeManager.switchLanguage(to: newLanguage)
                }
            ),
            onRestart: {
                codingPracticeManager.restartCurrentLanguage()
            },
            showIcons: true
        )
    }
}

struct TypingControlBar: View {
    @ObservedObject var typingPracticeManager: TypingPracticeManager
    
    var body: some View {
        PracticeControlBar(
            selectedOption: Binding(
                get: { typingPracticeManager.state.currentTextType },
                set: { newTextType in
                    typingPracticeManager.switchTextType(to: newTextType)
                }
            ),
            onRestart: {
                typingPracticeManager.restartCurrentTextType()
            },
            showIcons: false
        )
    }
}
