// ABOUTME: CGEventTap wrapper that monitors keyboard events and publishes them via Combine
// ABOUTME: Handles accessibility permissions and provides mock-friendly protocol for testing

import Foundation
import Combine
import ApplicationServices
import AppKit
import IOKit.hid

protocol KeyEventTapProtocol: ObservableObject {
    var currentKeyCode: CurrentValueSubject<CGKeyCode?, Never> { get }
    var lastTenCharacters: CurrentValueSubject<[Character], Never> { get }
    func startMonitoring()
    func stopMonitoring()
}

class KeyEventTap: KeyEventTapProtocol, ObservableObject {
    let currentKeyCode = CurrentValueSubject<CGKeyCode?, Never>(nil)
    let lastTenCharacters = CurrentValueSubject<[Character], Never>([])
    
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var characterBuffer: [Character] = []
    
    func startMonitoring() {
        print("KeyOgre: Attempting to start event monitoring...")
        
        // Explicitly request Input Monitoring permission
        let hasPermission = IOHIDRequestAccess(kIOHIDRequestTypeListenEvent)
        print("KeyOgre: Input Monitoring permission request result: \(hasPermission)")
        
        if !hasPermission {
            print("KeyOgre: Input Monitoring permission denied or not granted yet")
            promptForInputMonitoringPermissions()
            return
        }
        
        // Create the event tap - this should trigger Input Monitoring permission request
        let eventMask = (1 << CGEventType.keyDown.rawValue)
        
        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: { (proxy, type, event, refcon) -> Unmanaged<CGEvent>? in
                guard let refcon = refcon else { return Unmanaged.passUnretained(event) }
                let keyEventTap = Unmanaged<KeyEventTap>.fromOpaque(refcon).takeUnretainedValue()
                keyEventTap.handleKeyEvent(event: event)
                return Unmanaged.passUnretained(event)
            },
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        )
        
        guard let eventTap = eventTap else {
            print("KeyOgre: Failed to create event tap - Input Monitoring permission required")
            print("KeyOgre: App should now appear in System Preferences > Privacy & Security > Input Monitoring")
            promptForInputMonitoringPermissions()
            return
        }
        
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)
        
        print("KeyOgre: Event monitoring started successfully")
    }
    
    func stopMonitoring() {
        if let eventTap = eventTap {
            CGEvent.tapEnable(tap: eventTap, enable: false)
            CFMachPortInvalidate(eventTap)
        }
        
        if let runLoopSource = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        }
        
        eventTap = nil
        runLoopSource = nil
    }
    
    private func handleKeyEvent(event: CGEvent) {
        let keyCode = CGKeyCode(event.getIntegerValueField(.keyboardEventKeycode))
        
        // Debug logging to show key presses
        if let character = keyCodeToCharacter(keyCode) {
            print("KeyOgre: Key pressed - Code: \(keyCode), Character: '\(character)'")
        } else {
            print("KeyOgre: Key pressed - Code: \(keyCode), Character: (unmapped)")
        }
        
        DispatchQueue.main.async {
            self.currentKeyCode.send(keyCode)
            
            // Convert keycode to character for buffer
            if let character = self.keyCodeToCharacter(keyCode) {
                self.addCharacterToBuffer(character)
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
    
    private func keyCodeToCharacter(_ keyCode: CGKeyCode) -> Character? {
        // Basic ANSI keycode to character mapping
        let keyMap: [CGKeyCode: Character] = [
            0: "a", 1: "s", 2: "d", 3: "f", 4: "h", 5: "g", 6: "z", 7: "x", 8: "c", 9: "v",
            11: "b", 12: "q", 13: "w", 14: "e", 15: "r", 16: "y", 17: "t", 18: "1", 19: "2",
            20: "3", 21: "4", 22: "6", 23: "5", 24: "=", 25: "9", 26: "7", 27: "-", 28: "8",
            29: "0", 30: "]", 31: "o", 32: "u", 33: "[", 34: "i", 35: "p", 37: "l", 38: "j",
            39: "'", 40: "k", 41: ";", 42: "\\", 43: ",", 44: "/", 45: "n", 46: "m", 47: ".",
            49: " ", 50: "`"
        ]
        
        return keyMap[keyCode]
    }
    
    
    private func promptForInputMonitoringPermissions() {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "Input Monitoring Permission Required"
            alert.informativeText = "KeyOgre needs permission to monitor keyboard input to show live key highlights. Please grant permission in System Preferences > Privacy & Security > Input Monitoring, then restart KeyOgre."
            alert.addButton(withTitle: "Open System Preferences")
            alert.addButton(withTitle: "Quit KeyOgre")
            
            let response = alert.runModal()
            if response == .alertFirstButtonReturn {
                // Open Input Monitoring preferences
                NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent")!)
            } else {
                // User chose to quit
                NSApplication.shared.terminate(nil)
            }
        }
    }
}