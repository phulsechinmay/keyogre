// ABOUTME: Freeform typing mode view showing current typing behavior with 3-line display
// ABOUTME: Preserves existing TypingDisplayView functionality in the new mode system

import SwiftUI

struct FreeformModeView: View {
    @EnvironmentObject var keyEventTap: KeyEventTap
    
    var body: some View {
        VStack(spacing: 20) {
            TypingDisplayView()
                .environmentObject(keyEventTap)
            
            KeyboardView()
                .environmentObject(keyEventTap)
            
            // Keyboard selection dropdown
            KeyboardSelectionView()
        }
    }
}

struct KeyboardSelectionView: View {
    @StateObject private var keyboardLayoutManager = KeyboardLayoutManager.shared
    private let theme = ColorTheme.defaultTheme
    
    var body: some View {
        HStack {
            Spacer()
            
            Picker(
                "Select Keyboard",
                selection: Binding(
                    get: { keyboardLayoutManager.selectedConfiguration?.id ?? UUID() },
                    set: { selectedId in
                        if let config = keyboardLayoutManager.availableConfigurations.first(where: {
                            $0.id == selectedId
                        }) {
                            keyboardLayoutManager.switchToConfiguration(config)
                        }
                    }
                )
            ) {
                ForEach(keyboardLayoutManager.availableConfigurations, id: \.id) { config in
                    HStack {
                        Image(systemName: "keyboard")
                            .font(.system(size: 12))
                        Text(config.name)
                            .font(.system(size: 13))
                    }
                    .tag(config.id)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .labelsHidden()
            .frame(maxWidth: 200)
            
            Spacer()
        }
    }
}