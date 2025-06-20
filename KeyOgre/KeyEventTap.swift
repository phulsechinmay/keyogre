// ABOUTME: Simple key event listener using NSEvent for keyboard monitoring
// ABOUTME: Minimal implementation to detect key presses and print them

import Foundation
import Combine
import AppKit

struct TypingLines {
    let currentLine: String
    let previousLine1: String  // Most recent previous line
    let previousLine2: String  // Second previous line
    let allText: String
}

protocol KeyEventTapProtocol: ObservableObject {
    var lastTenCharacters: CurrentValueSubject<[Character], Never> { get }
    var typingLines: CurrentValueSubject<TypingLines, Never> { get }
    var pressedKeysSet: CurrentValueSubject<Set<CGKeyCode>, Never> { get }
    var currentMode: CurrentValueSubject<MainWindowMode, Never> { get }
    func startMonitoring()
    func stopMonitoring()
    func setCurrentMode(_ mode: MainWindowMode)
    func registerCodingPracticeHandler(_ handler: ((Character) -> Void)?)
    func registerBackspaceHandler(_ handler: (() -> Void)?)
    func registerEnterHandler(_ handler: (() -> Void)?)
    func registerTabHandler(_ handler: (() -> Void)?)
}

class KeyEventTap: KeyEventTapProtocol, ObservableObject {
    let lastTenCharacters = CurrentValueSubject<[Character], Never>([])
    let typingLines = CurrentValueSubject<TypingLines, Never>(TypingLines(currentLine: "", previousLine1: "", previousLine2: "", allText: ""))
    let pressedKeysSet = CurrentValueSubject<Set<CGKeyCode>, Never>([])
    let currentMode = CurrentValueSubject<MainWindowMode, Never>(.freeform)
    
    private var localMonitor: Any?
    private var keyUpMonitor: Any?
    private var flagsMonitor: Any?
    private var characterBuffer: [Character] = []
    private var fullTextBuffer: String = ""
    private var pressedKeys: Set<CGKeyCode> = []
    
    // Coding practice event handlers
    private var codingPracticeCharacterHandler: ((Character) -> Void)?
    private var backspaceHandler: (() -> Void)?
    private var enterHandler: (() -> Void)?
    private var tabHandler: (() -> Void)?
    
    func startMonitoring() {
        print("KeyOgre: Starting local key monitoring...")
        
        // Local monitor for key down events
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            self.handleKeyDownEvent(event: event, source: "LOCAL")
            return event
        }
        
