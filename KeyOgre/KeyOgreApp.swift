// ABOUTME: Main app entry point for KeyOgre keyboard overlay application
// ABOUTME: Handles app lifecycle, global hotkey monitoring, and window management

import SwiftUI
import Combine
import AppKit

@main
struct KeyOgreApp: App {
    @StateObject private var keyEventTap = KeyEventTap()
    
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


struct ContentView: View {
    @EnvironmentObject var keyEventTap: KeyEventTap
    
    var body: some View {
        VStack(spacing: 20) {
            KeyboardView()
                .environmentObject(keyEventTap)
            
            LastTenView()
                .environmentObject(keyEventTap)
        }
        .padding()
        .frame(width: 800, height: 500) // Increased height for text field
        .onAppear {
            keyEventTap.startMonitoring()
        }
        .onDisappear {
            keyEventTap.stopMonitoring()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(KeyEventTap())
    }
}
