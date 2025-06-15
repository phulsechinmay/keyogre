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
    private var characterBuffer: [Character] = []
    
    func startMonitoring() {
        print("KeyOgre: Starting local key monitoring...")
        
        // Local monitor for when the app has focus
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            self.handleSimpleKeyEvent(event: event, source: "LOCAL")
            return event
        }
        
        if localMonitor != nil {
            print("KeyOgre: ✅ Local key monitor started (captures keys when app has focus)")
            print("KeyOgre: Try typing in the text field above!")
        } else {
            print("KeyOgre: ❌ Failed to start local key monitor")
        }
    }
    
    func stopMonitoring() {
        print("KeyOgre: Stopping key monitoring...")
        
        if let local = localMonitor {
            NSEvent.removeMonitor(local)
            localMonitor = nil
            print("KeyOgre: ✅ Local monitor stopped")
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
    
    private func addCharacterToBuffer(_ character: Character) {
        characterBuffer.append(character)
        if characterBuffer.count > 10 {
            characterBuffer.removeFirst()
        }
        lastTenCharacters.send(characterBuffer)
    }
}