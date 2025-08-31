#!/bin/bash

# TypoZap Build Script
# This script builds and optionally runs the TypoZap macOS menu bar app

set -e

echo "🔤 Building TypoZap..."

# Check if Swift is available
if ! command -v swift &> /dev/null; then
    echo "❌ Swift is not installed. Please install Xcode Command Line Tools:"
    echo "   xcode-select --install"
    exit 1
fi

# Clean previous builds
echo "🧹 Cleaning previous builds..."
swift package clean

# Build the project
echo "🔨 Building project..."
swift build -c release

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    echo "📱 App location: .build/release/TypoZap"
    
    # Ask if user wants to run the app
    read -p "🚀 Would you like to run TypoZap now? (y/n): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🎯 Running TypoZap..."
        echo "⚠️  Note: You may need to grant accessibility permissions in System Preferences"
        echo "   System Preferences > Security & Privacy > Privacy > Accessibility"
        echo ""
        
        # Run the app
        .build/release/TypoZap
    else
        echo "📋 To run TypoZap later, use: .build/release/TypoZap"
    fi
else
    echo "❌ Build failed!"
    exit 1
fi
