// ABOUTME: Modal view for adding new keyboard configurations to the app
// ABOUTME: Supports both preset keyboards and custom ZMK keyboards with file selection

import SwiftUI
import AppKit

struct AddKeyboardView: View {
    @Binding var isPresented: Bool
    @StateObject private var layoutManager = KeyboardLayoutManager.shared
    @StateObject private var storageManager = KeyboardStorageManager.shared
    
    @State private var keyboardName: String = ""
    @State private var selectedType: KeyboardType = .preset
    @State private var selectedPresetModel: PresetKeyboardModel = .ansi60
    
    // ZMK file handling
    @State private var dtsiContent: String = ""
    @State private var keymapContent: String = ""
    @State private var dtsiFileName: String = ""
    @State private var keymapFileName: String = ""
    
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var isCreating = false
    
    private let theme = ColorTheme.defaultTheme
    
    var body: some View {
        ZStack {
            // Background
            Color(red: 0.165, green: 0.165, blue: 0.157)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                HStack {
                    Text("Add Keyboard")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                            .frame(width: 30, height: 30)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.1))
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
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
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Keyboard Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Keyboard Name")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            TextField("Enter keyboard name", text: $keyboardName)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        // Keyboard Type
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Keyboard Type")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Picker("Keyboard Type", selection: $selectedType) {
                                ForEach(KeyboardType.allCases, id: \.self) { type in
                                    Text(type.displayName).tag(type)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(8)
                        }
                        
                        // Preset Model Selection (only for preset keyboards)
                        if selectedType == .preset {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Preset Model")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Picker("Preset Model", selection: $selectedPresetModel) {
                                    ForEach(PresetKeyboardModel.allCases, id: \.self) { model in
                                        Text(model.displayName).tag(model)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.white.opacity(0.05))
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                            }
                        }
                        
                        // ZMK File Selection (only for custom keyboards)
                        if selectedType == .zmk {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("ZMK Configuration Files")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                // DTSI File
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Physical Layout (.dtsi)")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.8))
                                    
                                    HStack {
                                        Text(dtsiFileName.isEmpty ? "No file selected" : dtsiFileName)
                                            .foregroundColor(dtsiFileName.isEmpty ? .white.opacity(0.6) : .white)
                                            .truncationMode(.middle)
                                        
                                        Spacer()
                                        
                                        Button("Choose File") {
                                            selectDtsiFile()
                                        }
                                        .buttonStyle(SecondaryButtonStyle())
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.white.opacity(0.05))
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                                }
                                
                                // Keymap File
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Keymap Configuration (.keymap)")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.8))
                                    
                                    HStack {
                                        Text(keymapFileName.isEmpty ? "No file selected" : keymapFileName)
                                            .foregroundColor(keymapFileName.isEmpty ? .white.opacity(0.6) : .white)
                                            .truncationMode(.middle)
                                        
                                        Spacer()
                                        
                                        Button("Choose File") {
                                            selectKeymapFile()
                                        }
                                        .buttonStyle(SecondaryButtonStyle())
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.white.opacity(0.05))
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                                }
                                
                                // File validation status
                                if selectedType == .zmk && (!dtsiContent.isEmpty || !keymapContent.isEmpty) {
                                    HStack {
                                        Image(systemName: isValidZMKConfiguration ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                                            .foregroundColor(isValidZMKConfiguration ? .green : .orange)
                                        
                                        Text(isValidZMKConfiguration ? "Valid ZMK configuration" : "Invalid or incomplete ZMK files")
                                            .font(.caption)
                                            .foregroundColor(isValidZMKConfiguration ? .green : .orange)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }
                
                // Action Buttons
                HStack(spacing: 12) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    
                    Button(action: createKeyboard) {
                        if isCreating {
                            HStack {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .progressViewStyle(CircularProgressViewStyle())
                                Text("Creating...")
                            }
                        } else {
                            Text("Add Keyboard")
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(!canCreateKeyboard || isCreating)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
        }
        .frame(width: 480, height: 600)
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    // MARK: - Computed Properties
    
    private var canCreateKeyboard: Bool {
        guard !keyboardName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return false
        }
        
        guard storageManager.isNameUnique(keyboardName) else {
            return false
        }
        
        switch selectedType {
        case .preset:
            return true
        case .zmk:
            return isValidZMKConfiguration
        }
    }
    
    private var isValidZMKConfiguration: Bool {
        return !dtsiContent.isEmpty && !keymapContent.isEmpty &&
               KeyboardProvider.shared.validateZMKFiles(dtsiContent: dtsiContent, keymapContent: keymapContent)
    }
    
    // MARK: - Actions
    
    private func selectDtsiFile() {
        selectFile(title: "Select DTSI File", allowedTypes: ["dtsi", "public.text"]) { url in
            loadFile(from: url) { content in
                dtsiContent = content
                dtsiFileName = url.lastPathComponent
            }
        }
    }
    
    private func selectKeymapFile() {
        selectFile(title: "Select Keymap File", allowedTypes: ["keymap", "public.text"]) { url in
            loadFile(from: url) { content in
                keymapContent = content
                keymapFileName = url.lastPathComponent
            }
        }
    }
    
    private func selectFile(title: String, allowedTypes: [String], completion: @escaping (URL) -> Void) {
        let panel = NSOpenPanel()
        panel.title = title
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.allowedContentTypes = allowedTypes.compactMap { UTType(filenameExtension: $0) }
        
        if panel.runModal() == .OK, let url = panel.url {
            completion(url)
        }
    }
    
    private func loadFile(from url: URL, completion: @escaping (String) -> Void) {
        do {
            let content = try String(contentsOf: url, encoding: .utf8)
            completion(content)
        } catch {
            showError("Failed to load file: \(error.localizedDescription)")
        }
    }
    
    private func createKeyboard() {
        guard canCreateKeyboard else { return }
        
        isCreating = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let config: KeyboardConfiguration
                
                switch selectedType {
                case .preset:
                    config = KeyboardConfiguration(
                        name: keyboardName.trimmingCharacters(in: .whitespacesAndNewlines),
                        presetModel: selectedPresetModel
                    )
                case .zmk:
                    config = KeyboardConfiguration(
                        name: keyboardName.trimmingCharacters(in: .whitespacesAndNewlines),
                        dtsiContent: dtsiContent,
                        keymapContent: keymapContent,
                        dtsiFileName: dtsiFileName,
                        keymapFileName: keymapFileName
                    )
                }
                
                DispatchQueue.main.async {
                    layoutManager.addConfiguration(config)
                    isCreating = false
                    isPresented = false
                }
                
            } catch {
                DispatchQueue.main.async {
                    isCreating = false
                    showError("Failed to create keyboard: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func showError(_ message: String) {
        errorMessage = message
        showingError = true
    }
}

// MARK: - Custom Styles

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.05))
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .foregroundColor(.white)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.accentColor.opacity(configuration.isPressed ? 0.8 : 1.0))
            )
            .foregroundColor(.white)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.white.opacity(configuration.isPressed ? 0.15 : 0.1))
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .foregroundColor(.white)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

import UniformTypeIdentifiers