// ABOUTME: Dedicated view for displaying keyboard layout preview in separate window
// ABOUTME: Shows full keyboard visualization with layout details and debug information

import SwiftUI

struct KeyboardPreviewView: View {
    let layoutName: String
    @StateObject private var layoutManager = KeyboardLayoutManager.shared
    
    private let theme = ColorTheme.defaultTheme
    
    var body: some View {
        ZStack {
            // Background
            Color(red: 0.165, green: 0.165, blue: 0.157)
                .ignoresSafeArea()
            
            ScrollView([.horizontal, .vertical], showsIndicators: true) {
                VStack(alignment: .leading, spacing: 20) {
                    // Header section
                    VStack(alignment: .leading, spacing: 8) {
                        Text(layoutName)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text(layoutManager.currentLayoutInfo)
                            .font(.headline)
                            .foregroundColor(.green.opacity(0.8))
                    }
                    .padding(.horizontal, 20)
                    
                    // Full keyboard visualization
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Keyboard Layout")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                        
                        // Use the actual KeyboardView component
                        KeyboardView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.black.opacity(0.2))
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                        .padding(.horizontal, 20)
                    }
                    
                    // Debug information for ZMK layouts
                    if let zmkLayout = layoutManager.currentLayout as? ZMKKeyboardLayout {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Layout Information")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            Text(zmkLayout.debugInfo())
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(Color.white.opacity(0.8))
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.black.opacity(0.3))
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                )
                            
                            Text(zmkLayout.getLayerInfo())
                                .font(.body)
                                .foregroundColor(Color.blue.opacity(0.8))
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.blue.opacity(0.1))
                                        .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                                )
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Key details table
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Key Details")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        LazyVGrid(columns: [
                            GridItem(.fixed(60), alignment: .leading),
                            GridItem(.flexible(), alignment: .leading),
                            GridItem(.fixed(80), alignment: .leading),
                            GridItem(.fixed(100), alignment: .leading)
                        ], spacing: 8) {
                            // Header row
                            Group {
                                Text("Index")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white.opacity(0.6))
                                Text("Legend")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white.opacity(0.6))
                                Text("KeyCode")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white.opacity(0.6))
                                Text("Position")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            
                            // Key rows
                            ForEach(Array(layoutManager.currentLayout.keys.enumerated()), id: \.element.id) { index, key in
                                Group {
                                    Text("\(index)")
                                        .font(.system(.caption, design: .monospaced))
                                        .foregroundColor(.white.opacity(0.8))
                                    
                                    Text(key.baseLegend)
                                        .font(.system(.caption, design: .monospaced))
                                        .foregroundColor(.white)
                                    
                                    Text("\(Int(key.keyCode))")
                                        .font(.system(.caption, design: .monospaced))
                                        .foregroundColor(.green.opacity(0.8))
                                    
                                    Text("(\(Int(key.frame.origin.x)), \(Int(key.frame.origin.y)))")
                                        .font(.system(.caption, design: .monospaced))
                                        .foregroundColor(.blue.opacity(0.8))
                                }
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.05))
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .frame(minWidth: 600, minHeight: 400)
    }
}