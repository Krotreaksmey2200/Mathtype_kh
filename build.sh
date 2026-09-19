#!/bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$DIR"

echo "=========================================="
echo "  Building MathType 7 (Khmer Math Edition)"
echo "=========================================="

# 1. Install frontend dependencies if needed
if [ ! -d "app/node_modules" ]; then
    echo "📦 Installing frontend dependencies..."
    (cd app && npm install)
fi

# 2. Compile native macOS binary
echo "⚙️ Compiling native Cocoa/WebKit binary (src/main.mm)..."
mkdir -p "MathType.app/Contents/MacOS"
mkdir -p "MathType.app/Contents/Resources"
clang++ -O2 -std=c++17 -framework Cocoa -framework WebKit \
    "src/main.mm" -o "MathType.app/Contents/MacOS/MathType"

# 3. Synchronize frontend bundle into App
echo "📁 Syncing app assets..."
rsync -av --delete app/ "MathType.app/Contents/Resources/app/"

# 4. Install into /Applications and sign
echo "🚀 Installing to /Applications/MathType 7.app..."
rm -rf "/Applications/MathType 7.app"
cp -R "MathType.app" "/Applications/MathType 7.app"
codesign -s - --force --deep "/Applications/MathType 7.app"

echo "=========================================="
echo "✅ Build & Installation Successful!"
echo "   Application: /Applications/MathType 7.app"
echo "=========================================="
