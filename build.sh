#!/bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$DIR"

echo "=========================================="
echo "         Building Mathtype-kh"
echo "=========================================="

# 1. Install frontend dependencies if needed
if [ ! -d "app/node_modules" ]; then
    echo "📦 Installing frontend dependencies..."
    (cd app && npm install)
fi

# 2. Compile native macOS binary
echo "⚙️ Compiling native Cocoa/WebKit binary (src/main.mm)..."
mkdir -p "Mathtype-kh.app/Contents/MacOS"
mkdir -p "Mathtype-kh.app/Contents/Resources"

clang++ -O2 -std=c++17 -framework Cocoa -framework WebKit \
    "src/main.mm" -o "Mathtype-kh.app/Contents/MacOS/Mathtype-kh"

# Ensure Info.plist and icons are present
if [ -f "MathType.app/Contents/Info.plist" ]; then
    cp -f "MathType.app/Contents/Info.plist" "Mathtype-kh.app/Contents/Info.plist"
fi
if [ -f "MathType.app/Contents/Resources/App_MT_Mac.icns" ]; then
    cp -f "MathType.app/Contents/Resources/App_MT_Mac.icns" "Mathtype-kh.app/Contents/Resources/App_MT_Mac.icns"
fi

# 3. Synchronize frontend bundle into App
echo "📁 Syncing app assets..."
rsync -av --delete app/ "Mathtype-kh.app/Contents/Resources/app/"

# Also sync to MathType.app for backward compatibility
mkdir -p "MathType.app/Contents/MacOS"
cp -f "Mathtype-kh.app/Contents/MacOS/Mathtype-kh" "MathType.app/Contents/MacOS/MathType"
rsync -av --delete app/ "MathType.app/Contents/Resources/app/"

# 4. Install into /Applications and sign
echo "🚀 Installing to /Applications/Mathtype-kh.app..."
rm -rf "/Applications/Mathtype-kh.app"
cp -R "Mathtype-kh.app" "/Applications/Mathtype-kh.app"
codesign -s - --force --deep "/Applications/Mathtype-kh.app"

# Backward compatibility install
rm -rf "/Applications/MathType 7.app"
cp -R "Mathtype-kh.app" "/Applications/MathType 7.app"
codesign -s - --force --deep "/Applications/MathType 7.app"

echo "=========================================="
echo "✅ Build & Installation Successful!"
echo "   Application: /Applications/Mathtype-kh.app"
echo "=========================================="
