# ZMK Keyboard Layout Loading Feature

## Overview
Implement ZMK (ZMK Firmware) keyboard layout loading to support custom split/ergonomic keyboards like the Typhon. This will parse `.dtsi` physical layout files and `.keymap` files to render accurate keyboard visualizations.

## Reference Documentation (Use During Implementation)
**ZMK Core Documentation:**
- Physical Layouts: https://zmk.dev/docs/development/hardware-integration/physical-layouts
- Keymaps: https://zmk.dev/docs/keymaps  
- Key Codes: https://zmk.dev/docs/codes
- Behaviors: https://zmk.dev/docs/behaviors

**ZMK Key Code References:**
- Basic Key Codes: https://zmk.dev/docs/codes/keyboard-keypad
- Modifier Keys: https://zmk.dev/docs/codes/modifiers
- Media Keys: https://zmk.dev/docs/codes/media
- Bluetooth/System: https://zmk.dev/docs/codes/power

**ZMK Behavior References:**
- Key Press (&kp): https://zmk.dev/docs/behaviors/key-press
- Momentary Layer (&mo): https://zmk.dev/docs/behaviors/layers
- Mod-Tap (&mt): https://zmk.dev/docs/behaviors/mod-tap
- Bluetooth (&bt): https://zmk.dev/docs/behaviors/bluetooth

**Device Tree Syntax:**
- Linux Device Tree: https://www.devicetree.org/specifications/
- ZMK Device Tree Usage: https://zmk.dev/docs/development/hardware-integration

## Phase 1: Data Models & Parser Infrastructure
1. **ZMK Data Models** - Create Swift structs for:
   - `ZMKPhysicalLayout` (keyboard geometry)
   - `ZMKKeymap` (layer definitions and bindings) 
   - `ZMKKey` (physical position + binding)
   - `ZMKLayer` (collection of key bindings)

2. **ZMK File Parsers**:
   - `ZMKDtsiParser` - Parse `.dtsi` files for physical layouts
   - `ZMKKeymapParser` - Parse `.keymap` files for key bindings
   - Handle devicetree syntax and extract key attributes

3. **Key Code Mapping System**:
   - Map ZMK key codes (`&kp GRAVE`, `&kp N1`, etc.) to display names
   - Support common codes: alphanumeric, modifiers, function keys
   - Handle special ZMK behaviors (`&mo`, `&bt`, `&trans`)
   - **Reference ZMK docs above for complete key code mappings**

## Phase 2: Layout Integration
4. **Extend KeyboardLayout Protocol**:
   - Add `ZMKKeyboardLayout` conforming to existing `KeyboardLayout`
   - Convert ZMK coordinates to KeyOgre's coordinate system
   - Support split keyboard layouts with proper spacing

5. **Update KeyboardView**:
   - Render ZMK layouts using existing Canvas infrastructure
   - Handle variable key positions and sizes
   - Support 60-key layouts (current Typhon has 60 keys)

## Phase 3: Settings & Storage
6. **Settings Integration**:
   - Add ZMK keyboard selection to Settings > Keyboards tab
   - Show "Typhon" as initial loaded keyboard
   - Display keyboard preview in settings

7. **Local Storage System**:
   - Save parsed ZMK layouts to app documents directory
   - Cache parsed layouts for performance
   - Support multiple ZMK keyboards

## Phase 4: Testing & Polish
8. **Testing**:
   - Unit tests for ZMK parsers
   - Integration tests for layout rendering
   - Test with Typhon keyboard files

9. **Error Handling**:
   - Graceful handling of malformed ZMK files
   - Fallback to default keyboard on parsing errors
   - User feedback for loading issues

## Implementation Details

**File Structure:**
```
KeyOgre/ZMK/
├── Models/
│   ├── ZMKPhysicalLayout.swift
│   ├── ZMKKeymap.swift
│   └── ZMKKey.swift
├── Parsers/
│   ├── ZMKDtsiParser.swift
│   └── ZMKKeymapParser.swift
├── Layouts/
│   └── ZMKKeyboardLayout.swift
└── KeyCodeMapper.swift
```

**Key Technical Challenges:**
- Parsing devicetree syntax (regex-based approach)
- Coordinate system conversion (ZMK uses centi-keyunits)
- Split keyboard layout rendering
- ZMK key code to display name mapping

**Key Parsing Strategy:**
1. Extract `key_physical_attrs` from dtsi: `<&key_physical_attrs w h x y rotation rx ry>`
2. Extract `bindings` from keymap: `&kp GRAVE &kp N1 &kp N2...`
3. Map ZMK key codes to display strings using documentation above
4. Handle special cases: `&trans`, `&mo 1`, `&bt BT_SEL 0`

**ZMK File Format Examples:**

**Physical Layout (dtsi):**
```devicetree
typhon_layout: typhon_layout_0 {
    compatible = "zmk,physical-layout";
    display-name = "Typhon";
    keys = 
    <&key_physical_attrs 100 100   0  50 0 0 0>, // Width Height X Y Rotation RX RY
    <&key_physical_attrs 100 100 100  50 0 0 0>,
    // ... more keys
    ;
};
```

**Keymap (keymap):**
```devicetree
default_layer {
    bindings = <
    &kp GRAVE  &kp N1    &kp N2    // Row 1
    &kp TAB    &kp Q     &kp W     // Row 2  
    // ... more bindings
    >;
};
```

**Success Criteria:**
- Typhon keyboard loads and displays correctly in settings
- Physical key positions match actual keyboard layout
- Layer 0 key labels show correct characters (QWERTY layout)
- Integration with existing keyboard highlighting system

## Current Status
- Typhon ZMK files available in `KeyOgre/ZmkFiles/`
- Need to implement parsing and integration with existing KeyOgre architecture