#!/bin/bash

# TypoZap Installation Script
# This script builds and installs TypoZap to your Applications folder
# Updated to use proper app bundle structure

set -e

echo "🔤 Welcome to TypoZap Installation!"
echo "=================================="
echo ""

# Check if Swift is available
if ! command -v swift &> /dev/null; then
    echo "❌ Swift is not installed. Please install Xcode Command Line Tools:"
    echo "   xcode-select --install"
    echo ""
    echo "After installation, run this script again."
    exit 1
fi

echo "✅ Swift is available"
echo ""

# Build the project
echo "🔨 Building TypoZap..."
swift build -c release

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    echo ""
    
    # Create proper app bundle
    echo "📱 Creating app bundle..."
    
    # Create the app bundle directory
    APP_NAME="TypoZap.app"
    APP_BUNDLE="$APP_NAME"
    
    # Remove existing app bundle
    if [ -d "$APP_BUNDLE" ]; then
        rm -rf "$APP_BUNDLE"
    fi
    
    # Create app bundle structure
    mkdir -p "$APP_BUNDLE/Contents/MacOS"
    mkdir -p "$APP_BUNDLE/Contents/Resources"
    
    # Copy the executable
    cp .build/release/TypoZap "$APP_BUNDLE/Contents/MacOS/"
    
    # Copy the custom icons
    if [ -f "TypoZap.icns" ]; then
        cp TypoZap.icns "$APP_BUNDLE/Contents/Resources/"
        echo "✅ Main icon copied to app bundle"
    else
        echo "⚠️  TypoZap.icns not found, using default icon"
    fi
    
    if [ -f "loader.icns" ]; then
        cp loader.icns "$APP_BUNDLE/Contents/Resources/"
        echo "✅ Loader icon copied to app bundle"
    else
        echo "⚠️  loader.icns not found"
    fi
    
    if [ -f "completed.icns" ]; then
        cp completed.icns "$APP_BUNDLE/Contents/Resources/"
        echo "✅ Completed icon copied to app bundle"
    else
        echo "⚠️  completed.icns not found"
    fi
    
    # Copy tones.json
    if [ -f "tones.json" ]; then
        cp tones.json "$APP_BUNDLE/Contents/Resources/"
        echo "✅ tones.json copied to app bundle"
    else
        echo "⚠️  tones.json not found"
    fi
    
    # Create Info.plist
    cat > "$APP_BUNDLE/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>TypoZap</string>
    <key>CFBundleIconFile</key>
    <string>TypoZap.icns</string>
    <key>CFBundleIdentifier</key>
    <string>com.typozap.app</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>TypoZap</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.13</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
    <key>NSSupportsAutomaticTermination</key>
    <true/>
    <key>NSSupportsSuddenTermination</key>
    <true/>
</dict>
</plist>
EOF
    
    # Make the app bundle executable
    chmod +x "$APP_BUNDLE/Contents/MacOS/TypoZap"
    
    echo "✅ App bundle created: $APP_BUNDLE"
    echo ""
    
    # Check if Applications folder exists
    if [ -d "/Applications" ]; then
        echo "📱 Installing to Applications folder..."
        
        # Copy the app bundle to Applications
        if cp -R "$APP_BUNDLE" "/Applications/"; then
            echo "✅ TypoZap installed successfully to /Applications/$APP_NAME"
            echo ""
            echo "🎯 Next Steps:"
            echo "1. Open TypoZap from your Applications folder"
            echo "2. Grant accessibility permissions when prompted"
            echo "3. Enter your Gemini API key when prompted"
            echo "4. Start using with ⌥+T hotkey!"
            echo ""
            echo "📚 For detailed instructions, see README.md"
            echo ""
            
            # Ask if user wants to launch the app
            read -p "🚀 Would you like to launch TypoZap now? (y/n): " -n 1 -r
            echo
            
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                echo "🎯 Launching TypoZap..."
                open "/Applications/$APP_NAME"
            fi
        else
            echo "❌ Failed to install to Applications folder"
            echo "You can still run TypoZap from: $(pwd)/$APP_BUNDLE"
        fi
    else
        echo "⚠️  Applications folder not found"
        echo "You can run TypoZap from: $(pwd)/$APP_BUNDLE"
    fi
else
    echo "❌ Build failed!"
    exit 1
fi

echo ""
echo "🎉 Installation complete! Happy TypoZapping! ✨"
