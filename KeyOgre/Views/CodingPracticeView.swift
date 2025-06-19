// ABOUTME: Coding practice mode view with language selection and enhanced typing display
// ABOUTME: Provides structured code typing practice with character-level feedback and progress tracking

import SwiftUI

struct CodingPracticeView: View {
    @StateObject private var codingPracticeManager = CodingPracticeManager()
    @EnvironmentObject var keyEventTap: KeyEventTap
    
    var body: some View {
        VStack(spacing: 20) {
            // Language controls
            HStack {
                Spacer()
                
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
                
                Button(action: {
                    codingPracticeManager.restartCurrentLanguage()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.blue.opacity(0.8))
                        .frame(width: 20, height: 20)
                        .background(
                            Circle()
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
            .padding(.horizontal)
            
            // Enhanced typing display - placeholder for now
            CodingTypingDisplayView()
                .environmentObject(codingPracticeManager)
                .environmentObject(keyEventTap)
            
            KeyboardView()
                .environmentObject(keyEventTap)
        }
        .onAppear {
            // Register coding practice handlers with key event tap
            keyEventTap.registerCodingPracticeHandler { character in
                codingPracticeManager.processKeyInput(character)
            }
            keyEventTap.registerBackspaceHandler {
                codingPracticeManager.processBackspace()
            }
            keyEventTap.registerEnterHandler {
                codingPracticeManager.processEnterKey()
            }
        }
    }
}

// Simplified coding practice typing display showing current line + 2 above with wheel picker effect
struct CodingTypingDisplayView: View {
    @EnvironmentObject var codingPracticeManager: CodingPracticeManager
    @EnvironmentObject var keyEventTap: KeyEventTap
    private let theme = ColorTheme.defaultTheme
    
    // Wheel picker constants (matching TypingDisplayView)
    private let maxLineWidth: CGFloat = 350
    private let lineHeight: CGFloat = 24
    private let cylinderHeight: CGFloat = 140 // Increased for 5 lines visibility
    private let fontSize: CGFloat = 18
    
    // 3D styling constants
    private let baseYOffset: CGFloat = -28 // Slightly increased spacing
    private let baseOpacity: Double = 0.25
    private let baseXRotation: CGFloat = -22
    private let baseYRotation: CGFloat = 1
    private let perspective: CGFloat = 0.7
    
    var body: some View {
        VStack(spacing: 0) {
            // 3D Cylinder container with coding practice lines
            ZStack {
                // Get display data with highlights
                let displayData = getDisplayData()
                
                // 2nd previous line (index 0 - top line)
                if displayData.lines.count > 0 {
                    lineView(text: displayData.lines[0], highlights: displayData.highlights[0] ?? [])
                        .rotation3DEffect(.degrees(baseXRotation * 2),
                                          axis: (x: 1, y: 0, z: 0),
                                          anchor: .center,
                                          perspective: perspective)
                        .rotation3DEffect(.degrees(baseYRotation * 2),
                                          axis: (x: 0, y: 1, z: 0),
                                          perspective: perspective)
                        .opacity(1.0 - (baseOpacity * 2))
                        .offset(y: baseYOffset * 1.85)
                }
                
                // 1st previous line (index 1)
                if displayData.lines.count > 1 {
                    lineView(text: displayData.lines[1], highlights: displayData.highlights[1] ?? [])
                        .rotation3DEffect(.degrees(baseXRotation),
                                          axis: (x: 1, y: 0, z: 0),
                                          anchor: .center,
                                          perspective: perspective)
                        .rotation3DEffect(.degrees(baseYRotation),
                                          axis: (x: 0, y: 1, z: 0),
                                          perspective: perspective)
                        .opacity(1.0 - baseOpacity)
                        .offset(y: baseYOffset)
                }
                
                // Current line (index 2 - center line)
                if displayData.lines.count > 2 {
                    currentLineView(text: displayData.lines[2], highlights: displayData.highlights[2] ?? [])
                        .opacity(1.0)
                        .offset(y: 0)
                }
                
                // 1st next line (index 3)
                if displayData.lines.count > 3 {
                    lineView(text: displayData.lines[3], highlights: displayData.highlights[3] ?? [], textColor: theme.characterUpcoming)
                        .rotation3DEffect(.degrees(-baseXRotation),
                                          axis: (x: 1, y: 0, z: 0),
                                          anchor: .center,
                                          perspective: perspective)
                        .rotation3DEffect(.degrees(-baseYRotation),
                                          axis: (x: 0, y: 1, z: 0),
                                          perspective: perspective)
                        .opacity(1.0 - baseOpacity)
                        .offset(y: -baseYOffset)
                }
                
                // 2nd next line (index 4 - bottom line)
                if displayData.lines.count > 4 {
                    lineView(text: displayData.lines[4], highlights: displayData.highlights[4] ?? [], textColor: theme.characterUpcoming)
                        .rotation3DEffect(.degrees(-baseXRotation * 2),
                                          axis: (x: 1, y: 0, z: 0),
                                          anchor: .center,
                                          perspective: perspective)
                        .rotation3DEffect(.degrees(-baseYRotation * 2),
                                          axis: (x: 0, y: 1, z: 0),
                                          perspective: perspective)
                        .opacity(1.0 - (baseOpacity * 2))
                        .offset(y: -baseYOffset * 1.85)
                }
            }
            .frame(width: maxLineWidth, height: cylinderHeight, alignment: .center)
            .padding(5)
            .clipped()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.settingsInputBackgroundColor)
                .stroke(theme.keyBorder, lineWidth: 1)
        )
    }
    
    private func getDisplayData() -> (lines: [String], highlights: [Int: [CharacterHighlight]]) {
        let practiceContent = CodingPracticeContent()
        let currentContent = practiceContent.getCodeLines(for: codingPracticeManager.state.currentLanguage)
        let progress = codingPracticeManager.state.getCurrentProgress()
        
        var lines: [String] = []
        var highlights: [Int: [CharacterHighlight]] = [:]
        
        // Previous line 2 (index 0 - top line)
        if progress.currentLineIndex >= 2 && progress.currentLineIndex - 2 < currentContent.count {
            let prevLine = currentContent[progress.currentLineIndex - 2]
            lines.append(prevLine)
            highlights[0] = generateHighlightsForCompletedLine(lineIndex: progress.currentLineIndex - 2, progress: progress)
        } else {
            lines.append("")
            highlights[0] = []
        }
        
        // Previous line 1 (index 1)
        if progress.currentLineIndex >= 1 && progress.currentLineIndex - 1 < currentContent.count {
            let prevLine = currentContent[progress.currentLineIndex - 1]
            lines.append(prevLine)
            highlights[1] = generateHighlightsForCompletedLine(lineIndex: progress.currentLineIndex - 1, progress: progress)
        } else {
            lines.append("")
            highlights[1] = []
        }
        
        // Current line (index 2 - center line)
        if progress.currentLineIndex < currentContent.count {
            let currentLine = currentContent[progress.currentLineIndex]
            lines.append(currentLine)
            highlights[2] = generateHighlightsForCurrentLine(line: currentLine, progress: progress)
        } else {
            lines.append("Practice Complete! 🎉")
            highlights[2] = []
        }
        
        // Next line 1 (index 3)
        if progress.currentLineIndex + 1 < currentContent.count {
            let nextLine = currentContent[progress.currentLineIndex + 1]
            lines.append(nextLine)
            highlights[3] = [] // No highlighting for future lines
        } else {
            lines.append("")
            highlights[3] = []
        }
        
        // Next line 2 (index 4 - bottom line)
        if progress.currentLineIndex + 2 < currentContent.count {
            let nextLine = currentContent[progress.currentLineIndex + 2]
            lines.append(nextLine)
            highlights[4] = [] // No highlighting for future lines
        } else {
            lines.append("")
            highlights[4] = []
        }
        
        return (lines, highlights)
    }
    
    private func generateHighlightsForCurrentLine(line: String, progress: LanguageProgress) -> [CharacterHighlight] {
        var highlights: [CharacterHighlight] = []
        
        // Get typed results for current line
        let lineResult = progress.typedResults.first { $0.lineIndex == progress.currentLineIndex }
        let typedCharacters = lineResult?.characterResults ?? []
        
        for (index, _) in line.enumerated() {
            if index < typedCharacters.count {
                // Character has been typed
                let result = typedCharacters[index]
                highlights.append(CharacterHighlight(
                    index: index,
                    state: result.isCorrect ? .correct : .incorrect,
                    isCurrentChar: false
                ))
            } else if index == progress.currentCharIndex {
                // Current character to type
                highlights.append(CharacterHighlight(
                    index: index,
                    state: .current,
                    isCurrentChar: true
                ))
            } else {
                // Upcoming character
                highlights.append(CharacterHighlight(
                    index: index,
                    state: .upcoming,
                    isCurrentChar: false
                ))
            }
        }
        
        return highlights
    }
    
    private func generateHighlightsForCompletedLine(lineIndex: Int, progress: LanguageProgress) -> [CharacterHighlight] {
        guard let lineResult = progress.typedResults.first(where: { $0.lineIndex == lineIndex }) else {
            return []
        }
        
        return lineResult.characterResults.enumerated().map { index, result in
            CharacterHighlight(
                index: index,
                state: result.isCorrect ? .correct : .incorrect,
                isCurrentChar: false
            )
        }
    }
    
    // Generic line view for previous lines with highlighting
    private func lineView(text: String, highlights: [CharacterHighlight], textColor: Color = .white) -> some View {
        HStack(alignment: .center, spacing: 0) {
            if text.isEmpty {
                Text(" ")
                    .font(.system(size: fontSize, weight: .medium, design: .monospaced))
                    .foregroundColor(textColor)
            } else if highlights.isEmpty {
                // No highlighting - just display text
                Text(text)
                    .font(.system(size: fontSize, weight: .medium, design: .monospaced))
                    .foregroundColor(textColor)
            } else {
                // Use character highlighting
                CharacterHighlightedText(
                    text: text,
                    highlights: highlights,
                    theme: theme,
                    fontSize: fontSize,
                    fontWeight: .medium
                )
            }
        }
        .frame(maxWidth: maxLineWidth, alignment: .leading)
        .frame(height: lineHeight)
    }
    
    // Current line - most prominent with highlighting
    private func currentLineView(text: String, highlights: [CharacterHighlight]) -> some View {
        HStack(alignment: .center, spacing: 0) {
            if text.isEmpty {
                Text("Ready to practice...")
                    .font(.system(size: fontSize, weight: .semibold, design: .monospaced))
                    .foregroundColor(Color.white.opacity(0.5))
            } else if highlights.isEmpty {
                // No highlighting - just display text
                Text(text)
                    .font(.system(size: fontSize, weight: .semibold, design: .monospaced))
                    .foregroundColor(.white)
            } else {
                // Use character highlighting
                CharacterHighlightedText(
                    text: text,
                    highlights: highlights,
                    theme: theme,
                    fontSize: fontSize,
                    fontWeight: .semibold
                )
            }
            Spacer()
        }
        .frame(maxWidth: maxLineWidth, alignment: .leading)
        .frame(height: lineHeight)
    }
}