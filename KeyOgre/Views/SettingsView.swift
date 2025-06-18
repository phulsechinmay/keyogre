// ABOUTME: Main settings view with horizontal tab bar navigation
// ABOUTME: Provides tabbed interface for General and Keyboards settings sections

import SwiftUI

enum SettingsTab: String, CaseIterable {
    case general = "General"
    case keyboards = "Keyboards"

    var icon: String {
        switch self {
        case .general:
            return "gearshape"
        case .keyboards:
            return "keyboard"
        }
    }
}

struct SettingsView: View {
    @State private var selectedTab: SettingsTab = .general

    private let theme = ColorTheme.defaultTheme

    var body: some View {
        ZStack(alignment: .top) {
            // Background
            Color(red: 0.165, green: 0.165, blue: 0.157)
                .ignoresSafeArea()
            
            // Content Area with top padding for tabbar overlay
            VStack(spacing: 0) {
                // Spacer to push content down where tabbar will overlay
                Spacer()
                    .frame(height: 30) // Half the tabbar height (60/2 = 30)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        switch selectedTab {
                        case .general:
                            GeneralSettingsContent()
                        case .keyboards:
                            KeyboardsSettingsContent()
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 30) // Additional padding for the bottom half of tabbar
                    .padding(.bottom, 24)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            // Tab Bar (overlayed on top)
            HStack {
                Spacer()

                HStack(spacing: 0) {
                    ForEach(SettingsTab.allCases, id: \.self) { tab in
                        TabButton(
                            tab: tab,
                            isSelected: selectedTab == tab,
                            action: { selectedTab = tab }
                        )
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(red: 0.274, green: 0.274, blue: 0.274))
                        .background(.ultraThinMaterial)
                )

                Spacer()
            }
            .padding(.top, 20)
        }
        .frame(width: 600, height: 400)
    }
}

struct TabButton: View {
    let tab: SettingsTab
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: tab.icon)
                    .font(.system(size: 16, weight: .medium))
                    .frame(width: 20, height: 20)

                Text(tab.rawValue)
                    .font(.system(size: 12, weight: .medium))
            }
            .foregroundColor(
                isSelected ? Color.accentColor : Color.white.opacity(0.6)
            )
            .frame(width: 80, height: 60)  // Fixed size for uniform buttons
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        isSelected
                            ? Color.accentColor.opacity(0.2) : Color.clear
                    )
                    .stroke(
                        isSelected ? Color.accentColor : Color.clear,
                        lineWidth: 1
                    )
            )
            .contentShape(Rectangle())  // Make entire button area clickable
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
}

struct InnerSettingsView<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            content
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .padding(.top, 60) // Extra top padding for tabbar overlay spacing
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 0.19, green: 0.19, blue: 0.18))
        )
    }
}

struct GeneralSettingsContent: View {
    var body: some View {
        InnerSettingsView {
            VStack(alignment: .leading, spacing: 16) {
                HotkeyInputView()

                // Additional general settings can be added here
                Divider()
                    .background(Color.white.opacity(0.2))

                HStack {
                    Text("More settings coming soon...")
                        .font(.body)
                        .foregroundColor(Color.white.opacity(0.6))
                    Spacer()
                }
            }
        }
    }
}

struct KeyboardsSettingsContent: View {
    @StateObject private var layoutManager = KeyboardLayoutManager.shared
    
    var body: some View {
        InnerSettingsView {
            VStack(alignment: .leading, spacing: 16) {
                // Current Keyboard Section
                HStack {
                    Image(systemName: "keyboard")
                        .font(.system(size: 24))
                        .foregroundColor(Color.white.opacity(0.6))

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Current Keyboard")
                            .font(.headline)
                            .foregroundColor(.white)

                        Text(layoutManager.currentLayoutInfo)
                            .font(.body)
                            .foregroundColor(.green.opacity(0.8))
                    }

                    Spacer()
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.05))
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
                
                // Layout Selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Available Keyboards")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    ForEach(layoutManager.availableLayouts, id: \.self) { layoutName in
                        Button(action: {
                            layoutManager.switchToLayout(named: layoutName)
                        }) {
                            HStack {
                                Image(systemName: layoutManager.selectedLayoutName == layoutName ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(layoutManager.selectedLayoutName == layoutName ? .green : .white.opacity(0.6))
                                
                                Text(layoutName)
                                    .foregroundColor(.white)
                                
                                Spacer()
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(layoutManager.selectedLayoutName == layoutName ? Color.green.opacity(0.1) : Color.white.opacity(0.05))
                                    .stroke(layoutManager.selectedLayoutName == layoutName ? Color.green.opacity(0.3) : Color.white.opacity(0.1), lineWidth: 1)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.05))
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
                
                // Keyboard Preview
                VStack(alignment: .leading, spacing: 8) {
                    Text("Keyboard Preview")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    // Show first few keys as a test
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 4) {
                            ForEach(layoutManager.currentLayout.keys.prefix(12), id: \.id) { key in
                                VStack(spacing: 2) {
                                    Text(key.baseLegend)
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundColor(.white)
                                    Text("\(Int(key.keyCode))")
                                        .font(.system(size: 8))
                                        .foregroundColor(.white.opacity(0.6))
                                }
                                .frame(width: 32, height: 32)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.white.opacity(0.1))
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                            }
                        }
                        .padding(.horizontal, 8)
                    }
                    
                    if let zmkLayout = layoutManager.currentLayout as? ZMKKeyboardLayout {
                        Text(zmkLayout.debugInfo())
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(Color.white.opacity(0.8))
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.black.opacity(0.3))
                            )
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.05))
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
