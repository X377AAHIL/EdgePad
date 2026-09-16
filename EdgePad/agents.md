# Agents

This document tracks the AI agents and their responsibilities in the EdgePad project.

## Primary Agent: opencode (nemotron-3-ultra-free)

**Role**: Lead developer for EdgePad - Building Trackpad Edge Gestures on macOS 27

**Responsibilities**:
- Implement all four milestones from the build guide
- Maintain code quality and Swift 6 concurrency compliance
- Create and update project documentation
- Verify builds and resolve compilation issues

## Project Context

EdgePad is a menu-bar utility that watches raw finger positions on the trackpad and fires actions when fingers slide along the four edges:
- Right edge (vertical): Volume up/down
- Top edge (horizontal): Brightness up/down
- Left edge (vertical): Configurable (Stage 3)
- Bottom edge (horizontal): Configurable (Stage 3)

## Key Technical Decisions

1. **No App Sandbox**: Required for CGEventTap system-wide event monitoring
2. **Developer ID Signing**: Uses Apple Development certificate for stable TCC permissions
3. **Swift 6 Strict Concurrency**: Code uses @MainActor and @unchecked Sendable where appropriate
4. **Core Audio + Media Keys**: Volume via Core Audio (precise), Brightness via media keys (HUD support)
5. **CGEventTap**: Session-level event tap for system-wide gesture recognition

## File Structure

```
EdgePad/
├── EdgePadApp.swift          # App entry point with MenuBarExtra
├── AppDelegate.swift         # App lifecycle, event tap management
├── ContentView.swift         # TouchDebugView for Milestone A testing
├── Info.plist               # LSUIElement=YES, deployment target 26.0
├── Core/
│   ├── TrackpadEdge.swift    # Edge enum with coordinate math
│   ├── EdgeBinding.swift     # Action bindings and configuration
│   ├── EdgeGestureRecognizer.swift  # State machine for gesture recognition
│   └── ConfigurationStore.swift     # UserDefaults persistence
├── Input/
│   ├── TrackpadTouchView.swift     # NSView for in-app touch capture
│   └── GestureEventTap.swift       # CGEventTap wrapper
├── Actions/
│   ├── SystemVolume.swift    # Core Audio volume control
│   ├── SystemBrightness.swift       # Media key brightness control
│   └── HIDKeyPoster.swift    # Synthetic media key events
├── Permissions/
│   └── PermissionChecker.swift      # TCC Accessibility/Input Monitoring
└── UI/
    ├── TouchDebugView.swift   # Visual finger tracking (Milestone A)
    └── PreferencesView.swift  # Per-edge configuration UI (Milestone D)
```

## Build Commands

```bash
# Swift Package Manager (for quick verification)
swift build

# Xcode (for proper app bundle with entitlements)
# Open in Xcode and build (⌘B)
```

## Known Issues / Warnings

1. Swift 6 concurrency warnings in AppDelegate - should add @MainActor to class
2. Timer closure captures self - acceptable since it runs on main queue
3. NSAlert usage in nonisolated context - runs on main thread in practice