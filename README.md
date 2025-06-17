# KeyOgre

A macOS keyboard overlay application that displays live key highlighting with a translucent dropdown interface.

## Features

- **Live Key Highlighting**: Real-time visualization of pressed keys on a virtual keyboard
- **Translucent Interface**: Semi-transparent overlay that doesn't obstruct your work  
- **Global Hotkey**: System-wide **Control + Option + K** shortcut to show/hide the overlay
- **ANSI 60% Layout**: Compact keyboard layout with arrow keys
- **Background Operation**: Runs silently in the background as a menu bar application

## Usage

1. Launch KeyOgre - the overlay will appear automatically
2. Press **Control + Option + K** from any application to toggle the overlay visibility
3. The overlay slides down from the top of your screen when shown
4. KeyOgre continues running in the background when hidden

## Requirements

- macOS 10.15+ (Catalina or later)
- Accessibility permissions (the system will prompt you when first launched)

## Troubleshooting

### Global Hotkey Not Working

If the **Control + Option + K** shortcut doesn't show/hide the overlay:

1. Open **Console.app** (Applications > Utilities > Console)
2. In the search bar, filter by "KeyOgre" 
3. Press the hotkey combination and look for these messages:
   - `[KeyOgre] Global hot-key registered successfully` - Registration worked
   - `[KeyOgre] Global hot-key registration FAILED: <error>` - Registration failed  
   - `[KeyOgre] Global hot-key triggered` - Hotkey was detected
4. If you see registration failures, try restarting KeyOgre
5. If no trigger messages appear, ensure KeyOgre has accessibility permissions in System Preferences > Security & Privacy > Privacy > Accessibility

### Accessibility Permissions

KeyOgre requires accessibility permissions to:
- Register global hotkeys
- Monitor keyboard input for live highlighting

If the overlay doesn't respond to keyboard input:
1. Go to **System Preferences > Security & Privacy > Privacy > Accessibility**
2. Ensure KeyOgre is listed and checked
3. If not listed, click the "+" button and add KeyOgre
4. Restart KeyOgre after granting permissions

## Development

Built with Swift 5.9 and SwiftUI, using:
- Carbon framework for global hotkey registration
- AppKit for window management and system integration
- Swift Testing for unit tests

### Building

```bash
# Build the project
xcodebuild -scheme KeyOgre build

# Run tests  
xcodebuild -scheme KeyOgre test
```

## License

[Add your license information here]