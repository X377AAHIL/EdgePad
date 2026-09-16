# Changelog

All notable changes to EdgePad will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-09-15

### Added - Milestone A: Touch Visualization
- `TrackpadTouchView` - NSView subclass for capturing indirect (trackpad) touches
- `TouchDebugView` - SwiftUI wrapper visualizing finger positions as orange dots
- Edge band shading (blue for vertical edges, green for horizontal edges)
- Touch coordinate normalization (0...1, origin bottom-left)

### Added - Milestone B: Actions Layer
- `SystemVolume` - Core Audio volume control with precise step adjustments
- `SystemBrightness` - Media key brightness control (shows system HUD)
- `KeyboardBacklight` - Media key keyboard backlight control
- `HIDKeyPoster` - Synthetic media key event posting (NX_SUBTYPE_AUX_CONTROL_BUTTONS)
- Fallback to media keys when Core Audio volume not supported

### Added - Milestone C: System-Wide Event Tap
- `GestureEventTap` - CGEventTap wrapper for session-level event monitoring
- `PermissionChecker` - TCC Accessibility and Input Monitoring permission handling
- MouseMoved event suppression during active edge gestures
- Tap auto-rearm on timeout/disable
- Wake notification handling for TCC revocation

### Added - Core Models
- `TrackpadEdge` - Enum for four edges with coordinate math (travel axis, depth)
- `EdgeBinding` - Per-edge configuration (action, band width, sensitivity, inversion)
- `EdgeConfiguration` - Complete edge binding dictionary with defaults
- `EdgeGestureRecognizer` - State machine for gesture recognition
  - Per-finger tracking using NSTouch.identity
  - Accumulator with while-loop for fast flicks
  - Escape margin hysteresis
  - Minimum dwell and required touch count options

### Added - Milestone D: Menu Bar UI & Persistence
- `ConfigurationStore` - UserDefaults persistence for edge configuration
- `PreferencesView` - HSplitView with edge list and per-edge form
  - Action picker (none, volume, brightness, keyboard backlight, scroll, media scrub)
  - Invert direction toggle
  - Band width slider (5-35%)
  - Sensitivity slider (step distance 1-20%)
  - Minimum dwell slider (0-500ms)
  - Required touch count stepper (1-3)
- `EdgePadApp` - MenuBarExtra with Settings and Quit
- `AppDelegate` - Full wiring of recognizer, tap, and actions
- NotificationCenter integration for live config updates

### Changed
- `Info.plist` - Added LSUIElement=YES for menu-bar-only app
- Deployment target set to macOS 26.0
- Swift 6 concurrency compliance (@MainActor, @unchecked Sendable)

### Fixed
- Concurrency-safe static properties (let instead of var)
- Sendable closure captures with @Sendable attribute
- kAXTrustedCheckOptionPrompt usage for Swift 6 compatibility

## [Unreleased]

### Fixed
- Restored the missing Xcode project definition and shared `EdgePad` scheme.
- Set the app target to arm64, macOS 26.0, non-sandboxed, and hardened runtime in line with the build guide.
- Corrected the raw `LSUIElement` Info.plist key so EdgePad is actually a menu-bar app.
- Removed Swift 6 concurrency warnings and prevented gesture travel before dwell/finger-count thresholds from firing delayed actions.
- Updated the Swift Package manifest to validate on macOS 26 and exclude non-source project files.

### Planned
- Haptic feedback on each step (NSHapticFeedbackManager)
- Custom HUD for Core Audio volume changes
- Per-app configuration profiles
- Corner zone support (tap actions)
- Acceleration curves for step distance
- Launch at login (SMAppService)
- Distribution notarization
