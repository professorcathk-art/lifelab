#!/bin/bash

# LifeLab - Install iOS Runtime Script
# This downloads and installs the iOS Simulator runtime

set -e

echo "📥 Installing iOS Simulator Runtime"
echo "===================================="
echo ""
echo "This will download the iOS runtime (may take a while)..."
echo ""

# Method 1: Try xcodebuild download
echo "Method 1: Using xcodebuild..."
if xcodebuild -downloadPlatform iOS; then
    echo "✅ iOS runtime installed!"
    exit 0
fi

echo ""
echo "⚠️  Method 1 didn't work, trying alternative..."
echo ""

# Method 2: Check available runtimes
echo "Available runtimes to download:"
xcodebuild -downloadAllPlatforms 2>&1 | head -20 || echo "Checking..."

echo ""
echo "If download didn't start automatically, try:"
echo "1. Open Xcode"
echo "2. Click the device picker at the top (where you see 'iOS 26.2 not installed')"
echo "3. Click 'Download more simulator runtimes...'"
echo "4. Or go to: Xcode > Settings > Components (not Platforms)"
echo ""
