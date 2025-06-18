// ABOUTME: Centralized manager for keyboard layouts using unified storage and provider system
// ABOUTME: Provides a shared instance and handles loading/switching between different keyboard configurations

import Foundation
import SwiftUI
import Combine

// Legacy protocol for backward compatibility
protocol KeyboardLayoutProtocol {
    var keys: [Key] { get }
    var totalSize: CGSize { get }
    func keyForKeyCode(_ keyCode: CGKeyCode) -> Key?
}

extension ANSI60KeyboardLayout: KeyboardLayoutProtocol {}
extension ZMKKeyboardLayout: KeyboardLayoutProtocol {}

class KeyboardLayoutManager: ObservableObject {
    static let shared = KeyboardLayoutManager()
    
    @Published var currentLayout: any KeyboardLayout
    @Published var availableConfigurations: [KeyboardConfiguration] = []
    @Published var selectedConfiguration: KeyboardConfiguration?
    
    private let storageManager = KeyboardStorageManager.shared
    private let provider = KeyboardProvider.shared
    private var cancellables = Set<AnyCancellable>()
    private var layoutCache: [UUID: any KeyboardLayout] = [:]
    
    private init() {
        // Initialize with a default ANSI layout as fallback
        let defaultLayout = ANSI60KeyboardLayout(withColors: true)
        self.currentLayout = defaultLayout
        
        // Set up reactive subscriptions
        setupStorageSubscriptions()
        
        // Load initial configuration
        loadInitialConfiguration()
    }
    
    private func setupStorageSubscriptions() {
        // Subscribe to storage manager updates
        storageManager.$configurations
            .receive(on: DispatchQueue.main)
            .sink { [weak self] configurations in
                self?.availableConfigurations = configurations
            }
            .store(in: &cancellables)
        
        storageManager.$selectedConfigurationId
            .receive(on: DispatchQueue.main)
            .sink { [weak self] selectedId in
                self?.handleConfigurationSelection(selectedId)
            }
            .store(in: &cancellables)
    }
    
    private func loadInitialConfiguration() {
        print("🔍 KeyboardLayoutManager: Loading initial configuration...")
        
        availableConfigurations = storageManager.configurations
        
        if let selectedConfig = storageManager.selectedConfiguration {
            loadConfiguration(selectedConfig)
        } else if let firstConfig = availableConfigurations.first {
            loadConfiguration(firstConfig)
        }
    }
    
    private func handleConfigurationSelection(_ selectedId: UUID?) {
        guard let selectedId = selectedId,
              let config = storageManager.getConfiguration(by: selectedId) else {
            return
        }
        
        loadConfiguration(config)
    }
    
    private func loadConfiguration(_ config: KeyboardConfiguration) {
        print("🔄 KeyboardLayoutManager: Loading configuration: \(config.name)")
        
        selectedConfiguration = config
        
        // Check cache first
        if let cachedLayout = layoutCache[config.id] {
            currentLayout = cachedLayout
            print("✅ KeyboardLayoutManager: Loaded \(config.name) from cache")
            return
        }
        
        // Create layout from configuration
        do {
            let layout = try provider.createKeyboardLayout(from: config)
            layoutCache[config.id] = layout
            currentLayout = layout
            print("✅ KeyboardLayoutManager: Successfully loaded \(config.name)")
        } catch {
            print("❌ KeyboardLayoutManager: Failed to load \(config.name): \(error)")
            // Keep current layout as fallback
        }
    }
    
    // MARK: - Public Interface
    
    func switchToConfiguration(_ config: KeyboardConfiguration) {
        storageManager.saveSelectedConfiguration(id: config.id)
        loadConfiguration(config)
    }
    
    func addConfiguration(_ config: KeyboardConfiguration) {
        storageManager.addConfiguration(config)
    }
    
    func removeConfiguration(_ config: KeyboardConfiguration) {
        storageManager.removeConfiguration(config)
        
        // Clear from cache
        layoutCache.removeValue(forKey: config.id)
        
        // If this was the selected configuration, switch to another one
        if selectedConfiguration?.id == config.id {
            if let newConfig = availableConfigurations.first {
                switchToConfiguration(newConfig)
            }
        }
    }
    
    func updateConfiguration(_ config: KeyboardConfiguration) {
        storageManager.updateConfiguration(config)
        
        // Clear cache to force reload
        layoutCache.removeValue(forKey: config.id)
        
        // Reload if this is the current configuration
        if selectedConfiguration?.id == config.id {
            loadConfiguration(config)
        }
    }
    
    // MARK: - Legacy Compatibility
    
    var availableLayouts: [String] {
        return availableConfigurations.map { $0.name }
    }
    
    var selectedLayoutName: String {
        return selectedConfiguration?.name ?? "Unknown"
    }
    
    func switchToLayout(named layoutName: String) {
        if let config = availableConfigurations.first(where: { $0.name == layoutName }) {
            switchToConfiguration(config)
        }
    }
    
    var currentLayoutInfo: String {
        guard let config = selectedConfiguration else {
            return "No keyboard selected"
        }
        
        let keyCount = currentLayout.keys.count
        switch config.type {
        case .preset:
            return "\(config.presetModel?.displayName ?? "Preset"): \(config.name) (\(keyCount) keys)"
        case .zmk:
            return "ZMK: \(config.name) (\(keyCount) keys)"
        }
    }
    
    // Clear cache when memory pressure occurs
    func clearCache() {
        layoutCache.removeAll()
        print("🧹 KeyboardLayoutManager: Cleared layout cache")
    }
}