// ABOUTME: Component for displaying text with character-level highlighting for coding practice
// ABOUTME: Shows green (correct), red (incorrect), gray (upcoming), and blue (current) character states

import SwiftUI

struct CharacterHighlightedText: View {
    let text: String
    let highlights: [CharacterHighlight]
    let theme: ColorTheme
    let fontSize: CGFloat
    let fontWeight: Font.Weight
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(text.enumerated()), id: \.offset) { index, character in
                let highlight = highlights.first { $0.index == index }
                
                Text(String(character))
                    .font(.system(size: fontSize, weight: fontWeight, design: .monospaced))
                    .foregroundColor(getCharacterColor(highlight: highlight))
                    .background(
                        highlight?.isCurrentChar == true ? 
                            theme.characterCurrent : Color.clear
                    )
            }
        }
    }
    
    private func getCharacterColor(highlight: CharacterHighlight?) -> Color {
        guard let highlight = highlight else {
            return theme.characterUpcoming
        }
        
        switch highlight.state {
        case .correct:
            return theme.characterCorrect
        case .incorrect:
            return theme.characterIncorrect
        case .upcoming:
            return theme.characterUpcoming
        case .current:
            return .white // Current character uses white text with colored background
        }
    }
}

struct CharacterHighlight {
    let index: Int
    let state: CharacterState
    let isCurrentChar: Bool
    
    enum CharacterState {
        case correct
        case incorrect
        case upcoming
        case current
    }
}