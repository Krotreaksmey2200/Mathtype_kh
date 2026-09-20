# Mathtype-kh 🇰🇭

> **Native 64-bit Mathtype-kh Desktop Application for macOS** with high-resolution **LaTeX Kernel Engine (300 DPI)** and deep **Microsoft Word Automation** with automatic **Baseline Alignment**.

### 📥 កញ្ចប់ដំឡើងតាម Version Release (Download Installers):
👉 **[ទាញយក Mathtype-kh-v7.4.4.pkg (All-in-One Installer)](https://github.com/Krotreaksmey2200/Mathtype_kh/releases/download/v7.4.4/Mathtype-kh-v7.4.4.pkg)** *(ណែនាំ: ដំឡើងទាំង Mathtype-kh.app និង Word Plugin ក្នុងពេលតែមួយ)*  
👉 **[ទាញយក Mathtype-kh-WordPlugin-v7.4.4.pkg (Word Plugin Standalone)](https://github.com/Krotreaksmey2200/Mathtype_kh/releases/download/v7.4.4/Mathtype-kh-WordPlugin-v7.4.4.pkg)** *(សម្រាប់អ្នកដែលចង់ដំឡើងតែ Plugin លើ Word)*  
*(ចុច Double-Click លើឯកសារ `.pkg` នេះ ដើម្បីដំឡើងលើកុំព្យូទ័រ Mac បានភ្លាមៗ គាំទ្រទាំង Apple Silicon M1/M2/M3/M4 និង Intel)*

---

## ✨ លក្ខណៈពិសេសចម្បង (Key Features)

1. **⚡ បញ្ចូលទៅ Word ដោយចុច ១ ដង (1-Click Insert into Word)**
   - ចុចប៊ូតុងពណ៌បៃតង **"បញ្ចូលទៅ Word"** ឬចុចផ្លូវកាត់ **`⌘ + I`**
   - **Auto Word Mode**: ពេលវាយសមីការចប់ គ្រាន់តែចុច **`Enter`** (Return) ឬ **`⌘ + Enter`** សមីការនឹងលោតចូល Microsoft Word ភ្លាមៗដោយស្វ័យប្រវត្តិ។

2. **🔄 មុខងារ Toggle TeX (ស្រង់សមីការចេញពី Word មក Mathtype-kh វិញ)**
   - គ្រាន់តែ Select លើសមីការ ឬអត្ថបទ LaTeX ក្នុង Microsoft Word រួចចុចប៊ូតុង **`Toggle TeX`** (ឬ **`⌥ + \`** / **`⌥ + T`**)
   - កម្មវិធីនឹងស្រង់យករូបមន្ត LaTeX ពី Word មកបើកកែសម្រួលក្នុង Mathtype-kh ភ្លាមៗ។ កែរួចចុច `Enter` នោះសមីការថ្មីនឹងជំនួសវិញភ្លាម។

3. **📐 ទំហំសមីការលំនាំដើម 12pt (Default Equation Size 12pt)**
   - កំណត់ទំហំអក្សរលំនាំដើម **12 pt** ស៊ីគ្នាយ៉ាងឥតខ្ចោះជាមួយទំហំអក្សរស្ដង់ដារនៃឯកសារ Microsoft Word។
   - មានជម្រើសផ្លាស់ប្តូរទំហំសមីការចាប់ពី **10pt ដល់ 36pt** ទាំងលើរបារ Toolbar និងក្នុង Menu Bar `Size`។

4. **⚙️ ផ្ទាំងកំណត់ផ្លូវ LaTeX ក្នុងម៉ឺនុយ Help (Config LaTeX Path)**
   - ចូលទៅកាន់ **ជំនួយ (Help) -> ⚙️ កំណត់ផ្លូវ LaTeX Path (Config LaTeX)...**
   - ពិនិត្យរកវត្តមានរបស់ `latex`, `dvipng`, និង `dvisvgm`
   - គាំទ្រការកំណត់ផ្លូវដោយសេរី ឬរើសតាម Presets (`/Library/TeX/texbin`, `/opt/homebrew/bin`, `/usr/local/bin`)
   - រក្សាទុកផ្លូវក្នុង `NSUserDefaults` ជាប់ជាអចិន្ត្រៃយ៍។

5. **🎯 តម្រឹមកម្ពស់បន្ទាត់ស្វ័យប្រវត្តិ (Baseline Depth Alignment)**
   - ប្រើប្រាស់ `dvisvgm` ដើម្បីគណនា Bounding Box និងកម្ពស់ស្រុតក្រោមបន្ទាត់ (`depth ratio`)
   - បញ្ជា Microsoft Word តាម AppleScript ដើម្បីរៀបចំ Font Position សមីការឱ្យនៅចំជួរអក្សរស្មើស្អាត គ្មានបញ្ហាលេចខុសបន្ទាត់។

6. **🛡️ គ្មានផ្ទាំង "Grant File Access" រំខាន (Word Sandbox Optimization)**
   - រក្សាទុករូបភាពសមីការបណ្តោះអាសន្នចូលក្នុង Container Sandbox ផ្ទាល់របស់ Word (`~/Library/Containers/com.microsoft.Word/Data/tmp/`) ធ្វើឱ្យ Word អាន និងបញ្ចូលរូបភាពបាន 100% ដោយមិនទាមទារសិទ្ធិ ឬបង្ហាញផ្ទាំងរំខានឡើយ។

7. **🌐 ទ្រទ្រង់ពីរភាសា (Bilingual Support)**
   - ភាសាខ្មែរ 🇰🇭 និងភាសាអង់គ្លេស 🇺🇸 អាចប្តូរបានភ្លាមៗដោយចុចលើប៊ូតុងភាសា។

---

## ⌨️ គ្រាប់ចុចកាត់ (Keyboard Shortcuts)

| គ្រាប់ចុចកាត់ | មុខងារ (Action) |
|---|---|
| **`Enter`** ឬ **`⌘ + Enter`** | បញ្ចូលសមីការទៅ Word ភ្លាមៗ (Auto Word Insertion) |
| **`⌘ + I`** | បញ្ចូលទៅ Word (Insert into Word) |
| **`⌥ + \`** ឬ **`⌥ + T`** | Toggle TeX (ស្រង់សមីការពី Word មក MathType) |
| **`⌘ + C`** | ចម្លងសមីការទៅ Clipboard (Copy 300 DPI Image) |
| **`⌘ + F`** | បង្កើតប្រភាគ (Fraction: `\frac{}{}`) |
| **`⌘ + R`** | បង្កើតឬសការេ (Square Root: `\sqrt{}`) |
| **`⇧ + ⌘ + R`** | បង្កើតឬសទី n (N-th Root: `\sqrt[n]{}`) |
| **`⌘ + H`** | បង្កើតស្វ័យគុណ (Superscript: `^{}`) |
| **`⌘ + L`** | បង្កើតសន្ទស្សន៍ (Subscript: `_{}`) |
| **`⌘ + J`** | បង្កើតស្វ័យគុណ និងសន្ទស្សន៍ទាំងពីរ (`_{}^{}`) |
| **`Escape`** | បិទផ្ទាំង Dialog/Modal ណាមួយ |

---

## 🛠️ រចនាសម្ព័ន្ធគម្រោង (Project Architecture)

```
Mathtype_kh/
├── src/
│   └── main.mm          # Native Cocoa/WebKit app, LaTeX compilation kernel & Word AppleScript
├── app/
│   ├── index.html       # Web UI layout & toolbar structure
│   ├── mathtype.js      # App logic, MathLive integration, shortcuts, localization
│   ├── mathtype.css     # Clean Apple HIG styling, dark/light themes, modal UI
│   ├── package.json     # Frontend dependencies (MathLive, KaTeX, html2canvas)
│   └── assets/          # Icons, palette images, Khmer math symbols
├── Mathtype-kh.app/     # macOS Application Bundle wrapper
│   └── Contents/
│       ├── Info.plist   # Bundle identifier, version & configuration
│       └── Resources/
│           └── App_MT_Mac.icns # High-resolution macOS Application Icon
├── build.sh             # 1-Click build, compile & install script
└── README.md            # Documentation
```

---

## 🚀 របៀប Compile និងដំឡើង (Build & Install)

### លក្ខខណ្ឌតម្រូវ (Prerequisites):
- macOS (Apple Silicon M1/M2/M3/M4 ឬ Intel)
- Xcode Command Line Tools (`xcode-select --install`)
- MacTeX ឬ BasicTeX (`brew install --cask mactex-no-gui`)
- Node.js & npm (សម្រាប់ frontend libraries)

### ដំណើរការ Build ដោយ ១ បន្ទាត់ពាក្យបញ្ជា៖
```bash
./build.sh
```

ឬ Compile ដោយដៃ៖
```bash
# 1. Install frontend packages
cd app && npm install && cd ..

# 2. Compile native Objective-C++ binary
clang++ -O2 -std=c++17 -framework Cocoa -framework WebKit \
  "src/main.mm" -o "Mathtype-kh.app/Contents/MacOS/Mathtype-kh"

# 3. Sync frontend assets into App Bundle
rsync -av --delete app/ Mathtype-kh.app/Contents/Resources/app/

# 4. Install into /Applications and ad-hoc code sign
rm -rf "/Applications/Mathtype-kh.app"
cp -R "Mathtype-kh.app" "/Applications/Mathtype-kh.app"
codesign -s - --force --deep "/Applications/Mathtype-kh.app"

# 5. Launch
open "/Applications/Mathtype-kh.app"
```

---

## 👤 អ្នកបង្កើត និងអភិវឌ្ឍ (Author)
- **Krot Reaksmey** ([@Krotreaksmey2200](https://github.com/Krotreaksmey2200))
- Email: krotreaksmey2200@gmail.com
