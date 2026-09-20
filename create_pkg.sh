#!/bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$DIR"

VERSION="${1:-7.4.4}"
VERSION="${VERSION#v}"
TAG="v${VERSION}"

echo "=========================================="
echo "        Packaging Mathtype-kh ${TAG}"
echo "=========================================="

# 1. Compile universal binary (Apple Silicon + Intel)
echo "⚙️ Compiling Universal Binary (arm64 + x86_64)..."
mkdir -p "Mathtype-kh.app/Contents/MacOS"
mkdir -p "Mathtype-kh.app/Contents/Resources"
clang++ -O2 -std=c++17 -arch arm64 -arch x86_64 -framework Cocoa -framework WebKit \
    "src/main.mm" -o "Mathtype-kh.app/Contents/MacOS/Mathtype-kh"

# 2. Synchronize frontend bundle
echo "📁 Syncing app assets..."
rsync -av --delete app/ "Mathtype-kh.app/Contents/Resources/app/"

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
         --version "${VERSION}" \
         "packaging/Mathtype-kh-Component.pkg"

# 5. Build Word Add-in component package for distribution
echo "📦 Building Word Add-in package component..."
pkgbuild --root "word_plugin/pkg_build/root" \
         --scripts "word_plugin/pkg_build/scripts" \
         --identifier "com.mathtype.kh.wordplugin" \
         --version "${VERSION}" \
         "packaging/Mathtype-kh-WordPlugin.pkg"

# Standalone Word plugin pkg with version
cp -f "packaging/Mathtype-kh-WordPlugin.pkg" "Mathtype-kh-WordPlugin-${TAG}.pkg"
cp -f "packaging/Mathtype-kh-WordPlugin.pkg" "word_plugin/Mathtype-kh-${TAG}.pkg"
cp -f "packaging/Mathtype-kh-WordPlugin.pkg" "word_plugin/Mathtype-kh.pkg"

# 6. Build distribution product package (All-in-One: App + Word Plugin)
echo "🎁 Building final distribution package (All-in-One: Mathtype-kh-${TAG}.pkg)..."
productbuild --distribution "packaging/distribution.xml" \
             --package-path "packaging" \
             --resources "packaging" \
             "Mathtype-kh-${TAG}.pkg"

cp -f "Mathtype-kh-${TAG}.pkg" "Mathtype-kh.pkg"

# 7. Build Uninstaller package (Remove_mathtype_kh-${TAG}.pkg)
echo "🗑️ Building Uninstaller package..."
mkdir -p packaging/uninstaller/root
pkgbuild --root "packaging/uninstaller/root" \
         --scripts "packaging/uninstaller/scripts" \
         --identifier "com.mathtype.kh.uninstaller" \
         --version "${VERSION}" \
         "packaging/uninstaller/Remove-Mathtype-kh-Component.pkg"

productbuild --distribution "packaging/uninstaller/distribution.xml" \
             --package-path "packaging/uninstaller" \
             --resources "packaging/uninstaller" \
             "Remove_mathtype_kh-${TAG}.pkg"

cp -f "Remove_mathtype_kh-${TAG}.pkg" "Remove_mathtype_kh.pkg"

# Clean up staging
rm -rf packaging/staging "packaging/Mathtype-kh-Component.pkg" "packaging/Mathtype-kh-WordPlugin.pkg" "packaging/uninstaller/Remove-Mathtype-kh-Component.pkg"

echo "=========================================="
echo "✅ Packaging Complete!"
echo "   Output Application Installer: Mathtype-kh-${TAG}.pkg & Mathtype-kh.pkg"
echo "   Output Word Plugin Installer: Mathtype-kh-WordPlugin-${TAG}.pkg & word_plugin/Mathtype-kh-${TAG}.pkg"
echo "   Output Uninstaller Package:   Remove_mathtype_kh-${TAG}.pkg & Remove_mathtype_kh.pkg"
echo "=========================================="
