<!-- ═══════════════════════════════════════════════════════════════════════
     EdgePad — README
     Design: Dark OLED + Glassmorphism · Accent: Cyan #00CCF2
     ═══════════════════════════════════════════════════════════════════════ -->

<br/>
<br/>

<div align="center">

<img src="assets/app-icon.png" width="128" />
<br/><br/>

<h1><big><big><strong>E D G E P A D</strong></big></big></h1>

**Turn your trackpad edges into powerful system controls.**

<sub>Slide along any edge of your MacBook trackpad to control volume, brightness, media playback, and more — no buttons, no shortcuts, just natural gestures.</sub>

<br/>

<a href="https://github.com/X377AAHIL/EdgePad/releases/latest"><img src="https://img.shields.io/badge/Download_DMG-00CCF2?style=for-the-badge&logoColor=white&labelColor=0F172A" alt="Download"></a>

<br/>
<br/>

<img src="https://img.shields.io/badge/macOS_26.0+-0F172A?style=flat-square&logo=apple&logoColor=white" alt="Platform">
&nbsp;
<img src="https://img.shields.io/badge/Swift_6-F05138?style=flat-square&logo=swift&logoColor=white" alt="Swift">
&nbsp;
<img src="https://img.shields.io/github/license/X377AAHIL/EdgePad?style=flat-square&color=334155&labelColor=0F172A" alt="License">
&nbsp;
<img src="https://img.shields.io/github/actions/workflow/status/X377AAHIL/EdgePad/swift.yml?style=flat-square&label=build&labelColor=0F172A" alt="Build">

</div>

<br/>
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

---

<br/>

<!-- ─── FEATURES ─── -->

<h2 align="center"><kbd>&nbsp;Features&nbsp;</kbd></h2>

<br/>

<div align="center">

- **4 Edge Zones** — Left, right, top, and bottom, each independently configurable
- **7 Actions** — Volume, brightness, keyboard backlight, scroll, media scrub, and fast scrub
- **Haptic Feedback** — Tactile click on every step so you feel the change
- **Touch Visualizer** — Real-time finger tracking with edge-band overlays
- **Glassmorphic UI** — Liquid Glass on macOS 26, frosted fallback on older systems
- **Menu Bar Only** — Zero dock clutter, lives quietly in your menu bar

</div>

<br/>

---

<br/>

<!-- ─── ACTIONS ─── -->

<h2 align="center"><kbd>&nbsp;Actions&nbsp;</kbd></h2>

<p align="center"><sub>Each trackpad edge can be assigned any of these:</sub></p>

<br/>

<div align="center">

| Action | What It Does | Direction |
|:------:|:------------:|:---------:|
| **Volume** | System audio up / down | Vertical |
| **Brightness** | Display brightness up / down | Horizontal |
| **Keyboard Backlight** | Backlight intensity up / down | Either |
| **Scroll** | Scroll content in any app | Vertical |
| **Media Scrub** | Skip forward / backward | Horizontal |
| **Media Scrub (Fast)** | Jump with Option + Arrow | Horizontal |

</div>

<br/>

---

<br/>

<!-- ─── TIP ─── -->

<h2 align="center"><kbd>&nbsp;Avoid Accidental Palm Triggers&nbsp;</kbd></h2>

<p align="center">
  <sub>If gestures fire while typing because your palm rests on the trackpad:</sub>
</p>

<br/>

<div align="center">

| Fix | How |
|:---:|:---:|
| 👆👆 **Use 2-finger mode** | Set **Fingers** to **2** — a resting palm won't trigger it |
| **Add a modifier key** | Enable **Option** or **Command** — gestures only fire while the key is held |

</div>

<p align="center">
  <sub>Both options are per-edge — mix and match depending on which edge you use most.</sub>
</p>

<br/>

---

<br/>

<!-- ─── INSTALL ─── -->

<h2 align="center"><kbd>&nbsp;Installation&nbsp;</kbd></h2>

<br/>

<h3 align="center">Homebrew (Recommended)</h3>

<div align="center">

```bash
brew install --cask X377AAHIL/edgepad/edgepad
```

</div>

<br/>

<h3 align="center">Manual (DMG)</h3>

<div align="center">

**[Download EdgePad.dmg](https://github.com/X377AAHIL/EdgePad/releases/latest)**

</div>

```
1 · Open the DMG
2 · Drag EdgePad into Applications
3 · Open Terminal and run:  xattr -cr /Applications/EdgePad.app
4 · Launch from Applications
5 · Grant Accessibility when prompted
```

> **Note:** Step 3 is required because EdgePad is not notarized.
> Homebrew handles this automatically — use the Homebrew method above for the smoothest experience.

<details>
<summary><b>Build from source</b></summary>

```bash
git clone https://github.com/X377AAHIL/EdgePad.git
cd EdgePad
xcodebuild -project EdgePad.xcodeproj -scheme EdgePad -configuration Release build
```

</details>

<br/>

---

<br/>

<!-- ─── UNINSTALL ─── -->

<h2 align="center"><kbd>&nbsp;Uninstallation&nbsp;</kbd></h2>

<p align="center"><sub>macOS does not automatically clean up app data when you drag an app to the Trash.</sub></p>

<br/>

<h3 align="center">Option 1: In-App Uninstaller</h3>
<div align="center">
Click the EdgePad menu bar icon, hold <code>Option (⌥)</code>, and select <b>Uninstall EdgePad...</b>
<br/><sub>This will completely remove all preferences, login items, permissions, and delete the app.</sub>
</div>

<br/>

<h3 align="center">Option 2: Homebrew</h3>
<div align="center">
If you installed via Homebrew, simply run:

```bash
brew uninstall --cask edgepad
```
</div>

<br/>

<h3 align="center">Option 3: Manual (Trash)</h3>
<div align="center">
If you prefer dragging the app to the Trash, we highly recommend using a cleaner utility like <b><a href="https://github.com/alienator88/Pearcleaner">Pearcleaner</a></b> or <b><a href="https://freemacsoft.net/appcleaner/">AppCleaner</a></b> to ensure all leftover preferences and login items are properly removed from your system.
</div>

<br/>

---

<br/>

<!-- ─── PERMISSIONS ─── -->

<h2 align="center"><kbd>&nbsp;Permissions&nbsp;</kbd></h2>

<p align="center"><sub>EdgePad reads raw trackpad touches, which macOS treats as privileged input.</sub></p>

<br/>

<table align="center">
  <tr>
    <td align="center" width="400">
      <h4>Accessibility</h4>
      <code>System Settings → Privacy & Security → Accessibility</code><br/><br/>
      <b>Required</b> — enables system-wide gesture detection
    </td>
    <td align="center" width="400">
      <h4>Input Monitoring</h4>
      <code>System Settings → Privacy & Security → Input Monitoring</code><br/><br/>
      <b>If needed</b> — add EdgePad here if gestures don't register
    </td>
  </tr>
</table>

<br/>
<br/>

---

<p align="center">
  Made with care by <a href="https://github.com/X377AAHIL"><b>Aahil Shaarav G</b></a>
</p>
<p align="center">
  <sub>© 2026 Aahil Shaarav G · All rights reserved</sub>
</p>
