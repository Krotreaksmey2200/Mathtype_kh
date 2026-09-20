# Mathtype-kh 🇰🇭

> **Native 64-bit MathType Desktop Application for macOS** powered by a high-resolution **LaTeX Kernel Engine (300 DPI)** and deep **Microsoft Word Automation** with automatic **Baseline Alignment**.

---

### 📥 Download Installers (Latest Release):

| Package | Description | Direct Download |
|---|---|---|
| **Mathtype-kh All-in-One** | Installs both **Mathtype-kh.app** and the **Microsoft Word Plugin Suite** *(Recommended)* | 👉 **[Download Mathtype-kh-v7.4.4.pkg](https://github.com/Krotreaksmey2200/Mathtype_kh/releases/download/v7.4.4/Mathtype-kh-v7.4.4.pkg)** |
| **Word Plugin Standalone** | Installs only the **Microsoft Word Add-in & Ribbon toolbar** | 👉 **[Download Mathtype-kh-WordPlugin-v7.4.4.pkg](https://github.com/Krotreaksmey2200/Mathtype_kh/releases/download/v7.4.4/Mathtype-kh-WordPlugin-v7.4.4.pkg)** |
| **Complete Uninstaller** | Completely removes and cleans up all app files, Word templates, and settings | 👉 **[Download Remove_mathtype_kh.pkg](https://github.com/Krotreaksmey2200/Mathtype_kh/releases/download/v7.4.4/Remove_mathtype_kh.pkg)** |

> 💡 **Compatibility:** Universal Binary supporting both **Apple Silicon (M1/M2/M3/M4)** and **Intel** Macs on macOS 11.0 Big Sur through macOS 15+ Sequoia.  
> 🔗 View all versions on **[GitHub Releases](https://github.com/Krotreaksmey2200/Mathtype_kh/releases)**.

---

## ✨ Key Features

1. **⚡ 1-Click Insert into Microsoft Word**
   - Click the green **"Insert into Word"** button or press **`⌘ + I`**.
   - **Auto Word Mode:** When typing finishes, simply hit **`Enter`** (Return) or **`⌘ + Enter`** to automatically insert the equation directly into Word at the cursor position.

2. **✏️ In-Place Equation Editing**
   - Select an existing equation in Microsoft Word and click **"Edit Equation"** (កែប្រែសមីការ) on the Word ribbon.
   - **Mathtype-kh** immediately opens, brings itself to the foreground, and loads the existing LaTeX formula into the editor canvas.
   - When you click **"Insert into Word"**, it seamlessly replaces the old equation with the newly edited formula in-place without duplicating.

3. **🔄 Toggle TeX Integration**
   - Highlight any LaTeX code or formula (such as `$E=mc^2$`) in Microsoft Word and click **`Toggle TeX`** (or press **`⌥ + \`** / **`⌥ + T`**).
   - Automatically converts raw text expressions into high-resolution 300 DPI equations in the background.

4. **📐 Automatic Baseline Alignment**
   - Accurately calculates the exact bounding box and depth ratio below the baseline using `dvisvgm`.
   - Automates Word via AppleScript to adjust font position shifts, ensuring equations sit evenly on the text line with no baseline misalignment.

5. **⚙️ LaTeX Path Configuration in Help Menu**
   - Access **Help -> ⚙️ Configure LaTeX Path...** to verify your `latex`, `dvipng`, and `dvisvgm` binaries.
   - Supports custom binary paths or convenient presets (`/Library/TeX/texbin`, `/opt/homebrew/bin`, `/usr/local/bin`), saved permanently in `NSUserDefaults`.

6. **🛡️ Zero "Grant File Access" Prompts (Word Sandbox Optimized)**
   - Generated equations are placed directly into Word's own secure container sandbox (`~/Library/Containers/com.microsoft.Word/Data/tmp/`).
   - Word reads and inserts pictures 100% silently with no annoying file access permission popups.

7. **🌐 Bilingual Interface**
   - Toggle between **Khmer 🇰🇭** and **English 🇺🇸** with a single click at any time.

---

## ⌨️ Keyboard Shortcuts

| Shortcut | Action |
|---|---|
| **`Enter`** or **`⌘ + Enter`** | Insert equation into Microsoft Word immediately (Auto Word Mode) |
| **`⌘ + I`** | Insert into Word |
| **`⌥ + \`** or **`⌥ + T`** | Toggle TeX (Convert LaTeX selection in Word) |
| **`⌘ + C`** | Copy 300 DPI high-resolution image to clipboard |
| **`⌘ + F`** | Insert Fraction (`\frac{}{}`) |
| **`⌘ + R`** | Insert Square Root (`\sqrt{}`) |
| **`⇧ + ⌘ + R`** | Insert N-th Root (`\sqrt[n]{}`) |
| **`⌘ + H`** | Insert Superscript (`^{}`) |
| **`⌘ + L`** | Insert Subscript (`_{}`) |
| **`⌘ + J`** | Insert Superscript & Subscript combined (`_{}^{}`) |
| **`Escape`** | Close any open modal or dialog |

---

## 🛠️ Project Architecture

```
Mathtype_kh/
├── src/
│   └── main.mm              # Native Cocoa/WebKit app, LaTeX compilation kernel & Word AppleScript
├── app/
│   ├── index.html           # Web UI layout & ribbon toolbar structure
│   ├── mathtype.js          # App logic, MathLive integration, shortcuts, localization
│   ├── mathtype.css         # Modern macOS styling, dark/light themes, modal UI
│   ├── package.json         # Frontend dependencies (MathLive, KaTeX, html2canvas)
│   └── assets/              # Icons, symbol palettes, official MathType branding
├── word_plugin/
│   ├── Mathtype-kh.dotm     # Microsoft Word ribbon template add-in
│   ├── Mathtype-kh.applescript # AppleScript automation for Word
│   └── toggle_tex_worker.py # Background TeX parsing engine
├── packaging/
│   ├── distribution.xml     # Distribution XML for productbuild
│   ├── welcome.html         # macOS Installer welcome screen
│   └── uninstaller/         # Complete cleanup scripts and configuration
├── build.sh                 # 1-Click build, compile & local install script
├── create_pkg.sh            # Universal PKG installer builder
├── publish_release.py       # Automated GitHub Release publisher
└── README.md                # Project documentation
```

---

## 🚀 Building from Source

### Prerequisites:
- macOS (Apple Silicon M1/M2/M3/M4 or Intel)
- Xcode Command Line Tools (`xcode-select --install`)
- MacTeX or BasicTeX (`brew install --cask mactex-no-gui`)
- Node.js & npm (for frontend libraries)

### 1. Build and Run Locally:
```bash
./build.sh
```

### 2. Build Release Installer Packages (`.pkg`):
```bash
./create_pkg.sh
```
This builds:
- `Mathtype-kh.pkg` (All-in-One Installer)
- `word_plugin/Mathtype-kh.pkg` (Standalone Word Plugin)
- `Remove_mathtype_kh.pkg` (Complete Uninstaller)

### 3. Publish a New Version to GitHub:
```bash
python3 publish_release.py v7.4.5
```

---

## 👤 Author & Credits

- **Krot Reaksmey** ([@Krotreaksmey2200](https://github.com/Krotreaksmey2200))
- Email: krotreaksmey2200@gmail.com
- Repository: [https://github.com/Krotreaksmey2200/Mathtype_kh](https://github.com/Krotreaksmey2200/Mathtype_kh)

---

## 📄 License
Released under the [MIT License](LICENSE) or personal educational license by K.Reaksmey.
