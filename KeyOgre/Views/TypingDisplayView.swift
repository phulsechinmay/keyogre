// ABOUTME: iOS calendar picker-style UI displaying typing history with true 3D cylinder effect
// ABOUTME: Shows 3 lines total - current line prominent, 2 previous lines with progressive rotation

import SwiftUI
import Combine


struct TypingDisplayView: View {
    @EnvironmentObject var keyEventTap: KeyEventTap
    @State private var typingLines = TypingLines(currentLine: "", previousLine1: "", previousLine2: "", allText: "")
    @State private var cancellables = Set<AnyCancellable>()
    
    private let theme = ColorTheme.defaultTheme
    private let maxLineWidth: CGFloat = 350
    private let lineHeight: CGFloat = 24
    private let cylinderHeight: CGFloat = 60
    private let lineSpacing: CGFloat = 20  // Equal spacing between all lines
    private let fontSize: CGFloat = 18     // Same font size for all lines
    
    
    // ──────────────── generalized styling constants ────────────────
    private let baseYOffset: CGFloat = -25       // Base offset per line from center
    private let baseOpacity: Double = 0.25       // Base opacity reduction per line from center
    private let baseXRotation: CGFloat = -22     // Base X-axis rotation per line
    private let baseYRotation: CGFloat = 1       // Base Y-axis rotation per line
    private let perspective: CGFloat = 0.7       // Shared perspective for all rows
    // ───────────────────────────────────────────────────────────────
    
    var body: some View {
        VStack(spacing: 0) {
            // 3D Cylinder container matching iOS calendar picker
            ZStack {
                // 2nd previous line (index 2)
                lineView(text: typingLines.previousLine2.isEmpty ? " " : typingLines.previousLine2,
                         fontSize: fontSize)
                    .rotation3DEffect(.degrees(baseXRotation * 2),
                                      axis: (x: 1, y: 0, z: 0),
                                      anchor: .center,
                                      perspective: perspective)
                    .rotation3DEffect(.degrees(baseYRotation * 2),
                                      axis: (x: 0, y: 1, z: 0),
                                      perspective: perspective)
                    .opacity(1.0 - (baseOpacity * 2))
                    .offset(y: baseYOffset * 1.85)

                // 1st previous line (index 1)
                lineView(text: typingLines.previousLine1.isEmpty ? " " : typingLines.previousLine1,
                         fontSize: fontSize)
                    .rotation3DEffect(.degrees(baseXRotation),
                                      axis: (x: 1, y: 0, z: 0),
                                      anchor: .center,
                                      perspective: perspective)
                    .rotation3DEffect(.degrees(baseYRotation),
                                      axis: (x: 0, y: 1, z: 0),
                                      perspective: perspective)
                    .opacity(1.0 - baseOpacity)
                    .offset(y: baseYOffset)

                // Current line (index 0)
                currentLineView
                    .opacity(1.0)
                    .offset(y: 0)
            }
            .frame(width: maxLineWidth, height: cylinderHeight, alignment: .bottom)
            .padding(5)
            .clipped()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.settingsInputBackgroundColor)
                .stroke(theme.keyBorder, lineWidth: 1)
        )
        .onAppear {
            keyEventTap.typingLines
                .receive(on: DispatchQueue.main)
                .sink { newTypingLines in
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        typingLines = newTypingLines
                    }
                }
                .store(in: &cancellables)
        }
    }
    
    // Generic line view for previous lines
    private func lineView(text: String, fontSize: CGFloat) -> some View {
        HStack(alignment: .center, spacing: 0) {
            if text.count > 30 {
                ScrollView(.horizontal, showsIndicators: false) {
                    Text(text)
                        .font(.system(size: fontSize, weight: .medium, design: .monospaced))
                        .foregroundColor(.white)
                }
            } else {
                Text(text)
                    .font(.system(size: fontSize, weight: .medium, design: .monospaced))
                    .foregroundColor(.white)
            }
        }
        .frame(maxWidth: maxLineWidth, alignment: .leading)
        .frame(height: lineHeight)
    }
    
    // Current line - most prominent
    private var currentLineView: some View {
        HStack(alignment: .center, spacing: 0) {
            if typingLines.currentLine.count > 30 {
                // Scrollable for long lines
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 0) {
                            Text(typingLines.currentLine)
                                .font(.system(size: fontSize, weight: .semibold, design: .monospaced))
                                .foregroundColor(.white)
                                .id("currentText")
                        }
                    }
                    .onChange(of: typingLines.currentLine) { _ in
                        // Auto-scroll to show the end of the line when typing
                        withAnimation(.easeOut(duration: 0.2)) {
                            proxy.scrollTo("currentText", anchor: .trailing)
                        }
                    }
                }
            } else {
                // Normal display for shorter lines
                Text(typingLines.currentLine.isEmpty ? "type something..." : typingLines.currentLine)
                    .font(.system(size: fontSize, weight: .semibold, design: .monospaced))
                    .foregroundColor(typingLines.currentLine.isEmpty ? Color.white.opacity(0.5) : .white)
            }
            Spacer()
        }
        .frame(maxWidth: maxLineWidth, alignment: .leading)
        .frame(height: lineHeight)
    }
}

struct TypingDisplayView_Previews: PreviewProvider {
    static var previews: some View {
        TypingDisplayView()
            .environmentObject(KeyEventTap())
            .frame(width: 400, height: 100)
    }
}
