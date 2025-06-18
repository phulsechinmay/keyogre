// ABOUTME: Data model for storing keyboard configuration with persistence support
// ABOUTME: Supports both preset keyboards and custom ZMK keyboards with local storage

import Foundation

enum KeyboardType: String, Codable, CaseIterable {
    case preset = "preset"
    case zmk = "zmk"
    
    var displayName: String {
        switch self {
        case .preset:
            return "Preset Keyboard"
        case .zmk:
            return "Custom ZMK Keyboard"
        }
    }
}

enum PresetKeyboardModel: String, Codable, CaseIterable {
    case ansi60 = "ansi60"
    case ansi87 = "ansi87"
    case ansi104 = "ansi104"
    
    var displayName: String {
        switch self {
        case .ansi60:
            return "ANSI 60%"
        case .ansi87:
            return "ANSI 87 (TKL)"
        case .ansi104:
            return "ANSI 104 (Full Size)"
        }
    }
}

struct KeyboardConfiguration: Codable, Identifiable, Equatable {
    let id: UUID
    let name: String
    let type: KeyboardType
    let isDefault: Bool
    let isDeletable: Bool
    
    // For preset keyboards
    let presetModel: PresetKeyboardModel?
    
    // For ZMK keyboards
    let dtsiContent: String?
    let keymapContent: String?
    let dtsiFileName: String?
    let keymapFileName: String?
    
    let dateCreated: Date
    let dateModified: Date
    
    // Preset keyboard initializer
    init(name: String, presetModel: PresetKeyboardModel, isDefault: Bool = false, isDeletable: Bool = true) {
        self.id = UUID()
        self.name = name
        self.type = .preset
        self.isDefault = isDefault
        self.isDeletable = isDeletable
        self.presetModel = presetModel
        self.dtsiContent = nil
        self.keymapContent = nil
        self.dtsiFileName = nil
        self.keymapFileName = nil
        self.dateCreated = Date()
        self.dateModified = Date()
    }
    
    // ZMK keyboard initializer
    init(name: String, dtsiContent: String, keymapContent: String, dtsiFileName: String, keymapFileName: String, isDefault: Bool = false, isDeletable: Bool = true) {
        self.id = UUID()
        self.name = name
        self.type = .zmk
        self.isDefault = isDefault
        self.isDeletable = isDeletable
        self.presetModel = nil
        self.dtsiContent = dtsiContent
        self.keymapContent = keymapContent
        self.dtsiFileName = dtsiFileName
        self.keymapFileName = keymapFileName
        self.dateCreated = Date()
        self.dateModified = Date()
    }
    
    static func == (lhs: KeyboardConfiguration, rhs: KeyboardConfiguration) -> Bool {
        return lhs.id == rhs.id
    }
    
    func updated(name: String? = nil, dtsiContent: String? = nil, keymapContent: String? = nil) -> KeyboardConfiguration {
        var updated = self
        if let name = name {
            updated = KeyboardConfiguration(
                id: self.id,
                name: name,
                type: self.type,
                isDefault: self.isDefault,
                isDeletable: self.isDeletable,
                presetModel: self.presetModel,
                dtsiContent: dtsiContent ?? self.dtsiContent,
                keymapContent: keymapContent ?? self.keymapContent,
                dtsiFileName: self.dtsiFileName,
                keymapFileName: self.keymapFileName,
                dateCreated: self.dateCreated,
                dateModified: Date()
            )
        }
        return updated
    }
    
    private init(id: UUID, name: String, type: KeyboardType, isDefault: Bool, isDeletable: Bool, presetModel: PresetKeyboardModel?, dtsiContent: String?, keymapContent: String?, dtsiFileName: String?, keymapFileName: String?, dateCreated: Date, dateModified: Date) {
        self.id = id
        self.name = name
        self.type = type
        self.isDefault = isDefault
        self.isDeletable = isDeletable
        self.presetModel = presetModel
        self.dtsiContent = dtsiContent
        self.keymapContent = keymapContent
        self.dtsiFileName = dtsiFileName
        self.keymapFileName = keymapFileName
        self.dateCreated = dateCreated
        self.dateModified = dateModified
    }
}