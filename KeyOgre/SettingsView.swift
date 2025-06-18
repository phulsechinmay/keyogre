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
        VStack(spacing: 0) {
            // Horizontal Tab Bar
            HStack(spacing: 8) {
                ForEach(SettingsTab.allCases, id: \.self) { tab in
                    TabButton(
                        tab: tab,
                        isSelected: selectedTab == tab,
                        action: { selectedTab = tab }
                    )
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)
            .background(Color(NSColor.windowBackgroundColor))
            
            // Content Area
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    switch selectedTab {
                    case .general:
                        GeneralSettingsContent()
                    case .keyboards:
                        KeyboardsSettingsContent()
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(Color(NSColor.controlBackgroundColor))
        }
        .frame(width: 600, height: 400)
    }
}

struct TabButton: View {
    let tab: SettingsTab
    let isSelected: Bool
    let action: () -> Void
    
    private let theme = ColorTheme.defaultTheme
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: tab.icon)
                    .font(.system(size: 14, weight: .medium))
                    .frame(width: 16, height: 16)
                
                Text(tab.rawValue)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(isSelected ? .white : Color(NSColor.labelColor))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.accentColor : Color.clear)
            )
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

struct GeneralSettingsContent: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("General")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(Color(NSColor.labelColor))
            
            VStack(alignment: .leading, spacing: 16) {
                HotkeyInputView()
                
                // Additional general settings can be added here
                Divider()
                
                HStack {
                    Text("More settings coming soon...")
                        .font(.body)
                        .foregroundColor(Color(NSColor.secondaryLabelColor))
                    Spacer()
                }
            }
        }
    }
}

struct KeyboardsSettingsContent: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Keyboards")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(Color(NSColor.labelColor))
            
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "keyboard")
                        .font(.system(size: 24))
                        .foregroundColor(Color(NSColor.secondaryLabelColor))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Custom Keyboard Layouts")
                            .font(.headline)
                            .foregroundColor(Color(NSColor.labelColor))
                        
                        Text("Support for custom keyboard layouts will be added in a future update.")
                            .font(.body)
                            .foregroundColor(Color(NSColor.secondaryLabelColor))
                    }
                    
                    Spacer()
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(NSColor.controlBackgroundColor))
                        .stroke(Color(NSColor.separatorColor), lineWidth: 1)
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