        // Local monitor for key up events
        keyUpMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyUp) { event in
            self.handleKeyUpEvent(event: event, source: "LOCAL")
            return event
        }
        
        // Local monitor for modifier key changes
        flagsMonitor = NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { event in
            self.handleModifierKeyEvent(event: event, source: "LOCAL")
            return event
        }
        
        if localMonitor != nil && keyUpMonitor != nil && flagsMonitor != nil {
            print("KeyOgre: ✅ Local key monitor started (captures key down/up and modifiers when app has focus)")
            print("KeyOgre: Try typing or pressing modifier keys!")
        } else {
            print("KeyOgre: ❌ Failed to start local key monitor")
        }
    }
    
    func stopMonitoring() {
        print("KeyOgre: Stopping key monitoring...")
        
        if let local = localMonitor {
            NSEvent.removeMonitor(local)
            localMonitor = nil
            print("KeyOgre: ✅ Local key down monitor stopped")
        }
        
        if let keyUp = keyUpMonitor {
            NSEvent.removeMonitor(keyUp)
            keyUpMonitor = nil
            print("KeyOgre: ✅ Local key up monitor stopped")
        }
        
        if let flags = flagsMonitor {
            NSEvent.removeMonitor(flags)
            flagsMonitor = nil
            print("KeyOgre: ✅ Local flags monitor stopped")
        }
        
        // Clear any pressed keys when stopping
        pressedKeys.removeAll()
        pressedKeysSet.send([])
    }
    
    private func handleKeyDownEvent(event: NSEvent, source: String) {
        let keyCode = CGKeyCode(event.keyCode)
        let character = event.charactersIgnoringModifiers ?? "?"
        
        print("KeyOgre: 🔥 [\(source)] Key DOWN - Code: \(keyCode), Character: '\(character)'")
        
        // Update the published values
        DispatchQueue.main.async {
            // Add to pressed keys set
            self.pressedKeys.insert(keyCode)
            
            // Publish the updated pressed keys set
            self.pressedKeysSet.send(self.pressedKeys)
            
            // Handle special keys for coding practice mode
            if self.currentMode.value == .codingPractice {
                if keyCode == 51 { // Backspace key
                    self.backspaceHandler?()
                    return
                } else if keyCode == 48 { // Tab key
                    self.tabHandler?()
                    return
                }
            }
            
            // Add character to buffer
            if let char = character.first {
                self.addCharacterToBuffer(char)
            }
        }
    }
    
    private func handleKeyUpEvent(event: NSEvent, source: String) {
        let keyCode = CGKeyCode(event.keyCode)
        let character = event.charactersIgnoringModifiers ?? "?"
        
        print("KeyOgre: 🔥 [\(source)] Key UP - Code: \(keyCode), Character: '\(character)'")
        
        // Update the published values
        DispatchQueue.main.async {
            // Remove from pressed keys set
            self.pressedKeys.remove(keyCode)
            
            // Publish the updated pressed keys set
            self.pressedKeysSet.send(self.pressedKeys)
        }
    }
    
    private func handleModifierKeyEvent(event: NSEvent, source: String) {
        let newFlags = event.modifierFlags
        let keyCode = CGKeyCode(event.keyCode)
        
        // Map modifier flags for tracking
        let modifierFlags: [NSEvent.ModifierFlags] = [
            .shift, .control, .option, .command, .capsLock
        ]
        
        // Check each modifier flag to see if it's currently pressed
        for flag in modifierFlags {
            let isPressed = newFlags.contains(flag)
            let wasAlreadyPressed = pressedKeys.contains(keyCode)
            
            // Only process if the state changed for this specific key
            if isPressed && !wasAlreadyPressed {
                // Key was just pressed
                let modifierName = getModifierName(for: flag, keyCode: keyCode)
                print("KeyOgre: 🎯 [\(source)] Modifier DOWN - Code: \(keyCode), Name: \(modifierName)")
                
                DispatchQueue.main.async {
                    self.pressedKeys.insert(keyCode)
                    self.pressedKeysSet.send(self.pressedKeys)
                }
            } else if !isPressed && wasAlreadyPressed {
                // Key was just released
                let modifierName = getModifierName(for: flag, keyCode: keyCode)
                print("KeyOgre: 🎯 [\(source)] Modifier UP - Code: \(keyCode), Name: \(modifierName)")
                
                DispatchQueue.main.async {
                    self.pressedKeys.remove(keyCode)
                    self.pressedKeysSet.send(self.pressedKeys)
                }
            }
        }
    }
    
    private func getModifierName(for flag: NSEvent.ModifierFlags, keyCode: CGKeyCode) -> String {
        switch flag {
        case .shift:
            return keyCode == 56 ? "Left Shift" : "Right Shift"
        case .control:
            return keyCode == 59 ? "Left Ctrl" : "Right Ctrl"
        case .option:
            return keyCode == 58 ? "Left Alt" : "Right Alt"
        case .command:
            return keyCode == 55 ? "Left Cmd" : "Right Cmd"
        case .capsLock:
            return "Caps Lock"
        default:
            return "Unknown Modifier"
        }
    }
    
    private func addCharacterToBuffer(_ character: Character) {
        // Legacy 10-character buffer for backward compatibility
        characterBuffer.append(character)
        if characterBuffer.count > 10 {
            characterBuffer.removeFirst()
        }
        lastTenCharacters.send(characterBuffer)
        
        // Route character based on current mode
        let currentModeValue = currentMode.value
        
        if currentModeValue == .codingPractice {
            // Handle coding practice mode
            if character == "\r" || character == "\n" {
                enterHandler?()
            } else {
                codingPracticeCharacterHandler?(character)
            }
        } else {
            // Handle freeform mode (legacy behavior)
            if character == "\r" || character == "\n" {
                handleNewlineCharacter()
            } else {
                // Regular character - add to buffer
                fullTextBuffer.append(character)
                if fullTextBuffer.count > 200 {
                    fullTextBuffer.removeFirst()
                }
                updateTypingLines()
            }
        }
    }
    
    private func handleNewlineCharacter() {
        // Get current line before processing newline
        let lines = fullTextBuffer.components(separatedBy: "\n")
        let currentLineBeforeEnter = lines.last ?? ""
        
        print("KeyOgre: Enter pressed, current line: '\(currentLineBeforeEnter)'")
        
        // Check if current line is empty or contains only whitespace
        let trimmedCurrentLine = currentLineBeforeEnter.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedCurrentLine.isEmpty {
            // Current line is empty/whitespace - clear it but don't change previous line
            if lines.count > 1 {
                // Keep all lines except the last (current) one
                let previousLines = Array(lines.dropLast())
                fullTextBuffer = previousLines.joined(separator: "\n")
                if !previousLines.isEmpty {
                    fullTextBuffer += "\n"
                }
            } else {
                // Only one line and it's empty - clear everything
                fullTextBuffer = ""
            }
            print("KeyOgre: Cleared empty line, buffer: '\(fullTextBuffer)'")
        } else {
            // Current line has content - add newline to create new line
            fullTextBuffer.append("\n")
            if fullTextBuffer.count > 200 {
                fullTextBuffer.removeFirst()
            }
            print("KeyOgre: Added newline, buffer: '\(fullTextBuffer)'")
        }
        
        updateTypingLines()
    }
    
    private func updateTypingLines() {
        let lines = fullTextBuffer.components(separatedBy: "\n")
        
        let currentLine: String
        let previousLine1: String
        let previousLine2: String
        
        // Extract lines from most recent to oldest
        if lines.count >= 3 {
            // 3+ lines exist
            currentLine = lines.last ?? ""
            previousLine1 = lines[lines.count - 2]
            previousLine2 = lines[lines.count - 3]
        } else if lines.count == 2 {
            // 2 lines exist
            currentLine = lines.last ?? ""
            previousLine1 = lines[lines.count - 2]
            previousLine2 = ""
        } else if lines.count == 1 {
            // Only one line exists
            currentLine = lines[0]
            previousLine1 = ""
            previousLine2 = ""
        } else {
            // No lines
            currentLine = ""
            previousLine1 = ""
            previousLine2 = ""
        }
        
        let typingData = TypingLines(
            currentLine: currentLine,
            previousLine1: previousLine1,
            previousLine2: previousLine2,
            allText: fullTextBuffer
        )
        
        typingLines.send(typingData)
    }
    
    // MARK: - Mode Management
    
    func setCurrentMode(_ mode: MainWindowMode) {
        currentMode.send(mode)
    }
    
    func registerCodingPracticeHandler(_ handler: ((Character) -> Void)?) {
        codingPracticeCharacterHandler = handler
    }
    
    func registerBackspaceHandler(_ handler: (() -> Void)?) {
        backspaceHandler = handler
    }
    
    func registerEnterHandler(_ handler: (() -> Void)?) {
        enterHandler = handler
    }
    
    func registerTabHandler(_ handler: (() -> Void)?) {
        tabHandler = handler
    }
}