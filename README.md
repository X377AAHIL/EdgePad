<p align="center">
  <img src="assets/banner.png" alt="EdgePad Banner" width="800"/>
</p>

<h1 align="center">EdgePad</h1>

<p align="center">
  <b>Turn your trackpad edges into powerful system controls.</b>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/platform-macOS%2026.0+-black?style=for-the-badge&logo=apple&logoColor=white" alt="Platform">
  <img src="https://img.shields.io/badge/Swift-6-F05138?style=for-the-badge&logo=swift&logoColor=white" alt="Swift">
  <img src="https://img.shields.io/badge/License-MIT-blue?style=for-the-badge" alt="License">
  <img src="https://img.shields.io/github/v/release/X377AAHIL/EdgePad?style=for-the-badge&color=brightgreen" alt="Release">
</p>

<p align="center">
  <a href="#-features">Features</a> •
  <a href="#-how-it-works">How It Works</a> •
  <a href="#-installation">Installation</a> •
  <a href="#-actions">Actions</a> •
  <a href="#-configuration">Configuration</a> •
  <a href="#-permissions">Permissions</a>
</p>

---

<!-- 🔽 REPLACE: Add a hero screenshot or GIF of the app in action -->
<p align="center">
  <img src="assets/hero-screenshot.png" alt="EdgePad in action" width="700"/>
</p>

---

## ✨ Features

<table>
  <tr>
    <td align="center" width="33%">
      <img src="assets/feature-edges.png" alt="4 Edge Zones" width="200"/><br/>
      <b>4 Edge Zones</b><br/>
      <sub>Left · Right · Top · Bottom</sub>
    </td>
    <td align="center" width="33%">
      <img src="assets/feature-actions.png" alt="7 Actions" width="200"/><br/>
      <b>7 Built-in Actions</b><br/>
      <sub>Volume · Brightness · Scroll & more</sub>
    </td>
    <td align="center" width="33%">
      <img src="assets/feature-haptic.png" alt="Haptic Feedback" width="200"/><br/>
      <b>Haptic Feedback</b><br/>
      <sub>Tactile response on every step</sub>
    </td>
  </tr>
  <tr>
    <td align="center" width="33%">
      <img src="assets/feature-menubar.png" alt="Menu Bar App" width="200"/><br/>
      <b>Menu Bar App</b><br/>
      <sub>Lives quietly in your menu bar</sub>
    </td>
    <td align="center" width="33%">
      <img src="assets/feature-visualizer.png" alt="Touch Visualizer" width="200"/><br/>
      <b>Touch Visualizer</b><br/>
      <sub>See your finger positions in real time</sub>
    </td>
    <td align="center" width="33%">
      <img src="assets/feature-glass.png" alt="Glassmorphic UI" width="200"/><br/>
      <b>Glassmorphic UI</b><br/>
      <sub>Native macOS design language</sub>
    </td>
  </tr>
</table>

---

## 🧠 How It Works

```
                    ┌─── Top Edge ───┐
                    │   Brightness   │
                    │                │
          Left ─────┤                ├───── Right
          Edge      │                │      Edge
       (Custom)     │   Trackpad     │   (Volume)
                    │                │
                    │                │
                    └── Bottom Edge ─┘
                       Media Scrub
```

EdgePad monitors your trackpad at the system level. When your finger enters an **edge zone**, it locks in and converts your sliding motion into system actions — no clicking, no shortcuts, just natural gestures.

| Step | What Happens |
|------|-------------|
| 🖐️ Touch | Place finger(s) near any trackpad edge |
| 🔒 Lock | EdgePad detects the edge zone and locks the gesture |
| 👆 Slide | Slide along the edge to trigger repeated actions |
| 📳 Feel | Haptic feedback confirms each step |

---

## 📦 Installation

### Download

