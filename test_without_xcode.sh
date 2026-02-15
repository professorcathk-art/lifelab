#!/bin/bash

# LifeLab - Command Line Testing Script
# This script allows you to build, test, and run your iOS app without opening Xcode GUI

set -e

PROJECT_PATH="LifeLab/LifeLab.xcodeproj"
SCHEME="LifeLab"
SIMULATOR_NAME="iPhone 15 Pro"
SIMULATOR_OS="iOS 17.0"

echo "🚀 LifeLab - Command Line Testing"
echo "=================================="
echo ""

# Function to list available simulators
list_simulators() {
    echo "📱 Available iOS Simulators:"
    xcrun simctl list devices available | grep -E "iPhone|iPad" | head -10
    echo ""
}

# Function to boot simulator
boot_simulator() {
    echo "🔌 Booting simulator: $SIMULATOR_NAME..."
    DEVICE_ID=$(xcrun simctl list devices available | grep "$SIMULATOR_NAME" | grep -oE '[A-F0-9-]{36}' | head -1)
    
    if [ -z "$DEVICE_ID" ]; then
        echo "❌ Simulator not found. Listing available simulators..."
        list_simulators
        exit 1
    fi
    
    xcrun simctl boot "$DEVICE_ID" 2>/dev/null || echo "Simulator already booted"
    open -a Simulator
    sleep 3
    echo "✅ Simulator ready"
}

# Function to build the project
build_project() {
    echo "🔨 Building project..."
    xcodebuild \
        -project "$PROJECT_PATH" \
        -scheme "$SCHEME" \
        -sdk iphonesimulator \
        -destination "platform=iOS Simulator,name=$SIMULATOR_NAME" \
        clean build
    
    if [ $? -eq 0 ]; then
        echo "✅ Build successful"
    else
        echo "❌ Build failed"
        exit 1
    fi
}

# Function to run tests
run_tests() {
    echo "🧪 Running tests..."
    xcodebuild test \
        -project "$PROJECT_PATH" \
        -scheme "$SCHEME" \
        -sdk iphonesimulator \
        -destination "platform=iOS Simulator,name=$SIMULATOR_NAME" \
        -only-testing:LifeLabTests
    
    if [ $? -eq 0 ]; then
        echo "✅ All tests passed"
    else
        echo "❌ Some tests failed"
        exit 1
    fi
}

# Function to install and run app
run_app() {
    echo "📲 Installing app on simulator..."
    
    DEVICE_ID=$(xcrun simctl list devices available | grep "$SIMULATOR_NAME" | grep -oE '[A-F0-9-]{36}' | head -1)
    
    if [ -z "$DEVICE_ID" ]; then
        echo "❌ Simulator not found"
        exit 1
    fi
    
    # Build and install
    xcodebuild \
        -project "$PROJECT_PATH" \
        -scheme "$SCHEME" \
        -sdk iphonesimulator \
        -destination "platform=iOS Simulator,id=$DEVICE_ID" \
        -derivedDataPath ./build
    
    # Find the built app
    APP_PATH=$(find ./build -name "LifeLab.app" -type d | head -1)
    
    if [ -z "$APP_PATH" ]; then
        echo "❌ App not found in build directory"
        exit 1
    fi
    
    echo "📱 Installing app..."
    xcrun simctl install "$DEVICE_ID" "$APP_PATH"
    
    echo "▶️  Launching app..."
    xcrun simctl launch "$DEVICE_ID" com.resonance.lifelab
    
    echo "✅ App launched"
}

# Function to clean build
clean_build() {
    echo "🧹 Cleaning build artifacts..."
    xcodebuild clean \
        -project "$PROJECT_PATH" \
        -scheme "$SCHEME"
    rm -rf ./build
    echo "✅ Clean complete"
}

# Function to check syntax
check_syntax() {
    echo "🔍 Checking Swift syntax..."
    find LifeLab/LifeLab -name "*.swift" -type f | while read file; do
        swiftc -typecheck "$file" 2>&1 | grep -v "error:" || echo "✅ $file"
    done
}

# Main menu
case "${1:-menu}" in
    list)
        list_simulators
        ;;
    boot)
        boot_simulator
        ;;
    build)
        build_project
        ;;
    test)
        boot_simulator
        run_tests
        ;;
    run)
        boot_simulator
        build_project
        run_app
        ;;
    clean)
        clean_build
        ;;
    check)
        check_syntax
        ;;
    menu|*)
        echo "Usage: $0 [command]"
        echo ""
        echo "Commands:"
        echo "  list    - List available simulators"
        echo "  boot    - Boot iOS simulator"
        echo "  build   - Build the project"
        echo "  test    - Run unit tests"
        echo "  run     - Build and run app on simulator"
        echo "  clean   - Clean build artifacts"
        echo "  check   - Check Swift syntax"
        echo ""
        echo "Examples:"
        echo "  $0 run      # Build and run app"
        echo "  $0 test    # Run tests"
        echo "  $0 build   # Just build"
        ;;
esac
