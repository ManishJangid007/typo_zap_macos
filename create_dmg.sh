#!/bin/bash

# TypoZap DMG Creation Script
# Creates a reliable DMG installer for GitHub releases

set -e

echo "🔤 Creating TypoZap DMG Installer..."
echo "===================================="
echo ""

# Configuration
APP_NAME="TypoZap"
VERSION="1.1.0"
DMG_NAME="TypoZap-${VERSION}.dmg"
DMG_DIR="dmg_build"
APP_PATH="/Applications/${APP_NAME}.app"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're running from the right directory
if [ ! -f "Package.swift" ]; then
    print_error "Please run this script from the TypoZap project root directory"
    exit 1
fi

# Check if app exists in Applications
if [ ! -d "$APP_PATH" ]; then
    print_warning "App not found in Applications folder. Building and installing first..."
    ./install.sh
fi

# Clean up previous builds
print_status "Cleaning up previous builds..."
rm -rf "$DMG_DIR"
rm -f "$DMG_NAME"

# Create DMG directory structure
print_status "Creating DMG directory structure..."
mkdir -p "$DMG_DIR"

# Copy the app to DMG directory
print_status "Copying app to DMG directory..."
cp -R "$APP_PATH" "$DMG_DIR/"

# Create a comprehensive installer script
print_status "Creating installer script..."
cat > "$DMG_DIR/Install TypoZap.command" << 'EOF'
#!/bin/bash

# TypoZap Installation Script
# This script installs TypoZap to your Applications folder

echo "🔤 Installing TypoZap v1.1.0..."
echo "================================"
echo ""

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
APP_NAME="TypoZap.app"
SOURCE_APP="$SCRIPT_DIR/$APP_NAME"
DEST_APP="/Applications/$APP_NAME"

# Check if source app exists
if [ ! -d "$SOURCE_APP" ]; then
    echo "❌ Error: TypoZap.app not found in the same directory as this script"
    echo "Please make sure you're running this from the DMG mount point"
    exit 1
fi

# Check if destination already exists
if [ -d "$DEST_APP" ]; then
    echo "⚠️  TypoZap is already installed. Removing old version..."
    rm -rf "$DEST_APP"
fi

# Copy the app to Applications
echo "📱 Installing TypoZap to Applications folder..."
if cp -R "$SOURCE_APP" "$DEST_APP"; then
    echo "✅ TypoZap installed successfully!"
    echo ""
    echo "🎯 Next Steps:"
    echo "1. Open TypoZap from your Applications folder"
    echo "2. Grant accessibility permissions when prompted"
    echo "3. Enter your Gemini API key when prompted"
    echo "4. Start using with ⌥+T hotkey!"
    echo ""
    echo "🎭 NEW FEATURES in v1.1.0:"
    echo "• Tone Selection: Choose from 5 different writing styles"
    echo "• Enhanced UI: Better menu bar interface"
    echo "• Right-click menu bar icon to change tone"
    echo ""
    echo "📚 For detailed instructions, see README.txt"
    echo ""
    
    # Ask if user wants to launch the app
    read -p "🚀 Would you like to launch TypoZap now? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🎯 Launching TypoZap..."
        open "$DEST_APP"
    fi
else
    echo "❌ Failed to install TypoZap"
    echo "Please try running this script with administrator privileges:"
    echo "sudo ./Install\\ TypoZap.command"
    exit 1
fi

echo ""
echo "🎉 Installation complete! Happy TypoZapping! ✨"
echo ""
echo "Press any key to close this window..."
read -n 1
EOF

# Make the installer script executable
chmod +x "$DMG_DIR/Install TypoZap.command"

# Create a comprehensive README file for the DMG
print_status "Creating README for DMG..."
cat > "$DMG_DIR/README.txt" << 'EOF'
TypoZap v1.1.0 - AI-Powered Grammar Correction
=============================================

🎉 NEW FEATURES IN v1.1.0:
- 🎭 Tone Selection: Choose from 5 different writing styles
- ✨ Enhanced UI: Better menu bar interface with tone descriptions
- 🔒 Improved Security: Better API key management
- 📱 Better Installation: Effortless DMG installation

INSTALLATION:
1. Double-click "Install TypoZap.command"
2. Follow the on-screen instructions
3. Grant accessibility permissions when prompted
4. Enter your Gemini API key

USAGE:
1. Select text in any application
2. Press ⌥+T (Option+T) to correct
3. Right-click menu bar icon to change tone

TONES AVAILABLE:
- Default: Standard grammar correction
- Polite: Professional and courteous tone
- Aggressive: Direct and assertive tone
- Sarcastic: Witty and humorous tone
- Funny: Playful and light-hearted tone

REQUIREMENTS:
- macOS 13.0 or later
- Gemini API key from https://ai.google.dev/gemini-api

TROUBLESHOOTING:
- If installation fails, try running with: sudo ./Install\ TypoZap.command
- Make sure to grant accessibility permissions in System Preferences
- Check that your Gemini API key is valid

SUPPORT:
- GitHub: https://github.com/yourusername/typo_zap
- Issues: Please report bugs on GitHub

Made with ❤️ for macOS users who want perfect grammar!
EOF

# Create a symlink to Applications folder for easy drag-and-drop
print_status "Creating Applications symlink..."
ln -s /Applications "$DMG_DIR/Applications"

# Set proper permissions
print_status "Setting proper permissions..."
chmod -R 755 "$DMG_DIR"
chmod +x "$DMG_DIR/Install TypoZap.command"

# Create the DMG using hdiutil
print_status "Creating DMG file..."
hdiutil create -srcfolder "$DMG_DIR" -volname "TypoZap v${VERSION}" -format UDZO -imagekey zlib-level=9 -o "$DMG_NAME"

# Clean up
print_status "Cleaning up temporary files..."
rm -rf "$DMG_DIR"

# Get file size
FILE_SIZE=$(du -h "$DMG_NAME" | cut -f1)

print_success "DMG created successfully!"
print_success "File: $DMG_NAME"
print_success "Size: $FILE_SIZE"
print_success "Location: $(pwd)/$DMG_NAME"
echo ""
print_status "The DMG includes:"
echo "  ✅ TypoZap.app with tone selection feature"
echo "  ✅ Easy installer script"
echo "  ✅ Comprehensive README with instructions"
echo "  ✅ Applications folder shortcut"
echo ""
print_status "Ready for GitHub release! 🚀"