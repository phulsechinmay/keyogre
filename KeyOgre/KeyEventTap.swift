// ABOUTME: Simple key event listener using NSEvent for keyboard monitoring
// ABOUTME: Minimal implementation to detect key presses and print them

import Foundation
import Combine
import AppKit

protocol KeyEventTapProtocol: ObservableObject {
    var lastTenCharacters: CurrentValueSubject<[Character], Never> { get }
    var pressedKeysSet: CurrentValueSubject<Set<CGKeyCode>, Never> { get }
    func startMonitoring()
    func stopMonitoring()
}

class KeyEventTap: KeyEventTapProtocol, ObservableObject {
    let lastTenCharacters = CurrentValueSubject<[Character], Never>([])
    let pressedKeysSet = CurrentValueSubject<Set<CGKeyCode>, Never>([])
    
    private var localMonitor: Any?
    private var keyUpMonitor: Any?
    private var flagsMonitor: Any?
    private var characterBuffer: [Character] = []
    private var pressedKeys: Set<CGKeyCode> = []
    
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
        characterBuffer.append(character)
        if characterBuffer.count > 10 {
            characterBuffer.removeFirst()
        }
        lastTenCharacters.send(characterBuffer)
    }
}