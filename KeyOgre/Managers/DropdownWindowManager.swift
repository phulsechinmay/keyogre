// ABOUTME: Manages the dropdown overlay window that slides from the top of the screen
// ABOUTME: Handles window positioning, animations, and lifecycle for the keyboard overlay

import AppKit
import SwiftUI

class DropdownWindowManager: ObservableObject {
    private var overlayWindow: NSWindow?
    @Published var isVisible = false

    private let windowWidth: CGFloat = 800
    private let windowHeight: CGFloat = 500

    // Create the overlay window in applicationDidFinishLaunching for fullscreen compatibility
    func createOverlayWindow(keyEventTap: KeyEventTap) {
        guard overlayWindow == nil else { return }

        print("KeyOgre: Creating overlay window in applicationDidFinishLaunching")

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
        let windowX = (screenFrame.width - windowWidth) / 2

        let initialFrame = NSRect(
            x: windowX,
            y: startY,
            width: windowWidth,
            height: windowHeight
        )

        // Create window with specific configuration for fullscreen overlay
        let window = NSWindow(
            contentRect: initialFrame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        window.contentViewController = hostingController

        // Critical configuration for fullscreen overlay
        window.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.maximumWindow)))
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = true
        window.animationBehavior = .none
        window.hidesOnDeactivate = false

        overlayWindow = window
        print("KeyOgre: ✅ Overlay window created successfully in applicationDidFinishLaunching")
    }

    func showDropdown(keyEventTap: KeyEventTap) {
        print("KeyOgre: showDropdown called")
        guard let window = overlayWindow else {
            print("KeyOgre: No overlay window available, creating one...")
            createOverlayWindow(keyEventTap: keyEventTap)
            guard let window = overlayWindow else { return }
            return showDropdown(keyEventTap: keyEventTap)
        }

        guard !isVisible else {
            print("KeyOgre: Window already visible, skipping show")
            return
        }

        // Get the main screen for positioning
        guard let screen = NSScreen.main else { return }
        let screenFrame = screen.frame

        // Position window at top center of screen, initially off-screen
        let startY = screenFrame.maxY
        let finalY = screenFrame.maxY - windowHeight - 20  // 20px from top
        let windowX = (screenFrame.width - windowWidth) / 2

        // Set initial position (off-screen)
        window.setFrame(
            NSRect(x: windowX, y: startY, width: windowWidth, height: windowHeight), display: false)

        // Show window and activate app to bring it into focus
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        isVisible = true
        print("KeyOgre: ✅ Window shown successfully")

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
        guard let window = overlayWindow, isVisible else {
            print("KeyOgre: No window to hide or already hidden")
            return
        }

        isVisible = false
        let currentFrame = window.frame
        let finalY = NSScreen.main?.frame.maxY ?? currentFrame.maxY

        print("KeyOgre: Starting hide animation from \(currentFrame.minY) to \(finalY)")

        // Animate slide up
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.3
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            window.animator().setFrame(
                NSRect(
                    x: currentFrame.minX, y: finalY, width: currentFrame.width,
                    height: currentFrame.height),
                display: true
            )
        }) { [weak self] in
            print("KeyOgre: Hide animation completed")
            // Hide window but keep it available for reuse (critical for fullscreen overlay)
            window.orderOut(nil)
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
    @StateObject private var keyboardLayoutManager = KeyboardLayoutManager.shared

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
                TypingDisplayView()
                    .environmentObject(keyEventTap)

                KeyboardView()
                    .environmentObject(keyEventTap)

                // Keyboard selection dropdown
                KeyboardSelectionView()
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

struct KeyboardSelectionView: View {
    @StateObject private var keyboardLayoutManager = KeyboardLayoutManager.shared
    private let theme = ColorTheme.defaultTheme

    var body: some View {
        HStack {
            Spacer()

            Picker(
                "Select Keyboard",
                selection: Binding(
                    get: { keyboardLayoutManager.selectedConfiguration?.id ?? UUID() },
                    set: { selectedId in
                        if let config = keyboardLayoutManager.availableConfigurations.first(where: {
                            $0.id == selectedId
                        }) {
                            keyboardLayoutManager.switchToConfiguration(config)
                        }
                    }
                )
            ) {
                ForEach(keyboardLayoutManager.availableConfigurations, id: \.id) { config in
                    HStack {
                        Image(systemName: "keyboard")
                            .font(.system(size: 12))
                        Text(config.name)
                            .font(.system(size: 13))
                    }
                    .tag(config.id)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .labelsHidden()
            .frame(maxWidth: 200)

            Spacer()
        }
    }
}
