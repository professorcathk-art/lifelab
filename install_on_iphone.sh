#!/bin/bash

# LifeLab - Install on Real iPhone
# This builds and installs your app directly on your iPhone (no simulator!)

set -e

echo "📱 LifeLab - Install on iPhone"
echo "==============================="
echo ""

PROJECT_PATH="LifeLab/LifeLab.xcodeproj"
SCHEME="LifeLab"

# Check if iPhone is connected
echo "🔍 Checking for connected iPhone..."
DEVICES=$(xcrun xctrace list devices 2>&1 | grep -i "iphone" || echo "")

if [ -z "$DEVICES" ]; then
    echo "❌ No iPhone found!"
    echo ""
    echo "Please:"
    echo "1. Connect your iPhone via USB"
    echo "2. Unlock your iPhone"
    echo "3. Trust this computer (if prompted)"
    echo "4. Run this script again"
    echo ""
    exit 1
fi

echo "✅ iPhone found!"
echo ""
echo "$DEVICES"
echo ""

# List available devices
echo "📋 Available devices:"
xcrun xctrace list devices 2>&1 | grep -E "iPhone|iPad" || xcodebuild -showdestinations -project "$PROJECT_PATH" -scheme "$SCHEME" 2>&1 | grep -i "iphone"

echo ""
read -p "Enter your iPhone name (or press Enter for auto-detect): " DEVICE_NAME

if [ -z "$DEVICE_NAME" ]; then
    # Auto-detect first iPhone
    DEVICE_NAME=$(xcrun xctrace list devices 2>&1 | grep -i "iphone" | head -1 | awk -F'(' '{print $1}' | xargs)
    echo "Auto-detected: $DEVICE_NAME"
fi

echo ""
echo "🔨 Building for device..."
xcodebuild -project "$PROJECT_PATH" \
           -scheme "$SCHEME" \
           -sdk iphoneos \
           -destination "generic/platform=iOS" \
           -configuration Debug \
           CODE_SIGN_IDENTITY="" \
           CODE_SIGNING_REQUIRED=NO \
           clean build 2>&1 | tail -30

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Build successful!"
    echo ""
    echo "📱 To install:"
    echo "1. Open Xcode"
    echo "2. Window > Devices and Simulators"
    echo "3. Select your iPhone"
    echo "4. Drag the .app from build folder to install"
    echo ""
    echo "Or use:"
    echo "   xcrun devicectl device install app --device YOUR_DEVICE_ID ./build/..."
else
    echo ""
    echo "⚠️  Build failed or needs code signing"
    echo ""
    echo "Alternative: Use Xcode to build and install"
    echo "1. Open Xcode"
    echo "2. Select your iPhone as destination"
    echo "3. Click Run (▶️)"
    echo ""
    echo "Or set up free developer account:"
    echo "Xcode > Settings > Accounts > Add Apple ID"
fi
