// ABOUTME: Manages keyboard preview window for showing layout details
// ABOUTME: Provides a dedicated window to display keyboard layout visualization

import SwiftUI
import AppKit

class KeyboardPreviewWindowManager: ObservableObject {
    private var previewWindow: NSWindow?
    
    private let windowWidth: CGFloat = 800
    private let windowHeight: CGFloat = 600
    
    func showPreview(for layoutName: String) {
        closePreview() // Close any existing preview window
        
        // Create new preview window
        createPreviewWindow(for: layoutName)
    }
    
    private func createPreviewWindow(for layoutName: String) {
        print("KeyOgre: Creating keyboard preview window for \(layoutName)")
        
        // Create a dummy KeyEventTap for the preview (no actual monitoring needed)
        let dummyKeyEventTap = KeyEventTap()
        
        // Create the preview content view with environment
        let previewContent = KeyboardPreviewView(layoutName: layoutName)
            .environmentObject(dummyKeyEventTap)
        
        // Create the hosting controller
        let hostingController = NSHostingController(rootView: previewContent)
        
        // Get the main screen for positioning
        guard let screen = NSScreen.main else { return }
        let screenFrame = screen.frame
        
        // Center the window on screen, slightly offset from settings window
        let windowX = (screenFrame.width - windowWidth) / 2 + 50
        let windowY = (screenFrame.height - windowHeight) / 2 + 50
        
        let windowFrame = NSRect(
            x: windowX,
            y: windowY,
            width: windowWidth,
            height: windowHeight
        )
        
        // Create window with resizable style
        let window = NSWindow(
            contentRect: windowFrame,
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        
        window.contentViewController = hostingController
        window.title = "Keyboard Preview - \(layoutName)"
        window.isReleasedWhenClosed = false
        window.minSize = NSSize(width: 600, height: 400)
        window.center()
        
        // Store reference and show
        previewWindow = window
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        
        print("KeyOgre: ✅ Keyboard preview window created and shown")
    }
    
    func closePreview() {
        previewWindow?.close()
        previewWindow = nil
    }
    
    deinit {
        closePreview()
    }
}