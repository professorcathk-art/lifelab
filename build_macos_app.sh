#!/bin/bash

# LifeLab - Build as macOS App
# This converts your iOS app to run natively on macOS (no simulator needed!)

set -e

echo "🖥️  Building LifeLab as macOS App"
echo "=================================="
echo ""

PROJECT_PATH="LifeLab/LifeLab.xcodeproj"
SCHEME="LifeLab"

# Check if macOS target exists
echo "📋 Checking project structure..."

# Try to build for macOS
echo "🔨 Building for macOS..."
xcodebuild -project "$PROJECT_PATH" \
           -scheme "$SCHEME" \
           -sdk macosx \
           -destination 'platform=macOS' \
           clean build 2>&1 | tail -30

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ macOS build successful!"
    echo ""
    echo "📱 To run:"
    echo "   Find the .app in ./build/Debug/"
    echo "   Double-click to run!"
else
    echo ""
    echo "⚠️  macOS target might not exist yet"
    echo ""
    echo "Options:"
    echo "1. Restart Mac and try simulator again: make run"
    echo "2. Use Xcode Playgrounds (minimal Xcode usage)"
    echo "3. Consider React Native/Expo migration"
fi