> **[⬇️ Download the latest EdgePad.dmg from Releases](https://github.com/X377AAHIL/EdgePad/releases/latest)**

### Steps

```
1. Download EdgePad.dmg
2. Open the disk image
3. Drag EdgePad.app → Applications
4. Launch EdgePad from your Applications folder
5. Grant Accessibility permission when prompted
```

### Build from Source

```bash
git clone https://github.com/X377AAHIL/EdgePad.git
cd EdgePad
xcodebuild -project EdgePad.xcodeproj -scheme EdgePad -configuration Release build
```

---

## ⚡ Actions

Each trackpad edge can be assigned one of these actions:

| Action | Description | Edge Direction |
|:------:|:-----------:|:--------------:|
| 🔊 **Volume** | System audio volume up/down | ↕ Slide vertically |
| 🔆 **Brightness** | Display brightness up/down | ↔ Slide horizontally |
| ⌨️ **Keyboard Backlight** | Keyboard light up/down | ↕ or ↔ |
| 📜 **Scroll** | Vertical scroll in any app | ↕ Slide vertically |
| ⏩ **Media Scrub** | Skip forward/backward in media | ↔ Slide horizontally |
| ⏭️ **Media Scrub (Fast)** | Jump forward/backward (⌥+Arrow) | ↔ Slide horizontally |

---

## ⚙️ Configuration

<!-- 🔽 REPLACE: Add a screenshot of the PreferencesView here -->
<p align="center">
  <img src="assets/preferences.png" alt="Preferences Window" width="600"/>
</p>

EdgePad is fully customizable per-edge through its **Preferences window**:

| Setting | Range | Description |
|---------|:-----:|-------------|
| **Action** | 7 options | What the edge does |
| **Band Width** | 5–35% | How wide the edge zone is |
| **Sensitivity** | 1–20% | Distance between each step trigger |
| **Min. Dwell** | 0–500ms | Hold time before gesture activates |
| **Touch Count** | 1–3 | Fingers required to activate |
| **Invert** | On/Off | Reverse the action direction |

---

## 🔐 Permissions

EdgePad needs two macOS permissions to read trackpad input:

<table>
  <tr>
    <td align="center" width="50%">
      <h3>🛡️ Accessibility</h3>
      <sub>System Settings → Privacy & Security → Accessibility</sub><br/><br/>
      <b>Required</b> — Enables system-wide gesture detection
    </td>
    <td align="center" width="50%">
      <h3>🖱️ Input Monitoring</h3>
      <sub>System Settings → Privacy & Security → Input Monitoring</sub><br/><br/>
      <b>Optional</b> — Needed if gestures don't register
    </td>
  </tr>
</table>

---

## 🏗️ Architecture

```
EdgePad/
├── Core/
│   ├── EdgeGestureRecognizer   ← State machine for gesture detection
│   ├── EdgeBinding             ← Per-edge configuration model
│   ├── TrackpadEdge            ← Edge enum with coordinate math
│   └── ConfigurationStore      ← UserDefaults persistence
├── Actions/
│   ├── SystemVolume            ← Core Audio volume control
│   ├── SystemBrightness        ← Display brightness via media keys
│   └── HIDKeyPoster            ← Synthetic key event posting
├── Input/
│   ├── GestureEventTap         ← CGEventTap for system-wide input
│   └── PermissionChecker       ← TCC permission handling
└── UI/
    ├── PreferencesView         ← SwiftUI settings panel
    ├── EdgeSettingsCard        ← Per-edge configuration card
    ├── TrackpadVisualizerView  ← Real-time finger visualization
    └── GlassStyles             ← Glassmorphic design tokens
```

---

## 📸 Screenshots

<!-- 🔽 REPLACE: Add your app screenshots below -->

<p align="center">
  <img src="assets/screenshot-1.png" alt="Screenshot 1" width="45%"/>
  &nbsp;&nbsp;
  <img src="assets/screenshot-2.png" alt="Screenshot 2" width="45%"/>
</p>

<p align="center">
  <img src="assets/screenshot-3.png" alt="Screenshot 3" width="45%"/>
  &nbsp;&nbsp;
  <img src="assets/screenshot-4.png" alt="Screenshot 4" width="45%"/>
</p>

---

## 🗺️ Roadmap

- [ ] 🎯 Per-app profiles (different bindings per application)
- [ ] 📐 Corner zone support (tap actions)
- [ ] 📈 Acceleration curves for step distance
- [ ] 🚀 Launch at login (SMAppService)
- [ ] 🔏 Distribution notarization

---

<p align="center">
  Made with ❤️ by <a href="https://github.com/X377AAHIL">Aahil Shaarav G</a>
</p>

<p align="center">
  <sub>Copyright © 2026 Aahil Shaarav G. All rights reserved.</sub>
</p>
