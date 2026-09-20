#!/bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$DIR"

echo "=========================================="
echo "        Packaging Mathtype-kh"
echo "=========================================="

# 1. Compile universal binary (Apple Silicon + Intel)
echo "⚙️ Compiling Universal Binary (arm64 + x86_64)..."
mkdir -p "Mathtype-kh.app/Contents/MacOS"
mkdir -p "Mathtype-kh.app/Contents/Resources"
clang++ -O2 -std=c++17 -arch arm64 -arch x86_64 -framework Cocoa -framework WebKit \
    "src/main.mm" -o "Mathtype-kh.app/Contents/MacOS/Mathtype-kh"

# Ensure Info.plist and icons are present
if [ -f "MathType.app/Contents/Info.plist" ]; then
    cp -f "MathType.app/Contents/Info.plist" "Mathtype-kh.app/Contents/Info.plist"
fi
if [ -f "MathType.app/Contents/Resources/App_MT_Mac.icns" ]; then
    cp -f "MathType.app/Contents/Resources/App_MT_Mac.icns" "Mathtype-kh.app/Contents/Resources/App_MT_Mac.icns"
fi

# 2. Synchronize frontend bundle
echo "📁 Syncing app assets..."
rsync -av --delete app/ "Mathtype-kh.app/Contents/Resources/app/"

# Sync to MathType.app for backward compatibility
mkdir -p "MathType.app/Contents/MacOS"
cp -f "Mathtype-kh.app/Contents/MacOS/Mathtype-kh" "MathType.app/Contents/MacOS/MathType"
rsync -av --delete app/ "MathType.app/Contents/Resources/app/"

# 3. Sign application
echo "✍️ Signing application..."
codesign -s - --force --deep "Mathtype-kh.app"

# 4. Prepare staging
echo "📦 Building component package..."
mkdir -p packaging/staging packaging/scripts
rm -rf "packaging/staging/Mathtype-kh.app"
cp -R "Mathtype-kh.app" "packaging/staging/Mathtype-kh.app"

pkgbuild --root "packaging/staging" \
         --install-location "/Applications" \
         --scripts "packaging/scripts" \
         --identifier "com.mathtype.kh" \
         --version "7.4.4" \
         "packaging/Mathtype-kh-Component.pkg"

# 5. Build distribution product package
echo "🎁 Building final distribution package..."
productbuild --distribution "packaging/distribution.xml" \
             --package-path "packaging" \
             --resources "packaging" \
             "Mathtype-kh.pkg"

# Also produce Word plugin pkg
echo "📦 Building Word Add-in package..."
pkgbuild --root "word_plugin/pkg_build/root" \
         --scripts "word_plugin/pkg_build/scripts" \
         --identifier "com.mathtype.kh.wordplugin" \
         --version "1.0.0" \
         "word_plugin/Mathtype-kh.pkg"

cp -f "Mathtype-kh.pkg" "MathType-7-Khmer-macOS.pkg"
cp -f "word_plugin/Mathtype-kh.pkg" "word_plugin/Mathtype_kh.pkg"
cp -f "word_plugin/Mathtype-kh.pkg" "Mathtype_kh.pkg"

# Clean up staging
rm -rf packaging/staging "packaging/Mathtype-kh-Component.pkg"

echo "=========================================="
echo "✅ Packaging Complete!"
echo "   Output Application Installer: Mathtype-kh.pkg"
echo "   Output Word Plugin Installer: word_plugin/Mathtype-kh.pkg"
echo "=========================================="
