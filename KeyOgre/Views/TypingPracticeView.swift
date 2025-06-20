// ABOUTME: Typing practice mode view with word-based practice and enhanced typing display
// ABOUTME: Provides structured word typing practice with character-level feedback and progress tracking

import SwiftUI

struct TypingPracticeView: View {
    @EnvironmentObject var typingPracticeManager: TypingPracticeManager
    @EnvironmentObject var keyEventTap: KeyEventTap
    
    var body: some View {
        VStack(spacing: 16) {
            // Enhanced typing display
            TypingPracticeDisplayView()
                .environmentObject(typingPracticeManager)
                .environmentObject(keyEventTap)
            
            KeyboardView()
                .environmentObject(keyEventTap)
        }
        .onAppear {
            // Register typing practice handlers with key event tap
            keyEventTap.registerTypingPracticeHandler { character in
                typingPracticeManager.processKeyInput(character)
            }
            keyEventTap.registerBackspaceHandler {
                typingPracticeManager.processBackspace()
            }
            keyEventTap.registerEnterHandler {
                typingPracticeManager.processEnterKey()
            }
            // Note: No tab handler needed for typing practice (unlike coding practice)
            
            // Start analytics session when view appears
            if !typingPracticeManager.analyticsManager.isSessionActive {
                typingPracticeManager.startAnalyticsSession()
            }
        }
    }
}

// Typing practice display view with direct reactive access to manager state
struct TypingPracticeDisplayView: View {
    @EnvironmentObject var typingPracticeManager: TypingPracticeManager
    private let theme = ColorTheme.defaultTheme
    
    // Display constants matching other typing views
    private let maxLineWidth: CGFloat = 350
    private let lineHeight: CGFloat = 24
    private let cylinderHeight: CGFloat = 140
    private let fontSize: CGFloat = 18
    
    // 3D styling constants
    private let baseYOffset: CGFloat = -28
    private let baseOpacity: Double = 0.25
    private let baseXRotation: CGFloat = -22
    private let baseYRotation: CGFloat = 1
    private let perspective: CGFloat = 0.7
    
    var body: some View {
        VStack(spacing: 0) {
            // 3D Cylinder container with typing practice lines
            ZStack {
                // Get display data with highlights - this makes the view reactive to state changes
                let displayData = typingPracticeManager.getDisplayData()
                
                // 2nd previous line (index 0 - top line)
                if displayData.allLines.count > 0 {
                    lineView(text: displayData.allLines[0], highlights: displayData.highlights[0] ?? [])
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
                if displayData.allLines.count > 1 {
                    lineView(text: displayData.allLines[1], highlights: displayData.highlights[1] ?? [])
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
                if displayData.allLines.count > 2 {
                    currentLineView(text: displayData.allLines[2], highlights: displayData.highlights[2] ?? [], showEnterIndicator: displayData.showEnterIndicator)
                        .opacity(1.0)
                        .offset(y: 0)
                }
                
                // 1st next line (index 3)
                if displayData.allLines.count > 3 {
                    lineView(text: displayData.allLines[3], highlights: displayData.highlights[3] ?? [], textColor: theme.characterUpcoming)
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
                if displayData.allLines.count > 4 {
                    lineView(text: displayData.allLines[4], highlights: displayData.highlights[4] ?? [], textColor: theme.characterUpcoming)
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
    private func currentLineView(text: String, highlights: [CharacterHighlight], showEnterIndicator: Bool) -> some View {
        HStack(alignment: .center, spacing: 0) {
            if text.isEmpty {
                if showEnterIndicator {
                    HStack(spacing: 8) {
                        Image(systemName: "return")
                            .font(.system(size: fontSize, weight: .semibold))
                            .foregroundColor(Color.blue.opacity(0.8))
                        Text("Press Enter to continue")
                            .font(.system(size: fontSize, weight: .semibold, design: .monospaced))
                            .foregroundColor(Color.white.opacity(0.7))
                    }
                } else {
                    Text("Ready to practice words...")
                        .font(.system(size: fontSize, weight: .semibold, design: .monospaced))
                        .foregroundColor(Color.white.opacity(0.5))
                }
            } else if text == "Word Practice Complete! 🎉" {
                // Special handling for completion message
                Text(text)
                    .font(.system(size: fontSize, weight: .semibold, design: .monospaced))
                    .foregroundColor(.green)
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
                
                // Show enter icon at the end of completed lines
                if showEnterIndicator {
                    Spacer()
                    Image(systemName: "return")
                        .font(.system(size: fontSize, weight: .semibold))
                        .foregroundColor(Color.blue.opacity(0.8))
                        .padding(.leading, 8)
                }
            }
            Spacer()
        }
        .frame(maxWidth: maxLineWidth, alignment: .leading)
        .frame(height: lineHeight)
    }
}