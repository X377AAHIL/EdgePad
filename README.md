<!-- ═══════════════════════════════════════════════════════════════════════
     EdgePad — README
     Design: Dark OLED + Glassmorphism · Accent: Cyan #00CCF2
     Typography direction: JetBrains Mono / IBM Plex Sans (dev-tool mood)
     ═══════════════════════════════════════════════════════════════════════ -->

<br/>

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://img.shields.io/badge/EdgePad-00CCF2?style=for-the-badge&labelColor=0F172A&logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0IiBmaWxsPSIjMDBDQ0YyIj48cGF0aCBkPSJNMTUgM2wtNiAxOE0yMSA5bC02IDZNOSA5bC02IDYiLz48L3N2Zz4=">
    <img src="https://img.shields.io/badge/EdgePad-00CCF2?style=for-the-badge&labelColor=0F172A" alt="EdgePad">
  </picture>
</p>

<h3 align="center">
  Turn your trackpad edges into powerful system controls.
</h3>

<p align="center">
  <sub>Slide along any edge of your MacBook trackpad to control volume, brightness, media playback, and more — no buttons, no shortcuts, just natural gestures.</sub>
</p>

<br/>

<p align="center">
  <a href="https://github.com/X377AAHIL/EdgePad/releases/latest"><img src="https://img.shields.io/badge/⬇_Download_DMG-00CCF2?style=for-the-badge&logoColor=white&labelColor=0F172A" alt="Download"></a>
  &nbsp;
  <img src="https://img.shields.io/badge/macOS_26.0+-0F172A?style=flat-square&logo=apple&logoColor=white" alt="Platform">
  &nbsp;
  <img src="https://img.shields.io/badge/Swift_6-F05138?style=flat-square&logo=swift&logoColor=white" alt="Swift">
  &nbsp;
  <img src="https://img.shields.io/github/license/X377AAHIL/EdgePad?style=flat-square&color=334155&labelColor=0F172A" alt="License">
  &nbsp;
  <img src="https://img.shields.io/github/actions/workflow/status/X377AAHIL/EdgePad/swift.yml?style=flat-square&label=build&labelColor=0F172A" alt="Build">
</p>

<br/>

<!-- ─── APP SCREENSHOTS ─── -->

<p align="center">
  <img src="assets/app-top-edge.png" alt="Top Edge — Brightness Control" height="480"/>
  &nbsp;&nbsp;
  <img src="assets/app-left-edge.png" alt="Left Edge — Action Picker" height="480"/>
  &nbsp;&nbsp;
  <img src="assets/app-bottom-edge.png" alt="Bottom Edge — Media Scrub" height="480"/>
</p>

<br/>

<!-- ─── FEATURES ─── -->

<h2 align="center">Features</h2>

<br/>

<table align="center">
  <tr>
    <td align="center" width="280">
      <h4>🎯&ensp;4 Edge Zones</h4>
      <sub>Left · Right · Top · Bottom — each independently configurable</sub>
    </td>
    <td align="center" width="280">
      <h4>⚡&ensp;7 Actions</h4>
      <sub>Volume · Brightness · Keyboard Backlight · Scroll · Media Scrub · Fast Scrub</sub>
    </td>
    <td align="center" width="280">
      <h4>📳&ensp;Haptic Feedback</h4>
      <sub>Tactile click on every step so you feel the change</sub>
    </td>
  </tr>
  <tr><td colspan="3">&nbsp;</td></tr>
  <tr>
    <td align="center" width="280">
      <h4>👆&ensp;Touch Visualizer</h4>
      <sub>Real-time finger tracking with edge-band overlays</sub>
    </td>
    <td align="center" width="280">
      <h4>💎&ensp;Glassmorphic UI</h4>
      <sub>Liquid Glass on macOS 26 · frosted fallback on older systems</sub>
    </td>
    <td align="center" width="280">
      <h4>🔲&ensp;Menu Bar Only</h4>
      <sub>Zero dock clutter — lives quietly in your menu bar</sub>
    </td>
  </tr>
</table>

<br/>

<!-- ─── ACTIONS ─── -->

<h2 align="center">Actions</h2>

<p align="center"><sub>Each trackpad edge can be assigned any of these:</sub></p>

<br/>

<div align="center">

| | Action | What It Does | Direction |
|:-:|:------:|:------------:|:---------:|
| 🔊 | **Volume** | System audio up / down | ↕ vertical |
| 🔆 | **Brightness** | Display brightness up / down | ↔ horizontal |
| ⌨️ | **Keyboard Backlight** | Backlight intensity up / down | ↕ or ↔ |
| 📜 | **Scroll** | Scroll content in any app | ↕ vertical |
| ⏩ | **Media Scrub** | Skip forward / backward | ↔ horizontal |
| ⏭️ | **Media Scrub (Fast)** | Jump with ⌥+Arrow | ↔ horizontal |

</div>

<br/>

<!-- ─── TIP ─── -->

<h2 align="center">💡 Tip · Avoid Accidental Palm Triggers</h2>

<p align="center">
  <sub>If gestures fire while you're typing because your palm rests on the trackpad:</sub>
</p>

<br/>

<div align="center">

| Fix | How |
|:---:|:---:|
| 👆👆&ensp;**Use 2-finger mode** | Set **Fingers → 2** · a resting palm won't trigger it |
| ⌥&ensp;**Add a modifier key** | Enable **⌥ Option** or **⌘ Command** · gestures only fire while the key is held |

</div>

<p align="center">
  <sub>Both options are per-edge — mix and match depending on which edge you use most.</sub>
</p>

<br/>

<!-- ─── INSTALL ─── -->

<h2 align="center">Installation</h2>

<br/>

<div align="center">

**[⬇️&ensp;Download EdgePad.dmg](https://github.com/X377AAHIL/EdgePad/releases/latest)**

</div>

```
1 · Open the DMG
2 · Drag EdgePad → Applications
3 · Launch from Applications
4 · Grant Accessibility when prompted
```

<details>
<summary><b>Build from source</b></summary>

```bash
git clone https://github.com/X377AAHIL/EdgePad.git
cd EdgePad
xcodebuild -project EdgePad.xcodeproj -scheme EdgePad -configuration Release build
```

</details>

<br/>

<!-- ─── PERMISSIONS ─── -->

<h2 align="center">Permissions</h2>

<p align="center"><sub>EdgePad reads raw trackpad touches, which macOS treats as privileged input.</sub></p>

<br/>

<table align="center">
  <tr>
    <td align="center" width="400">
      <h4>🛡️&ensp;Accessibility</h4>
      <code>System Settings → Privacy & Security → Accessibility</code><br/><br/>
      <b>Required</b> — enables system-wide gesture detection
    </td>
    <td align="center" width="400">
      <h4>🖱️&ensp;Input Monitoring</h4>
      <code>System Settings → Privacy & Security → Input Monitoring</code><br/><br/>
      <b>If needed</b> — add EdgePad here if gestures don't register
    </td>
  </tr>
</table>

<br/>

<!-- ─── FOOTER ─── -->

---

<p align="center">
  Made with ❤️ by <a href="https://github.com/X377AAHIL"><b>Aahil Shaarav G</b></a>
</p>
<p align="center">
  <sub>© 2026 Aahil Shaarav G · All rights reserved</sub>
</p>
