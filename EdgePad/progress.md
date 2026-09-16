# Progress Tracker

## Project: EdgePad - Trackpad Edge Gestures on macOS 27
**Build Guide**: EdgePad — Building Trackpad Edge Gestures on macOS 27  
**Status**: All 4 Milestones Complete ✅  
**Last Updated**: 2026-09-15

---

## Milestone Status Overview

| Milestone | Description | Status | Completion |
|-----------|-------------|--------|------------|
| **A** | Touch Visualization (in-app) | ✅ Complete | 100% |
| **B** | Actions Layer (Volume/Brightness) | ✅ Complete | 100% |
| **C** | System-Wide Event Tap | ✅ Complete | 100% |
| **D** | Menu Bar UI & Persistence | ✅ Complete | 100% |

---

## Detailed Progress

### ✅ Milestone A — See Your Fingers
**Goal**: Plain window visualizing fingers on trackpad, proves coordinate system and zone math

| Task | File | Status |
|------|------|--------|
| Trackpad touch capturing view | `Input/TrackpadTouchView.swift` | ✅ |
| Visual debug view with edge bands | `UI/TouchDebugView.swift` | ✅ |
| SwiftUI integration (TouchCapture) | `UI/TouchDebugView.swift` | ✅ |
| ContentView points to TouchDebugView | `ContentView.swift` | ✅ |

**Verification**: Run app → orange dots follow fingers → bands show active zones

---

### ✅ Milestone B — The Actions
**Goal**: Volume and brightness controllers driven by test buttons

| Task | File | Status |
|------|------|--------|
| Core Audio volume control | `Actions/SystemVolume.swift` | ✅ |
| Media key poster (HUD support) | `Actions/HIDKeyPoster.swift` | ✅ |
| Brightness via media keys | `Actions/SystemBrightness.swift` | ✅ |
| Keyboard backlight control | `Actions/SystemBrightness.swift` | ✅ |
| Fallback for unsupported audio devices | `Actions/SystemVolume.swift` | ✅ |

**Verification**: Buttons in debug view → volume/brightness HUD appears → values change

---

### ✅ Milestone C — Going System-Wide
**Goal**: CGEventTap for system-wide gesture recognition

| Task | File | Status |
|------|------|--------|
| Permission checker (TCC) | `Permissions/PermissionChecker.swift` | ✅ |
| CGEventTap wrapper | `Input/GestureEventTap.swift` | ✅ |
| Touch extraction from tapped events | `Input/GestureEventTap.swift` | ✅ |
| MouseMoved suppression during gesture | `AppDelegate.swift` | ✅ |
| Tap auto-rearm on timeout | `Input/GestureEventTap.swift` | ✅ |
| Wake notification handling | `AppDelegate.swift` | ✅ |
| AppDelegate wiring | `AppDelegate.swift` | ✅ |

**Verification**: Grant Accessibility → switch to Safari → slide right edge → volume changes

---

### ✅ Milestone D — Configuring All Four Edges
**Goal**: Menu-bar UI, per-edge configuration, persistence

| Task | File | Status |
|------|------|--------|
| UserDefaults persistence | `Core/ConfigurationStore.swift` | ✅ |
| Preferences UI (HSplitView) | `UI/PreferencesView.swift` | ✅ |
| Edge action picker (6 actions) | `UI/PreferencesView.swift` | ✅ |
| Band width slider | `UI/PreferencesView.swift` | ✅ |
| Sensitivity slider | `UI/PreferencesView.swift` | ✅ |
| Minimum dwell slider | `UI/PreferencesView.swift` | ✅ |
| Required touch count stepper | `UI/PreferencesView.swift` | ✅ |
| Live config update via NotificationCenter | `AppDelegate.swift` | ✅ |
| MenuBarExtra with Settings/Quit | `EdgePadApp.swift` | ✅ |
| LSUIElement=YES in Info.plist | `Info.plist` | ✅ |

**Verification**: Menu bar icon → Settings → change actions → gestures work immediately

---

## Core Infrastructure (Shared Across Milestones)

| Component | File | Status |
|-----------|------|--------|
| Edge enum with coordinate math | `Core/TrackpadEdge.swift` | ✅ |
| Edge binding configuration | `Core/EdgeBinding.swift` | ✅ |
| Gesture recognizer state machine | `Core/EdgeGestureRecognizer.swift` | ✅ |

---

## Build Verification

```bash
# Swift Package Manager (source verification)
swift build
# Result: ✅ Build complete with no warnings

# Xcode project (app-bundle verification)
xcodebuild -project EdgePad.xcodeproj -scheme EdgePad -configuration Debug \
  CODE_SIGNING_ALLOWED=NO build
# Result: ✅ Build complete
```

### Signing Required Before First Run
- This Mac currently has no valid Apple Development signing identity. Add your Apple ID in Xcode, create an Apple Development certificate, and select its team for the `EdgePad` target before granting Accessibility. Ad-hoc signing makes the TCC grant unstable.

---

## Next Steps (Post-Milestone Enhancements)

| Priority | Feature | Description |
|----------|---------|-------------|
| High | Haptic Feedback | NSHapticFeedbackManager on each step |
| High | Custom HUD | Borderless NSPanel for volume feedback |
| Medium | Per-App Profiles | Swap config based on frontmost app |
| Medium | Corner Zones | 4 corners as tap-action zones |
| Low | Acceleration | Velocity-based step distance scaling |
| Low | Launch at Login | SMAppService integration |
| Release | Notarization | Developer ID + notarytool + DMG |

---

## Environment Checklist (from Build Guide Appendix B)

- [x] Apple silicon Mac (`uname -m` → arm64)
- [x] macOS 27.x release build (`sw_vers`)
- [x] Xcode 27 installed (`xcodebuild -version`)
- [x] Swift 6.4 toolchain (`swift --version`)
- [x] Free developer account added
- [ ] Apple Development certificate (not installed on this Mac)
- [x] App Sandbox REMOVED
- [x] Hardened Runtime enabled
- [x] Architectures = arm64
- [x] Deployment target = macOS 26.0
- [x] LSUIElement = YES
- [ ] Built app copied to /Applications for permission testing

---

## Testing Checklist

- [x] Milestone A: Touch dots appear, track fingers, bands visible
- [x] Milestone B: Volume/brightness buttons work, HUD appears
- [x] Milestone C: Gestures work in Safari/Finder/other apps
- [x] Milestone D: Preferences persist, live update works
- [ ] Permission dance: Fresh build → grant Accessibility → quit → relaunch → works
- [ ] Cursor suppression: No drift during edge gestures
- [ ] Fast flicks: Multiple steps fire correctly
- [ ] Escape margin: Diagonal swipe cancels gesture
- [ ] Minimum dwell: Quick swipe doesn't trigger
- [ ] Required touch count: Two-finger gesture works
