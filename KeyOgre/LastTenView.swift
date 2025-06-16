// ABOUTME: SwiftUI component displaying rolling buffer of last 10 typed characters
// ABOUTME: Updates in real-time as user types, shows character history below keyboard

import SwiftUI
import Combine

struct LastTenView: View {
    @EnvironmentObject var keyEventTap: KeyEventTap
    @State private var characters: [Character] = []
    @State private var cancellables = Set<AnyCancellable>()
    
    private let theme = ColorTheme.defaultTheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Last 10 Characters:")
                .font(.headline)
                .foregroundColor(theme.keyText)
            
            HStack(spacing: 8) {
                ForEach(Array(characters.enumerated()), id: \.offset) { index, character in
                    Text(String(character))
                        .font(.system(size: 20, weight: .medium, design: .monospaced))
                        .foregroundColor(theme.keyText)
                        .frame(width: 30, height: 30)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(theme.keyBackground)
                                .stroke(theme.keyBorder, lineWidth: 1)
                        )
                        .animation(.easeInOut(duration: 0.2), value: character)
                }
                
                // Fill remaining slots with empty boxes
                ForEach(characters.count..<10, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 6)
                        .fill(theme.keyBackground.opacity(0.3))
                        .stroke(theme.keyBorder.opacity(0.3), lineWidth: 1)
                        .frame(width: 30, height: 30)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.keyBackground.opacity(0.7))
                .stroke(theme.keyBorder, lineWidth: 1)
        )
        .onAppear {
            keyEventTap.lastTenCharacters
                .receive(on: DispatchQueue.main)
                .sink { newCharacters in
                    withAnimation(.easeInOut(duration: 0.3)) {
                        characters = newCharacters
                    }
                }
                .store(in: &cancellables)
        }
    }
}

struct LastTenView_Previews: PreviewProvider {
    static var previews: some View {
        LastTenView()
            .environmentObject(KeyEventTap())
            .frame(width: 400, height: 100)
    }
}