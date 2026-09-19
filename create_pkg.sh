#!/bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$DIR"

echo "=========================================="
echo " Packaging MathType 7 (Khmer Math Edition)"
echo "=========================================="

# 1. Compile universal binary (Apple Silicon + Intel)
echo "⚙️ Compiling Universal Binary (arm64 + x86_64)..."
mkdir -p "MathType.app/Contents/MacOS"
mkdir -p "MathType.app/Contents/Resources"
clang++ -O2 -std=c++17 -arch arm64 -arch x86_64 -framework Cocoa -framework WebKit \
    "src/main.mm" -o "MathType.app/Contents/MacOS/MathType"

# 2. Synchronize frontend bundle
echo "📁 Syncing app assets..."
rsync -av --delete app/ "MathType.app/Contents/Resources/app/"

# 3. Sign application
echo "✍️ Signing application..."
codesign -s - --force --deep "MathType.app"

# 4. Prepare staging
echo "📦 Building component package..."
mkdir -p packaging/staging packaging/scripts
rm -rf "packaging/staging/MathType 7.app"
cp -R "MathType.app" "packaging/staging/MathType 7.app"

pkgbuild --root "packaging/staging" \
         --install-location "/Applications" \
         --scripts "packaging/scripts" \
         --identifier "com.dessci.mathtype7.kh" \
         --version "7.4.4" \
         "packaging/MathType-Component.pkg"

# 5. Build distribution product package
echo "🎁 Building final distribution package..."
productbuild --distribution "packaging/distribution.xml" \
             --package-path "packaging" \
             --resources "packaging" \
             "MathType-7-Khmer-macOS.pkg"

# Clean up staging
rm -rf packaging/staging "packaging/MathType-Component.pkg"

echo "=========================================="
echo "✅ Packaging Complete!"
echo "   Output: MathType-7-Khmer-macOS.pkg"
echo "=========================================="
