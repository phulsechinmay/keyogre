// ABOUTME: iOS calendar picker-style UI displaying typing history with true 3D cylinder effect
// ABOUTME: Shows 4 lines total - current line prominent, 3 previous lines with progressive rotation

import SwiftUI
import Combine

struct TypingDisplayView: View {
    @EnvironmentObject var keyEventTap: KeyEventTap
    @State private var typingLines = TypingLines(currentLine: "", previousLine1: "", previousLine2: "", previousLine3: "", allText: "")
    @State private var cancellables = Set<AnyCancellable>()
    
    private let theme = ColorTheme.defaultTheme
    private let maxLineWidth: CGFloat = 350
    private let lineHeight: CGFloat = 24
    private let cylinderHeight: CGFloat = 150
    private let lineSpacing: CGFloat = 20  // Equal spacing between all lines
    private let fontSize: CGFloat = 18     // Same font size for all lines
    
    
    // ──────────────── hard-coded styling constants ────────────────
    private let kYOffsetP3:  CGFloat =  -60      // 3 rows above centre
    private let kYOffsetP2:  CGFloat =  -47      // 2 rows above centre
    private let kYOffsetP1:  CGFloat =  -25      // 1 row  above centre
    private let kYOffsetCur: CGFloat =    0      // centre row

    private let kOpacityP3:  Double  = 0.40
    private let kOpacityP2:  Double  = 0.55
    private let kOpacityP1:  Double  = 0.75
    private let kOpacityCur: Double  = 1.00

    private let kPerspective          = 0.7      // shared for all rows
    // ───────────────────────────────────────────────────────────────
    
    var body: some View {
        VStack(spacing: 0) {
            // 3D Cylinder container matching iOS calendar picker
            ZStack {
                // 2-nd previous line
                lineView(text: typingLines.previousLine2.isEmpty ? " " : typingLines.previousLine2,
                         fontSize: fontSize)
                    .rotation3DEffect(.degrees(-44),
                                      axis: (x: 1, y: 0, z: 0),
                                      anchor: .center,
                                      perspective: kPerspective)
                    .rotation3DEffect(.degrees(2),               // try 2-3°
                                      axis: (x: 0, y: 1, z: 0),
                                      perspective: 0.7)
                    .opacity(kOpacityP2)
                    .offset(y: kYOffsetP2)


                // 1-st previous line (nearest above centre)
                lineView(text: typingLines.previousLine1.isEmpty ? " " : typingLines.previousLine1,
                         fontSize: fontSize)
                    .rotation3DEffect(.degrees(-22),
                                      axis: (x: 1, y: 0, z: 0),
                                      anchor: .center,
                                      perspective: kPerspective)
                    .rotation3DEffect(.degrees(1),               // try 2-3°
                                      axis: (x: 0, y: 1, z: 0),
                                      perspective: 0.7)
                    .opacity(kOpacityP1)
                    .offset(y: kYOffsetP1)


                // Current line (centre row)
                currentLineView
                    .opacity(kOpacityCur)
                    .offset(y: kYOffsetCur)
            }
            .frame(width: maxLineWidth, height: cylinderHeight)
            .padding(5)
            .clipped()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.keyBackground.opacity(0.7))
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
                        .foregroundColor(theme.keyText)
                }
            } else {
                Text(text)
                    .font(.system(size: fontSize, weight: .medium, design: .monospaced))
                    .foregroundColor(theme.keyText)
            }
            Spacer()
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
                                .foregroundColor(theme.keyText)
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
                Text(typingLines.currentLine.isEmpty ? "Start typing..." : typingLines.currentLine)
                    .font(.system(size: fontSize, weight: .semibold, design: .monospaced))
                    .foregroundColor(typingLines.currentLine.isEmpty ? theme.keyText.opacity(0.5) : theme.keyText)
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
            .frame(width: 400, height: 200)
    }
}
