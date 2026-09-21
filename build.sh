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

clang++ -O2 -std=c++17 -arch arm64 -arch x86_64 -framework Cocoa -framework WebKit \
    "src/main.mm" -o "Mathtype-kh.app/Contents/MacOS/Mathtype-kh"

# 3. Synchronize frontend bundle into App
echo "📁 Syncing app assets..."
rsync -av --delete app/ "Mathtype-kh.app/Contents/Resources/app/"

# 4. Install into /Applications and sign
echo "🚀 Installing to /Applications/Mathtype-kh.app..."
rm -rf "/Applications/Mathtype-kh.app"
cp -R "Mathtype-kh.app" "/Applications/Mathtype-kh.app"
codesign -s - --force --deep "/Applications/Mathtype-kh.app"

echo "=========================================="
echo "✅ Build & Installation Successful!"
echo "   Application: /Applications/Mathtype-kh.app"
echo "=========================================="
