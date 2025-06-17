// ABOUTME: Manages the dropdown overlay window that slides from the top of the screen
// ABOUTME: Handles window positioning, animations, and lifecycle for the keyboard overlay

import SwiftUI
import AppKit

class DropdownWindowManager: ObservableObject {
    private var overlayWindow: NSWindow?
    @Published var isVisible = false
    
    private let windowWidth: CGFloat = 800
    private let windowHeight: CGFloat = 500
    
    func showDropdown(keyEventTap: KeyEventTap) {
        print("KeyOgre: showDropdown called")
        guard overlayWindow == nil else { 
            print("KeyOgre: Window already exists, skipping show")
            return 
        }
        
        // Create the content view with close button
        let dropdownContent = DropdownContentView(
            keyEventTap: keyEventTap,
            onClose: { [weak self] in
                self?.hideDropdown()
            }
        )
        
        // Create the hosting controller
        let hostingController = NSHostingController(rootView: dropdownContent)
        
        // Get the main screen
        guard let screen = NSScreen.main else { return }
        let screenFrame = screen.frame
        
        // Position window at top center of screen, initially off-screen
        let startY = screenFrame.maxY
        let finalY = screenFrame.maxY - windowHeight - 20 // 20px from top
        let windowX = (screenFrame.width - windowWidth) / 2
        
        let initialFrame = NSRect(
            x: windowX,
            y: startY,
            width: windowWidth,
            height: windowHeight
        )
        
        // Create window
        let window = NSWindow(
            contentRect: initialFrame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        window.contentViewController = hostingController
        window.level = .floating
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = true
        window.animationBehavior = .none
        
        overlayWindow = window
        
        // Show window and animate
        window.makeKeyAndOrderFront(nil)
        isVisible = true
        print("KeyOgre: ✅ Window created and shown successfully")
        
        // Animate slide down
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.3
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            window.animator().setFrame(
                NSRect(x: windowX, y: finalY, width: windowWidth, height: windowHeight),
                display: true
            )
        }
    }
    
    func hideDropdown() {
        print("KeyOgre: hideDropdown called")
        guard let window = overlayWindow else { 
            print("KeyOgre: No window to hide")
            return 
        }
        
        let currentFrame = window.frame
        let finalY = NSScreen.main?.frame.maxY ?? currentFrame.maxY
        
        // Animate slide up
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.2
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            window.animator().setFrame(
                NSRect(x: currentFrame.minX, y: finalY, width: currentFrame.width, height: currentFrame.height),
                display: true
            )
        }) { [weak self] in
            // Close window after animation
            // Not calling window.close() to reuse the window on next toggle
            self?.overlayWindow = nil
            self?.isVisible = false
        }
    }
    
    func toggleDropdown(keyEventTap: KeyEventTap) {
        print("KeyOgre: toggleDropdown called - isVisible: \(isVisible)")
        
        if isVisible {
            print("KeyOgre: Hiding dropdown...")
            hideDropdown()
        } else {
            print("KeyOgre: Showing dropdown...")
            showDropdown(keyEventTap: keyEventTap)
        }
    }
}

struct DropdownContentView: View {
    @ObservedObject var keyEventTap: KeyEventTap
    let onClose: () -> Void
    private let theme = ColorTheme.defaultTheme
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with close button
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("KeyOgre")
                        .font(.headline)
                        .foregroundColor(theme.keyText)
                    
                    Text("Press ⌘` to toggle")
                        .font(.caption)
                        .foregroundColor(theme.keyText.opacity(0.7))
                }
                
                Spacer()
                
                Button(action: onClose) {
                    ZStack {
                        Circle()
                            .fill(theme.keyBackground.opacity(0.8))
                            .frame(width: 24, height: 24)
                        
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(theme.keyText)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .onHover { hovering in
                    if hovering {
                        NSCursor.pointingHand.push()
                    } else {
                        NSCursor.pop()
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 8)
            
            // Main content
            VStack(spacing: 20) {
                KeyboardView()
                    .environmentObject(keyEventTap)
                
                LastTenView()
                    .environmentObject(keyEventTap)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.windowBackground)
        )
        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
    }
}