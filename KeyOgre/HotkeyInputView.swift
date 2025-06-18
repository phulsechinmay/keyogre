// ABOUTME: SwiftUI component for capturing and displaying custom keyboard shortcuts
// ABOUTME: Allows users to set their preferred hotkey for toggling the KeyOgre overlay

import SwiftUI
import KeyboardShortcuts

struct HotkeyInputView: View {
    @ObservedObject private var keyboardShortcutsManager = KeyboardShortcutsManager.shared
    @State private var isRecording = false
    @State private var currentShortcut: KeyboardShortcuts.Shortcut?
    @State private var eventMonitor: Any?
    
    private let theme = ColorTheme.defaultTheme
    
    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            // Left side: Title and instructions
            VStack(alignment: .leading, spacing: 4) {
                Text("Toggle Hotkey")
                    .font(.headline)
                    .foregroundColor(theme.keyText)
                
                Text("Hotkey to show/hide the Keyogre window")
                    .font(.caption)
                    .foregroundColor(theme.keyText.opacity(0.5))
            }
            
            Spacer()
            
            // Right side: Hotkey input with embedded clear button
            Button(action: toggleRecording) {
                HStack(spacing: 8) {
                    if isRecording {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 8, height: 8)
                            
                            Text("recording...")
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(theme.keyText.opacity(0.7))
                                .italic()
                        }
                    } else {
                        shortcutDisplay
                    }
                    
                    Spacer()
                    
                    // Clear button (x) inside the input box - only show when hotkey is set and not recording
                    if currentShortcut != nil && !isRecording {
                        Button(action: clearHotkey) {
                            Image(systemName: "xmark")
                                .font(.system(size: 8, weight: .medium))
                                .foregroundColor(.black)
                                .frame(width: 16, height: 16)
                                .background(Circle().fill(Color.white))
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
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(width: 180, height: 40) // Fixed width for consistent size
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isRecording ? theme.settingsInputBackgroundColor.opacity(0.3) : theme.settingsInputBackgroundColor)
                        .stroke(theme.keyBorder, lineWidth: 1)
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
        .padding(.vertical, 12)
        .onAppear {
            loadCurrentShortcut()
        }
        .onDisappear {
            stopRecording()
        }
    }
    
    private var shortcutDisplay: some View {
        HStack(spacing: 4) {
            if let shortcut = currentShortcut {
                // Display modifier symbols
                if shortcut.modifiers.contains(.control) {
                    modifierSymbol("⌃")
                }
                if shortcut.modifiers.contains(.option) {
                    modifierSymbol("⌥")
                }
                if shortcut.modifiers.contains(.shift) {
                    modifierSymbol("⇧")
                }
                if shortcut.modifiers.contains(.command) {
                    modifierSymbol("⌘")
                }
                
                // Display the key
                Text(keyDisplayName(for: shortcut.key))
                    .font(.system(.body, design: .monospaced, weight: .medium))
                    .foregroundColor(theme.keyText)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        RoundedRectangle(cornerRadius: 3)
                            .fill(theme.keyBackground.opacity(0.6))
                    )
            } else {
                Text("⌘`")
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(theme.keyText)
            }
        }
    }
    
    private func modifierSymbol(_ symbol: String) -> some View {
        Text(symbol)
            .font(.system(.body, design: .monospaced, weight: .medium))
            .foregroundColor(theme.keyText)
            .frame(width: 20, height: 20)
            .background(
                RoundedRectangle(cornerRadius: 3)
                    .fill(theme.keyBackground.opacity(0.6))
            )
    }
    
    private func keyDisplayName(for key: KeyboardShortcuts.Key?) -> String {
        guard let key = key else { return "?" }
        
        // Create a temporary shortcut with no modifiers to get the key character
        let shortcut = KeyboardShortcuts.Shortcut(key)
        
        // The shortcut description includes modifier symbols + key character
        // Since we have no modifiers, this will just be the key character
        let keyCharacter = shortcut.description
        
        // For certain special keys, provide more user-friendly names than symbols
        switch key {
        case .space: return "Space"
        case .tab: return "Tab" 
        case .return: return "Return"
        case .escape: return "Esc"
        case .delete: return "Delete"
        default: return keyCharacter
        }
    }
    
    private func loadCurrentShortcut() {
        currentShortcut = KeyboardShortcuts.getShortcut(for: .toggleKeyOgre)
    }
    
    private func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    private func startRecording() {
        isRecording = true
        
        // Create a local event monitor for recording the new shortcut
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            let keyCode = KeyboardShortcuts.Key(rawValue: Int(UInt32(event.keyCode)))
            let modifiers = event.modifierFlags.intersection([.command, .option, .control, .shift])
            
                let newShortcut = KeyboardShortcuts.Shortcut(keyCode, modifiers: modifiers)
                
                // Update the shortcut
                KeyboardShortcuts.setShortcut(newShortcut, for: .toggleKeyOgre)
                currentShortcut = newShortcut
                
                DispatchQueue.main.async {
                    self.stopRecording()
                }
                
                // Don't pass the event through
                return nil
        }
        
        // Auto-cancel recording after 10 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            if self.isRecording {
                self.stopRecording()
            }
        }
    }
    
    private func stopRecording() {
        isRecording = false
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }
    
    private func clearHotkey() {
        KeyboardShortcuts.reset(.toggleKeyOgre)
        currentShortcut = nil
    }
}

struct HotkeyInputView_Previews: PreviewProvider {
    static var previews: some View {
        HotkeyInputView()
            .frame(width: 400)
            .padding()
            .background(Color.black.opacity(0.1))
    }
}

