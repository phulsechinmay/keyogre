// ABOUTME: Main app entry point for KeyOgre keyboard overlay application
// ABOUTME: Handles app lifecycle, global hotkey monitoring, and dropdown window management

import SwiftUI
import Combine
import AppKit
import KeyboardShortcuts

class AppDelegate: NSObject, NSApplicationDelegate {
    private let keyEventTap = KeyEventTap()
    private let dropdownManager = DropdownWindowManager()
    private let keyboardShortcutsManager = KeyboardShortcutsManager.shared
    private let settingsWindowManager = SettingsWindowManager()
    private var menuBarManager: MenuBarManager?
    private var isWindowVisible = false
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBarApp()
        setupGlobalHotkey()
        
        // Creating window from AppDelegate is necessary for it to show up 
        // as overlay on fullscreen apps
        // https://stackoverflow.com/questions/79153578/keeping-swiftui-window-on-top-of-all-other-apps-even-in-fullscreen
        dropdownManager.createOverlayWindow(keyEventTap: keyEventTap)
        
        // Show the dropdown window on startup
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            self.showWindow()
        }
    }
    
    private func setupMenuBarApp() {
        // Hide dock icon and make this a menu bar app
        NSApp.setActivationPolicy(.accessory)
        
        // Initialize menu bar icon and menu
        menuBarManager = MenuBarManager(appDelegate: self)
        print("KeyOgre: Menu bar app setup completed")
    }
    
    private func setupGlobalHotkey() {
        print("KeyOgre: Setting up KeyboardShortcuts global hotkey...")
        
        // Log debug info first
        keyboardShortcutsManager.logDebugInfo()
        
        // Reset to new default (Command + backtick) to override any cached old shortcut
        keyboardShortcutsManager.resetToDefaultShortcut()
        
        // Setup the global hotkey
        keyboardShortcutsManager.setupGlobalHotkey { [weak self] in
            guard let self = self else { return }
            print("KeyOgre: 🎯 KeyboardShortcuts hotkey triggered! Toggling dropdown...")
            self.toggleWindow()
        }
        
        // Log final status
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.keyboardShortcutsManager.logDebugInfo()
        }
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // Don't quit the app when the last window is closed - stay running in background
        print("KeyOgre: Last window closed, but staying active in background")
        return false
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        print("KeyOgre: App terminating, cleaning up KeyboardShortcuts and KeyEventTap")
        keyboardShortcutsManager.removeGlobalHotkey()
        keyEventTap.stopMonitoring()
    }
    
    // MARK: - Window Management
    func toggleWindow() {
        if isWindowVisible {
            hideWindow()
        } else {
            showWindow()
        }
    }
    
    func showWindow() {
        // Start key monitoring when showing window
        keyEventTap.startMonitoring()
        
        dropdownManager.showDropdown(keyEventTap: keyEventTap)
        isWindowVisible = true
        
        // Update menu bar menu text
        menuBarManager?.updateMenuText(isVisible: true)
        
        // Activate app to bring it to front
        NSApp.activate(ignoringOtherApps: true)
        print("KeyOgre: Window shown and app activated")
    }
    
    private func hideWindow() {
        // Stop key monitoring when hiding window
        keyEventTap.stopMonitoring()
        
        dropdownManager.hideDropdown()
        isWindowVisible = false
        
        // Update menu bar menu text
        menuBarManager?.updateMenuText(isVisible: false)
        
        print("KeyOgre: Window hidden")
    }
    
    func showSettings() {
        settingsWindowManager.showSettings()
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
