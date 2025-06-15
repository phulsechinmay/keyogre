// ABOUTME: Main app entry point for KeyOgre keyboard overlay application
// ABOUTME: Handles app lifecycle, global hotkey monitoring, and window management

import SwiftUI
import Combine
import AppKit

@main
struct KeyOgreApp: App {
    @StateObject private var keyEventTap = KeyEventTap()
    @StateObject private var hotKeyManager = GlobalHotKeyManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(keyEventTap)
        }
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .newItem) {}
        }
    }
    
    init() {
        // Setup will happen in onAppear of ContentView
    }
}

class GlobalHotKeyManager: ObservableObject {
    private var eventMonitor: Any?
    
    func setupGlobalHotkey() {
        // Monitor for global key events (⌃⌥K)
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { event in
            if event.modifierFlags.contains([.control, .option]) && event.keyCode == 40 { // K key
                DispatchQueue.main.async {
                    self.toggleWindow()
                }
            }
        }
    }
    
    private func toggleWindow() {
        if let window = NSApp.windows.first {
            if window.isVisible {
                window.orderOut(nil)
            } else {
                window.makeKeyAndOrderFront(nil)
                NSApp.activate(ignoringOtherApps: true)
            }
        }
    }
    
    func cleanup() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }
    
    deinit {
        cleanup()
    }
}

struct ContentView: View {
    @EnvironmentObject var keyEventTap: KeyEventTap
    @StateObject private var hotKeyManager = GlobalHotKeyManager()
    
    var body: some View {
        VStack(spacing: 20) {
            KeyboardView()
                .environmentObject(keyEventTap)
            
            LastTenView()
                .environmentObject(keyEventTap)
        }
        .padding()
        .frame(width: 800, height: 400)
        .onAppear {
            keyEventTap.startMonitoring()
            hotKeyManager.setupGlobalHotkey()
        }
        .onDisappear {
            keyEventTap.stopMonitoring()
            hotKeyManager.cleanup()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(KeyEventTap())
    }
}