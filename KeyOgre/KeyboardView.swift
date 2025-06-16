// ABOUTME: SwiftUI component that renders the keyboard layout with highlighting
// ABOUTME: Handles key press animations with scale and glow effects matching reference video

import SwiftUI
import Combine

struct KeyboardView: View {
    @EnvironmentObject var keyEventTap: KeyEventTap
    @StateObject private var keyboardLayout = ANSI60KeyboardLayout(withColors: true)
    @State private var highlightedKeyCode: CGKeyCode?
    @State private var cancellables = Set<AnyCancellable>()
    
    private let theme = ColorTheme.defaultTheme
    
    var body: some View {
        ZStack {
            theme.windowBackground
                .cornerRadius(8)
            
            Canvas { context, size in
                // Scale the layout to fit the available space
                let scale = min(size.width / keyboardLayout.totalSize.width, 
                               size.height / keyboardLayout.totalSize.height) * 0.9
                
                let offsetX = (size.width - keyboardLayout.totalSize.width * scale) / 2
                let offsetY = (size.height - keyboardLayout.totalSize.height * scale) / 2
                
                for key in keyboardLayout.keys {
                    let scaledFrame = CGRect(
                        x: key.frame.origin.x * scale + offsetX,
                        y: key.frame.origin.y * scale + offsetY,
                        width: key.frame.width * scale,
                        height: key.frame.height * scale
                    )
                    
                    drawKey(context: context, key: key, frame: scaledFrame, scale: scale)
                }
            }
        }
        .onAppear {
            keyEventTap.currentKeyCode
                .receive(on: DispatchQueue.main)
                .sink { keyCode in
                    withAnimation(.easeOut(duration: 0.15)) {
                        highlightedKeyCode = keyCode
                    }
                }
                .store(in: &cancellables)
        }
    }
    
    private func drawKey(context: GraphicsContext, key: Key, frame: CGRect, scale: CGFloat) {
        let isHighlighted = highlightedKeyCode == key.keyCode
        let keyScale: CGFloat = isHighlighted ? 1.05 : 1.0
        
        // Calculate scaled frame for highlight effect
        let highlightFrame = CGRect(
            x: frame.midX - (frame.width * keyScale / 2),
            y: frame.midY - (frame.height * keyScale / 2),
            width: frame.width * keyScale,
            height: frame.height * keyScale
        )
        
        // Draw key background
        let path = Path(roundedRect: highlightFrame, cornerRadius: 2 * scale)
        let backgroundColor: Color
        if isHighlighted {
            backgroundColor = theme.keyHighlight
        } else if key.backgroundColor != .clear {
            backgroundColor = key.backgroundColor
        } else {
            backgroundColor = theme.keyBackground
        }
        context.fill(path, with: .color(backgroundColor))
        
        // Draw key border
        context.stroke(path, with: .color(theme.keyBorder), lineWidth: 0.5)
        
        // Draw glow effect when highlighted
        if isHighlighted {
            let glowPath = Path(roundedRect: highlightFrame.insetBy(dx: -2, dy: -2), cornerRadius: 3 * scale)
            context.fill(glowPath, with: .color(theme.keyHighlight.opacity(0.3)))
        }
        
        // Draw key legends
        let fontSize = 12 * scale
        
        if let shiftLegend = key.shiftLegend {
            // Draw dual labels: shift legend on top, base legend on bottom
            let topPosition = CGPoint(
                x: highlightFrame.midX,
                y: highlightFrame.midY - highlightFrame.height * 0.15
            )
            
            let bottomPosition = CGPoint(
                x: highlightFrame.midX,
                y: highlightFrame.midY + highlightFrame.height * 0.15
            )
            
            // Draw shift legend (top)
            context.draw(
                Text(shiftLegend)
                    .font(.system(size: fontSize * 0.8, weight: .medium, design: .monospaced))
                    .foregroundColor(theme.keyText),
                at: topPosition,
                anchor: .center
            )
            
            // Draw base legend (bottom)
            context.draw(
                Text(key.baseLegend)
                    .font(.system(size: fontSize, weight: .medium, design: .monospaced))
                    .foregroundColor(theme.keyText),
                at: bottomPosition,
                anchor: .center
            )
        } else if !key.baseLegend.isEmpty {
            // Draw single legend (centered)
            let textPosition = CGPoint(
                x: highlightFrame.midX,
                y: highlightFrame.midY
            )
            
            context.draw(
                Text(key.baseLegend)
                    .font(.system(size: fontSize, weight: .medium, design: .monospaced))
                    .foregroundColor(theme.keyText),
                at: textPosition,
                anchor: .center
            )
        }
    }
}

struct KeyboardView_Previews: PreviewProvider {
    static var previews: some View {
        KeyboardView()
            .environmentObject(KeyEventTap())
            .frame(width: 800, height: 300)
    }
}