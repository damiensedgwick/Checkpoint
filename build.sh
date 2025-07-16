#!/bin/bash

# Checkpoint Build Script
# This script helps build and run the Checkpoint app

set -e

echo "🏗️  Building Checkpoint..."

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Xcode is not installed or not in PATH"
    exit 1
fi

# Build the project
echo "📦 Building project..."
xcodebuild -project checkpoint.xcodeproj -scheme checkpoint -configuration Release build

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    echo ""
    echo "🎉 Checkpoint is ready to run!"
    echo "📱 The app will appear in your menu bar"
    echo ""
    echo "💡 Tips:"
    echo "   - Use ⌘T to start a timer"
    echo "   - Use ⌘L to log work"
    echo "   - Use ⌘V to view logs"
    echo "   - Use ⌘, to open settings"
else
    echo "❌ Build failed!"
    exit 1
fi 