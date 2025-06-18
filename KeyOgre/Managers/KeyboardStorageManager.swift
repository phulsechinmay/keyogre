// ABOUTME: Manages local storage and persistence of keyboard configurations
// ABOUTME: Handles saving/loading configurations to/from UserDefaults and provides default keyboards

import Foundation

class KeyboardStorageManager: ObservableObject {
    private let userDefaults = UserDefaults.standard
    private let keyboardConfigsKey = "KeyOgreKeyboardConfigurations"
    private let selectedKeyboardIdKey = "KeyOgreSelectedKeyboardId"
    
    @Published var configurations: [KeyboardConfiguration] = []
    @Published var selectedConfigurationId: UUID?
    
    static let shared = KeyboardStorageManager()
    
    private init() {
        loadConfigurations()
    }
    
    // MARK: - Default Keyboards
    
    private func createDefaultKeyboards() -> [KeyboardConfiguration] {
        return [
            KeyboardConfiguration(
                name: "ANSI 60%",
                presetModel: .ansi60,
                isDefault: true,
                isDeletable: true
            ),
            createTyphonDefault()
        ]
    }
    
    private func createTyphonDefault() -> KeyboardConfiguration {
        // Load Typhon ZMK files from bundle or development paths
        let dtsiContent = loadTyphonDtsi()
        let keymapContent = loadTyphonKeymap()
        
        return KeyboardConfiguration(
            name: "Typhon",
            dtsiContent: dtsiContent,
            keymapContent: keymapContent,
            dtsiFileName: "typhon.dtsi",
            keymapFileName: "typhon.keymap",
            isDefault: true,
            isDeletable: true
        )
    }
    
    private func loadTyphonDtsi() -> String {
        // Try bundle resources first, fallback to development paths
        if let path = Bundle.main.path(forResource: "typhon", ofType: "dtsi") {
            return (try? String(contentsOfFile: path)) ?? ""
        }
        
        let devPath = "/Users/phulsechinmay/Desktop/Projects/keyogre/KeyOgre/ZmkFiles/typhon.dtsi"
        return (try? String(contentsOfFile: devPath)) ?? ""
    }
    
    private func loadTyphonKeymap() -> String {
        // Try bundle resources first, fallback to development paths
        if let path = Bundle.main.path(forResource: "typhon", ofType: "keymap") {
            return (try? String(contentsOfFile: path)) ?? ""
        }
        
        let devPath = "/Users/phulsechinmay/Desktop/Projects/keyogre/KeyOgre/ZmkFiles/typhon.keymap"
        return (try? String(contentsOfFile: devPath)) ?? ""
    }
    
    // MARK: - Persistence
    
    func loadConfigurations() {
        if let data = userDefaults.data(forKey: keyboardConfigsKey),
           let savedConfigs = try? JSONDecoder().decode([KeyboardConfiguration].self, from: data) {
            configurations = savedConfigs
            print("KeyOgre: Loaded \(configurations.count) saved keyboard configurations")
        } else {
            // First time setup - create default keyboards
            configurations = createDefaultKeyboards()
            saveConfigurations()
            print("KeyOgre: Created default keyboard configurations")
        }
        
        // Load selected keyboard
        if let selectedIdString = userDefaults.string(forKey: selectedKeyboardIdKey),
           let selectedId = UUID(uuidString: selectedIdString),
           configurations.contains(where: { $0.id == selectedId }) {
            selectedConfigurationId = selectedId
        } else if let firstConfig = configurations.first {
            selectedConfigurationId = firstConfig.id
        }
    }
    
    func saveConfigurations() {
        if let data = try? JSONEncoder().encode(configurations) {
            userDefaults.set(data, forKey: keyboardConfigsKey)
            print("KeyOgre: Saved \(configurations.count) keyboard configurations")
        }
    }
    
    func saveSelectedConfiguration(id: UUID) {
        selectedConfigurationId = id
        userDefaults.set(id.uuidString, forKey: selectedKeyboardIdKey)
    }
    
    // MARK: - Configuration Management
    
    func addConfiguration(_ config: KeyboardConfiguration) {
        configurations.append(config)
        saveConfigurations()
        print("KeyOgre: Added keyboard configuration: \(config.name)")
    }
    
    func removeConfiguration(_ config: KeyboardConfiguration) {
        guard config.isDeletable else {
            print("KeyOgre: Cannot delete non-deletable keyboard: \(config.name)")
            return
        }
        
        configurations.removeAll { $0.id == config.id }
        
        // If we deleted the selected keyboard, select the first available one
        if selectedConfigurationId == config.id {
            selectedConfigurationId = configurations.first?.id
            if let newSelectedId = selectedConfigurationId {
                saveSelectedConfiguration(id: newSelectedId)
            }
        }
        
        saveConfigurations()
        print("KeyOgre: Removed keyboard configuration: \(config.name)")
    }
    
    func updateConfiguration(_ config: KeyboardConfiguration) {
        if let index = configurations.firstIndex(where: { $0.id == config.id }) {
            configurations[index] = config
            saveConfigurations()
            print("KeyOgre: Updated keyboard configuration: \(config.name)")
        }
    }
    
    func getConfiguration(by id: UUID) -> KeyboardConfiguration? {
        return configurations.first { $0.id == id }
    }
    
    var selectedConfiguration: KeyboardConfiguration? {
        guard let selectedId = selectedConfigurationId else { return nil }
        return getConfiguration(by: selectedId)
    }
    
    // MARK: - Validation
    
    func isNameUnique(_ name: String, excluding configId: UUID? = nil) -> Bool {
        return !configurations.contains { config in
            config.name.lowercased() == name.lowercased() && config.id != configId
        }
    }
    
    // MARK: - Reset
    
    func resetToDefaults() {
        configurations = createDefaultKeyboards()
        selectedConfigurationId = configurations.first?.id
        saveConfigurations()
        if let selectedId = selectedConfigurationId {
            saveSelectedConfiguration(id: selectedId)
        }
        print("KeyOgre: Reset to default keyboard configurations")
    }
}