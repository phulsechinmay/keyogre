// ABOUTME: Simple key event listener using NSEvent for keyboard monitoring
// ABOUTME: Minimal implementation to detect key presses and print them

import Foundation
import Combine
import AppKit

protocol KeyEventTapProtocol: ObservableObject {
    var currentKeyCode: CurrentValueSubject<CGKeyCode?, Never> { get }
    var lastTenCharacters: CurrentValueSubject<[Character], Never> { get }
    func startMonitoring()
    func stopMonitoring()
}

class KeyEventTap: KeyEventTapProtocol, ObservableObject {
    let currentKeyCode = CurrentValueSubject<CGKeyCode?, Never>(nil)
    let lastTenCharacters = CurrentValueSubject<[Character], Never>([])
    
    private var localMonitor: Any?
    private var flagsMonitor: Any?
    private var characterBuffer: [Character] = []
    
    func startMonitoring() {
        print("KeyOgre: Starting local key monitoring...")
        
        // Local monitor for regular keys when the app has focus
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            self.handleSimpleKeyEvent(event: event, source: "LOCAL")
            return event
        }
        
        // Local monitor for modifier key changes
        flagsMonitor = NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { event in
            self.handleModifierKeyEvent(event: event, source: "LOCAL")
            return event
        }
        
        if localMonitor != nil && flagsMonitor != nil {
            print("KeyOgre: ✅ Local key monitor started (captures keys and modifiers when app has focus)")
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
            print("KeyOgre: ✅ Local key monitor stopped")
        }
        
        if let flags = flagsMonitor {
            NSEvent.removeMonitor(flags)
            flagsMonitor = nil
            print("KeyOgre: ✅ Local flags monitor stopped")
        }
    }
    
    private func handleSimpleKeyEvent(event: NSEvent, source: String) {
        let keyCode = UInt16(event.keyCode)
        let character = event.charactersIgnoringModifiers ?? "?"
        
        print("KeyOgre: 🔥 [\(source)] Key pressed - Code: \(keyCode), Character: '\(character)'")
        
        // Update the published values
        DispatchQueue.main.async {
            self.currentKeyCode.send(CGKeyCode(keyCode))
            
            if let char = character.first {
                self.addCharacterToBuffer(char)
            }
            
            // Clear highlight after animation duration
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                self.currentKeyCode.send(nil)
            }
        }
    }
    
    private func handleModifierKeyEvent(event: NSEvent, source: String) {
        let newFlags = event.modifierFlags
        let keyCode = UInt16(event.keyCode)
        
        let changedFlags = NSEvent.ModifierFlags(rawValue: newFlags.rawValue)
        
        // Map modifier flags to key codes based on ANSI60KeyboardLayout
        let modifierKeyCode: CGKeyCode? = CGKeyCode(keyCode)
        
        // Check if a modifier was pressed (not released)
        let wasPressed = newFlags.intersection(changedFlags).rawValue != 0
        
        if let keyCode = modifierKeyCode, wasPressed {
            // Update the published values
            DispatchQueue.main.async {
                self.currentKeyCode.send(keyCode)
                
                // Clear highlight after animation duration
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    self.currentKeyCode.send(nil)
                }
            }
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