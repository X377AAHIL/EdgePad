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
  <a href="#-installation">Installation</a> •
  <a href="#-actions">Actions</a> •
  <a href="#-permissions">Permissions</a>
</p>

---

<p align="center">
  <img src="assets/app-top-edge.png" alt="Top Edge — Brightness" height="500"/>
  &nbsp;&nbsp;&nbsp;
  <img src="assets/app-left-edge.png" alt="Left Edge — Action Picker" height="500"/>
  &nbsp;&nbsp;&nbsp;
  <img src="assets/app-bottom-edge.png" alt="Bottom Edge — Media Scrub" height="500"/>
</p>

---

## ✨ Features

<table>
  <tr>
    <td align="center" width="33%">
      <h3>🎯 4 Edge Zones</h3>
      <sub>Left · Right · Top · Bottom</sub>
    </td>
    <td align="center" width="33%">
      <h3>⚡ 7 Built-in Actions</h3>
      <sub>Volume · Brightness · Scroll & more</sub>
    </td>
    <td align="center" width="33%">
      <h3>📳 Haptic Feedback</h3>
      <sub>Tactile response on every step</sub>
    </td>
  </tr>
  <tr>
    <td align="center" width="33%">
      <h3>🔲 Menu Bar App</h3>
      <sub>Lives quietly in your menu bar</sub>
    </td>
    <td align="center" width="33%">
      <h3>👆 Touch Visualizer</h3>
      <sub>See finger positions in real time</sub>
    </td>
    <td align="center" width="33%">
      <h3>💎 Glassmorphic UI</h3>
      <sub>Native macOS design language</sub>
    </td>
  </tr>
</table>

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

## 💡 Tip: Avoid Accidental Gestures While Typing

> **Palm resting on the trackpad triggering gestures while you type?**
>
> | Solution | How |
> |:--------:|:---:|
> | 👆👆 **Switch to 2-finger mode** | Set **Fingers** to `2` — your resting palm won't trigger it |
> | ⌥ **Add a modifier key** | Enable **⌥ Option** or **⌘ Command** — gestures only fire while the key is held |
>
> Both options are per-edge, so you can mix and match depending on how you use each edge.

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

<p align="center">
  Made with ❤️ by <a href="https://github.com/X377AAHIL">Aahil Shaarav G</a>
</p>

<p align="center">
  <sub>Copyright © 2026 Aahil Shaarav G. All rights reserved.</sub>
</p>
