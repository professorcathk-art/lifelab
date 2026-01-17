#!/bin/bash

# LifeLab - Fix Runtime Without Xcode GUI
# This tries to fix the iOS runtime issue via command line only

set -e

echo "🔧 Fixing iOS Runtime (No Xcode GUI Needed)"
echo "============================================"
echo ""

# Check if xcodebuild works
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ xcodebuild not found. Install Xcode Command Line Tools:"
    echo "   xcode-select --install"
    exit 1
fi

echo "✅ Xcode command line tools found"
echo ""

# Method 1: Download iOS platform
echo "📥 Method 1: Downloading iOS runtime..."
echo "   (This may take 10-30 minutes, downloading ~5-10GB)"
echo ""

# Start download in background and show progress
xcodebuild -downloadPlatform iOS 2>&1 | while IFS= read -r line; do
    echo "$line"
    if [[ "$line" == *"Downloaded"* ]] || [[ "$line" == *"Installed"* ]]; then
        echo "✅ Download complete!"
        break
    fi
done

# Wait a bit
sleep 2

# Check if runtime is now available
echo ""
echo "🔍 Checking available runtimes..."
RUNTIMES=$(xcrun simctl list runtimes 2>&1 | grep -c "iOS" || echo "0")

if [ "$RUNTIMES" -gt "0" ]; then
    echo "✅ iOS runtime found!"
    xcrun simctl list runtimes | grep iOS
    
    echo ""
    echo "🔨 Creating iPhone 15 Pro simulator..."
    
    # Get the iOS runtime identifier
    RUNTIME_ID=$(xcrun simctl list runtimes | grep iOS | tail -1 | awk '{print $NF}' | tr -d '()')
    
    if [ -z "$RUNTIME_ID" ]; then
        echo "⚠️  Could not determine runtime ID"
        echo "Available runtimes:"
        xcrun simctl list runtimes
        exit 1
    fi
    
    echo "Using runtime: $RUNTIME_ID"
    
    # Create simulator
    DEVICE_ID=$(xcrun simctl create "iPhone 15 Pro" \
        "com.apple.CoreSimulator.SimDeviceType.iPhone-15-Pro" \
        "$RUNTIME_ID" 2>&1)
    
    if [ $? -eq 0 ]; then
        echo "✅ Simulator created: $DEVICE_ID"
        echo ""
        echo "🎉 Success! Now you can run:"
        echo "   make run"
    else
        echo "❌ Failed to create simulator"
        echo "Error: $DEVICE_ID"
        echo ""
        echo "Try manually:"
        echo "   xcrun simctl list runtimes"
        echo "   xcrun simctl list devicetypes"
    fi
else
    echo "❌ No iOS runtime found after download attempt"
    echo ""
    echo "Troubleshooting:"
    echo "1. Check internet connection"
    echo "2. Try: xcodebuild -downloadAllPlatforms"
    echo "3. Or manually download via:"
    echo "   - Open Xcode"
    echo "   - Click device picker > Download more runtimes"
    echo ""
    echo "Alternative: Use Swift Playgrounds instead!"
fi
