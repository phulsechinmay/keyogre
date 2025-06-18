// ABOUTME: Manages the settings window lifecycle, positioning, and display
// ABOUTME: Provides a dedicated window for KeyOgre settings with tab-based navigation

import SwiftUI
import AppKit

class SettingsWindowManager: ObservableObject {
    private var settingsWindow: NSWindow?
    
    private let windowWidth: CGFloat = 600
    private let windowHeight: CGFloat = 400
    
    func showSettings() {
        if let window = settingsWindow {
            // If window exists, just bring it to front
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        
        // Create new settings window
        createSettingsWindow()
    }
    
    private func createSettingsWindow() {
        print("KeyOgre: Creating settings window")
        
        // Create the settings content view
        let settingsContent = SettingsView()
        
        // Create the hosting controller
        let hostingController = NSHostingController(rootView: settingsContent)
        
        // Get the main screen for positioning
        guard let screen = NSScreen.main else { return }
        let screenFrame = screen.frame
        
        // Center the window on screen
        let windowX = (screenFrame.width - windowWidth) / 2
        let windowY = (screenFrame.height - windowHeight) / 2
        
        let windowFrame = NSRect(
            x: windowX,
            y: windowY,
            width: windowWidth,
            height: windowHeight
        )
        
        // Create window with resizable settings window style
        let window = NSWindow(
            contentRect: windowFrame,
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        
        window.contentViewController = hostingController
        window.title = "KeyOgre Settings"
        window.isReleasedWhenClosed = false
        window.minSize = NSSize(width: 500, height: 350)
        window.center()
        
        // Store reference and show
        settingsWindow = window
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        
        print("KeyOgre: ✅ Settings window created and shown")
    }
    
    func closeSettings() {
        settingsWindow?.close()
        settingsWindow = nil
    }
    
    deinit {
        closeSettings()
    }
}