# KeyOgre Development Log

## Milestone 1 - Live-Key Overlay Implementation

### 2025-06-15 - Project Setup
- Created basic Xcode project structure for KeyOgre
- Implemented core components:
  - `KeyOgreApp.swift` - Main app entry point with global hotkey (⌃⌥K)
  - `KeyEventTap.swift` - CGEventTap wrapper with Combine publishers
  - `KeyboardLayout.swift` - ANSI 60% keyboard model with proper positioning
  - `KeyboardView.swift` - SwiftUI renderer with pastel theme and animations
  - `LastTenView.swift` - Rolling character buffer display
  - `ColorTheme.swift` - Muted pastel color definitions matching reference video

### Technical Implementation Notes
- Used protocol-based design for KeyEventTap to enable testing with mock objects
- Implemented 1.05x scale + glow effect for key highlighting (~150ms duration)
- ANSI 60% layout with 61 keys properly positioned and sized
- Character buffer maintains last 10 keystrokes with smooth animations
- Accessibility permission handling with user-friendly prompts

### Testing Strategy
- Created unit tests for KeyEventTap with synthetic key injection
- KeyboardLayout tests verify positioning, legends, and structure
- Mock implementation allows testing without actual event monitoring
- Coverage includes buffer management, key lookup, and layout validation

### Next Steps for M1
1. Fix any compilation issues in Xcode
2. Test accessibility permissions flow
3. Verify visual appearance matches reference video
4. Add snapshot tests for key highlighting
5. Ensure global hotkey toggle works properly

### 2025-06-15 20:42 - Enhanced Testing & Visual Improvements
- **Enhanced Key Structure**: Updated Key struct to support dual labels (base + shift symbols) and individual key colors
- **ANSI60KeyboardLayout**: Created dedicated layout class matching reference screenshot:
  - Column-based color scheme with muted pastels (green, yellow, orange, gray, pink)
  - Dual-label keys showing shift symbols on top, base symbols on bottom
  - Proper key positioning with tighter spacing (2px vs 4px) and smaller corner radius (2px)
- **Comprehensive Unit Tests**: Added full test suite with 3 test files:
  - `ANSI60KeyboardLayoutTests.swift` - Layout structure, key distribution, color validation
  - `KeyEventTapTests.swift` - Publisher behavior, monitoring lifecycle, protocol conformance
  - `KeyStructTests.swift` - Key initialization, dual labels, equality, frame properties
- **Visual Polish**: Updated keyboard rendering to match screenshot with smaller corner radius and tighter key grouping
- **Swift 6 Compatibility**: Fixed protocol references and type checking for modern Swift

### 2025-06-18 - ZMK Keyboard Layout Loading Implementation
- **ZMK Firmware Support**: Implemented comprehensive ZMK keyboard layout loading system
  - Created complete ZMK parsing infrastructure in `KeyOgre/ZMK/` directory
  - `ZMKDtsiParser.swift` - Parses `.dtsi` files for physical keyboard layouts with `key_physical_attrs`
  - `ZMKKeymapParser.swift` - Parses `.keymap` files for key bindings and layer definitions
  - `KeyCodeMapper.swift` - Maps ZMK key codes (`&kp GRAVE`, `&mo 1`, etc.) to display names
  - `ZMKCommentRemover.swift` - Strips `//` line comments and `/* */` block comments from files

- **Data Models**: Created comprehensive ZMK data structures
  - `ZMKPhysicalLayout.swift` - Keyboard geometry with centi-keyunit positioning
  - `ZMKKeymap.swift` - Multiple layer support with default layer detection
  - `ZMKKey.swift` - Individual key with physical attributes and key bindings
  - `ZMKKeyboardLayout.swift` - Integration adapter conforming to existing KeyOgre protocols

- **Layout Management**: Enhanced keyboard system with multiple layout support
  - `KeyboardLayoutManager.swift` - Centralized singleton managing ANSI 60% and ZMK layouts
  - Smart file path resolution: bundle resources → development paths → fallback
  - Real-time layout switching in Settings > Keyboards tab
  - Typhon ZMK keyboard (60-key split layout) loads as default on startup

- **Sandboxing & Permissions**: Fixed macOS app sandbox file access issues
  - Added file access entitlements: `com.apple.security.files.user-selected.read-only`
  - Added temporary exception: `com.apple.security.temporary-exception.files.absolute-path.read-only`
  - Resolved "Operation not permitted" errors for ZMK file reading

- **Testing Infrastructure**: Created comprehensive test suite
  - `ZMKParserTests.swift` - Unit tests for file parsing and key code mapping
  - `ZMKIntegrationTests.swift` - End-to-end tests covering startup, layout creation, and performance
  - Comment removal validation and ZMK file format compliance testing

- **Settings Integration**: Enhanced Settings > Keyboards tab
  - Live keyboard preview with first 12 keys displayed
  - Current keyboard status with key count and layout type
  - Layout switching between "ANSI 60%" and "Typhon (ZMK)"
  - ZMK debug information display for technical validation

### Technical Implementation Details
- **ZMK Documentation Integration**: Built parser based on official ZMK specs
  - Physical layouts: https://zmk.dev/docs/development/hardware-integration/physical-layouts
  - Keymaps: https://zmk.dev/docs/keymaps
  - Key codes: https://zmk.dev/docs/codes
  - Behaviors: https://zmk.dev/docs/behaviors

- **Comment Handling**: Robust preprocessing system handles devicetree comment syntax
  - Line comments: `// comment` (everything after // to end of line)
  - Block comments: `/* comment */` (including multi-line blocks)
  - Preserves file structure while enabling accurate regex parsing

- **Coordinate System**: Converts ZMK centi-keyunits to KeyOgre display coordinates
  - Scale factor 0.4 converts 100 centi-keyunits → 40 points
  - Handles split keyboard layouts with proper left/right positioning
  - Maintains aspect ratios and key spacing from original ZMK definitions

### Current Status
- ✅ Typhon ZMK keyboard loads successfully as default layout
- ✅ 60 keys display with proper split keyboard positioning  
- ✅ Comment removal and file parsing working correctly
- ⚠️ Key character mapping needs refinement (some labels incorrect)
- ✅ Settings integration and layout switching functional
- ✅ Comprehensive test coverage for all ZMK components

### Future Milestones Planning
- M2: Typing practice with accuracy tracking and WPM calculation
- M3: UX polish with slide animations and theme selection
- M4: ~~Custom ZMK layout parsing and storage~~ **COMPLETED**
- M5: Distribution with hardened runtime and notarization