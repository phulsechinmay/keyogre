// ABOUTME: Language selection and control bar for coding practice mode
// ABOUTME: Horizontal layout with language picker and restart button positioned above typing view

import SwiftUI

struct LanguageControlBar: View {
    @ObservedObject var codingPracticeManager: CodingPracticeManager
    private let theme = ColorTheme.defaultTheme
    
    var body: some View {
        HStack(spacing: 4) {
            // Language selection
            HStack(spacing: 8) {
                Picker("", selection: Binding(
                    get: { codingPracticeManager.state.currentLanguage },
                    set: { newLanguage in
                        codingPracticeManager.switchLanguage(to: newLanguage)
                    }
                )) {
                    ForEach(ProgrammingLanguage.allCases) { language in
                        HStack {
                            Image(systemName: language.icon)
                                .font(.system(size: 12))
                            Text(language.rawValue)
                                .font(.system(size: 13))
                        }
                        .tag(language)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(maxWidth: 150)
            }
            
            Spacer()
            
            // Restart button
            Button(action: {
                codingPracticeManager.restartCurrentLanguage()
            }) {
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
    
    private func getTotalLines() -> Int {
        let practiceContent = CodingPracticeContent()
        return practiceContent.getCodeLines(for: codingPracticeManager.state.currentLanguage).count
    }
}
