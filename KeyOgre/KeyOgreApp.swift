// ABOUTME: Main app entry point for KeyOgre keyboard overlay application
// ABOUTME: Handles app lifecycle, global hotkey monitoring, and dropdown window management

import SwiftUI
import Combine
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    private let keyEventTap = KeyEventTap()
    private let dropdownManager = DropdownWindowManager()
    private var globalHotkeyMonitor: Any?
    private var localHotkeyMonitor: Any?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBarApp()
        setupGlobalHotkey()
        
        // Show the dropdown window on startup
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.dropdownManager.showDropdown(keyEventTap: self?.keyEventTap ?? KeyEventTap())
        }
    }
    
    private func setupMenuBarApp() {
        // Hide dock icon and make this a menu bar app
        NSApp.setActivationPolicy(.accessory)
    }
    
    private func setupGlobalHotkey() {
        print("KeyOgre: Setting up hotkey monitors...")
        
        // Helper function to handle hotkey detection
        func handleHotkeyEvent(_ event: NSEvent, source: String) {
            let char = event.charactersIgnoringModifiers ?? ""
            print("KeyOgre: [\(source)] Key event - keyCode: \(event.keyCode), char: '\(char)', modifiers: \(event.modifierFlags)")
            
            // Check for Command+` (try multiple key codes for backtick)
            let isCommandPressed = event.modifierFlags.contains(.command)
            let isBacktickKey = event.keyCode == 50 || char == "`" || char == "~"
            
            print("KeyOgre: [\(source)] Command pressed: \(isCommandPressed), Backtick key: \(isBacktickKey)")
            
            if isCommandPressed && isBacktickKey {
                print("KeyOgre: [\(source)] 🎯 Command+` hotkey detected! Toggling dropdown...")
                DispatchQueue.main.async {
                    self.dropdownManager.toggleDropdown(keyEventTap: self.keyEventTap)
                }
            }
        }
        
        // Setup global hotkey monitor (for when app is not in focus)
        globalHotkeyMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { event in
            handleHotkeyEvent(event, source: "GLOBAL")
        }
        
        // Setup local hotkey monitor (for when app is in focus)
        localHotkeyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            handleHotkeyEvent(event, source: "LOCAL")
            return event // Return the event to allow normal processing
        }
        
        print("KeyOgre: Global monitor: \(globalHotkeyMonitor != nil ? "✅" : "❌")")
        print("KeyOgre: Local monitor: \(localHotkeyMonitor != nil ? "✅" : "❌")")
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // Don't quit the app when the last window is closed - stay running in background
        print("KeyOgre: Last window closed, but staying active in background")
        return false
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        print("KeyOgre: App terminating, cleaning up monitors")
        if let monitor = globalHotkeyMonitor {
            NSEvent.removeMonitor(monitor)
        }
        if let monitor = localHotkeyMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
}

@main
struct KeyOgreApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}


struct ContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            KeyboardView()
            LastTenView()
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
