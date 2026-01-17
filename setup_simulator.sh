#!/bin/bash

# LifeLab - Simulator Setup Script
# This helps you set up iOS Simulators for testing

set -e

echo "🔧 LifeLab - Simulator Setup"
echo "============================"
echo ""

# Check if Xcode is installed
check_xcode() {
    if ! command -v xcodebuild &> /dev/null; then
        echo "❌ Xcode not found!"
        echo ""
        echo "Please install Xcode:"
        echo "1. Open Mac App Store"
        echo "2. Search for 'Xcode'"
        echo "3. Install Xcode"
        echo ""
        exit 1
    fi
    
    echo "✅ Xcode found: $(xcodebuild -version | head -1)"
}

# Check for runtimes
check_runtimes() {
    echo "🔍 Checking iOS runtimes..."
    RUNTIMES=$(xcrun simctl list runtimes | grep -c "iOS" || echo "0")
    
    if [ "$RUNTIMES" -eq "0" ]; then
        echo "❌ No iOS runtimes found!"
        echo ""
        echo "You need to install an iOS Simulator runtime."
        echo ""
        echo "Option 1: Via Xcode (Easiest)"
        echo "1. Open Xcode"
        echo "2. Xcode > Settings (⌘,) > Platforms"
        echo "3. Click '+' next to iOS"
        echo "4. Download iOS 17.0 or latest"
        echo ""
        echo "Option 2: Via Command Line"
        echo "xcodebuild -downloadPlatform iOS"
        echo ""
        echo "After installing, run this script again."
        exit 1
    else
        echo "✅ Found iOS runtimes:"
        xcrun simctl list runtimes | grep iOS
    fi
}

# List available device types
list_device_types() {
    echo ""
    echo "📱 Available iPhone device types:"
    xcrun simctl list devicetypes | grep iPhone | head -10
}

# Create a simulator if none exist
create_simulator() {
    echo ""
    echo "🔨 Creating simulator..."
    
    # Get latest iOS runtime
    RUNTIME=$(xcrun simctl list runtimes | grep iOS | tail -1 | awk '{print $NF}' | tr -d '()')
    
    if [ -z "$RUNTIME" ]; then
        echo "❌ No iOS runtime available"
        exit 1
    fi
    
    echo "Using runtime: $RUNTIME"
    
    # Create iPhone 15 Pro simulator
    DEVICE_NAME="iPhone 15 Pro"
    DEVICE_TYPE="iPhone-15-Pro"
    
    echo "Creating: $DEVICE_NAME"
    xcrun simctl create "$DEVICE_NAME" "com.apple.CoreSimulator.SimDeviceType.$DEVICE_TYPE" "$RUNTIME" 2>/dev/null || {
        echo "⚠️  Simulator might already exist, checking..."
    }
    
    echo "✅ Simulator ready!"
}

# Main setup
main() {
    check_xcode
    check_runtimes
    list_device_types
    
    echo ""
    read -p "Create iPhone 15 Pro simulator? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        create_simulator
    fi
    
    echo ""
    echo "✅ Setup complete!"
    echo ""
    echo "Now you can run:"
    echo "  make run"
    echo "  or"
    echo "  ./test_without_xcode.sh run"
}

main
