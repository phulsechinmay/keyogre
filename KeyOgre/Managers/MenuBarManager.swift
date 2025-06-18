// ABOUTME: Manages the menu bar icon and dropdown menu for KeyOgre application
// ABOUTME: Provides standard macOS menu bar experience with Open, Settings, and Quit options

import AppKit
import SwiftUI

class MenuBarManager: ObservableObject {
    private var statusItem: NSStatusItem?
    private weak var appDelegate: AppDelegate?
    private var openMenuItem: NSMenuItem?
    
    init(appDelegate: AppDelegate) {
        self.appDelegate = appDelegate
        setupMenuBar()
    }
    
    private func setupMenuBar() {
        // Create status item in menu bar
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        guard let statusItem = statusItem else { return }
        
        // Set the menu bar icon
        if let button = statusItem.button {
            // Use keyboard SF Symbol for the icon
            let image = NSImage(systemSymbolName: "keyboard", accessibilityDescription: "KeyOgre")
            image?.size = NSSize(width: 16, height: 16)
            button.image = image
            button.imagePosition = .imageOnly
            button.toolTip = "KeyOgre - Keyboard Overlay"
        }
        
        // Create and set the menu
        let menu = createMenu()
        statusItem.menu = menu
        
        print("KeyOgre: ✅ Menu bar icon created successfully")
    }
    
    private func createMenu() -> NSMenu {
        let menu = NSMenu()
        
        // App title (non-clickable header)
        let titleItem = NSMenuItem()
        titleItem.title = "KeyOgre"
        titleItem.isEnabled = false
        menu.addItem(titleItem)
        
        // Separator
        menu.addItem(NSMenuItem.separator())
        
        // Open/Show KeyOgre option (dynamic text)
        openMenuItem = NSMenuItem(
            title: "Open window",
            action: #selector(toggleKeyOgre),
            keyEquivalent: ""
        )
        openMenuItem?.target = self
        if let openItem = openMenuItem {
            menu.addItem(openItem)
        }
        
        // Settings option
        let settingsItem = NSMenuItem(
            title: "Settings",
            action: #selector(openSettings),
            keyEquivalent: ","
        )
        settingsItem.target = self
        menu.addItem(settingsItem)
        
        // Separator
        menu.addItem(NSMenuItem.separator())
        
        // Quit option
        let quitItem = NSMenuItem(
            title: "Quit KeyOgre",
            action: #selector(quitApp),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)
        
        return menu
    }
    
    @objc private func toggleKeyOgre() {
        print("KeyOgre: Menu bar - Toggle selected")
        // Call the toggle functionality
        appDelegate?.toggleWindow()
    }
    
    @objc private func openSettings() {
        print("KeyOgre: Menu bar - Settings selected")
        appDelegate?.showSettings()
    }
    
    @objc private func quitApp() {
        print("KeyOgre: Menu bar - Quit selected")
        NSApplication.shared.terminate(nil)
    }
    
    
    func updateMenuText(isVisible: Bool) {
        // Update the menu item text based on window visibility
        if isVisible {
            openMenuItem?.title = "Hide window"
        } else {
            openMenuItem?.title = "Open window"
        }
    }
    
    deinit {
        // Clean up the status item
        if let statusItem = statusItem {
            NSStatusBar.system.removeStatusItem(statusItem)
        }
    }
}