// ABOUTME: Shared 3D cylinder display component for both coding and typing practice modes
// ABOUTME: Provides reusable 5-line cylinder visualization with character highlighting and customizable display data

import SwiftUI

protocol TypingDisplayDataProvider {
    func getDisplayLines() -> [String]
    func getHighlights() -> [Int: [CharacterHighlight]]
    func getShowEnterIndicator() -> Bool
    func getCurrentCharacter() -> Character?
    func getCompletionMessage() -> String
    func getReadyMessage() -> String
}

struct SharedTypingDisplayView: View {
    let dataProvider: TypingDisplayDataProvider
    private let theme = ColorTheme.defaultTheme
    
    // Wheel picker constants (matching TypingDisplayView)
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
                let lines = dataProvider.getDisplayLines()
                let highlights = dataProvider.getHighlights()
                let showEnterIndicator = dataProvider.getShowEnterIndicator()
                
                // 2nd previous line (index 0 - top line)
                if lines.count > 0 {
                    lineView(text: lines[0], highlights: highlights[0] ?? [])
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
                if lines.count > 1 {
                    lineView(text: lines[1], highlights: highlights[1] ?? [])
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
                if lines.count > 2 {
                    currentLineView(
                        text: lines[2], 
                        highlights: highlights[2] ?? [], 
                        showEnterIndicator: showEnterIndicator,
                        completionMessage: dataProvider.getCompletionMessage(),
                        readyMessage: dataProvider.getReadyMessage()
                    )
                    .opacity(1.0)
                    .offset(y: 0)
                }
                
                // 1st next line (index 3)
                if lines.count > 3 {
                    lineView(text: lines[3], highlights: highlights[3] ?? [], textColor: theme.characterUpcoming)
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
                if lines.count > 4 {
                    lineView(text: lines[4], highlights: highlights[4] ?? [], textColor: theme.characterUpcoming)
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
    private func currentLineView(
        text: String, 
        highlights: [CharacterHighlight], 
        showEnterIndicator: Bool, 
        completionMessage: String, 
        readyMessage: String
    ) -> some View {
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
                    Text(readyMessage)
                        .font(.system(size: fontSize, weight: .semibold, design: .monospaced))
                        .foregroundColor(Color.white.opacity(0.5))
                }
            } else if text == completionMessage {
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

// MARK: - Data Provider Implementations

struct CodingPracticeDisplayDataProvider: TypingDisplayDataProvider {
    let manager: CodingPracticeManager
    
    func getDisplayLines() -> [String] {
        return manager.getDisplayData().allLines
    }
    
    func getHighlights() -> [Int: [CharacterHighlight]] {
        return manager.getDisplayData().highlights
    }
    
    func getShowEnterIndicator() -> Bool {
        return manager.getDisplayData().showEnterIndicator
    }
    
    func getCurrentCharacter() -> Character? {
        return manager.getDisplayData().currentCharacter
    }
    
    func getCompletionMessage() -> String {
        return "Practice Complete! 🎉"
    }
    
    func getReadyMessage() -> String {
        return "Ready to practice..."
    }
}

struct TypingPracticeDisplayDataProvider: TypingDisplayDataProvider {
    let manager: TypingPracticeManager
    
    func getDisplayLines() -> [String] {
        return manager.getDisplayData().allLines
    }
    
    func getHighlights() -> [Int: [CharacterHighlight]] {
        return manager.getDisplayData().highlights
    }
    
    func getShowEnterIndicator() -> Bool {
        return manager.getDisplayData().showEnterIndicator
    }
    
    func getCurrentCharacter() -> Character? {
        return manager.getDisplayData().currentCharacter
    }
    
    func getCompletionMessage() -> String {
        return "Word Practice Complete! 🎉"
    }
    
    func getReadyMessage() -> String {
        return "Ready to practice words..."
    }
}