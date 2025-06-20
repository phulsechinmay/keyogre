// ABOUTME: Protocol for practice control bar options like programming languages and text types
// ABOUTME: Defines common interface for selectable options in practice control dropdowns

import Foundation

protocol PracticeControlOption {
    var displayName: String { get }
    var icon: String { get }
}