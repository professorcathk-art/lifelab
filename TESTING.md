# Testing LifeLab Without Xcode GUI

This guide provides several alternatives to testing your iOS app without opening Xcode's GUI.

## Quick Start

### Option 1: Command Line Script (Easiest)

Use the provided script to build and run:

```bash
chmod +x test_without_xcode.sh
./test_without_xcode.sh run    # Build and run app
./test_without_xcode.sh test   # Run tests
./test_without_xcode.sh build  # Just build
```

## Testing Methods

### 1. Command Line Tools (Built-in)

Xcode Command Line Tools provide powerful testing capabilities:

#### Build Only
```bash
cd LifeLab
xcodebuild -project LifeLab.xcodeproj \
           -scheme LifeLab \
           -sdk iphonesimulator \
           clean build
```

#### Run on Simulator
```bash
# List available simulators
xcrun simctl list devices available

# Boot a simulator
xcrun simctl boot "iPhone 15 Pro"

# Build and install
xcodebuild -project LifeLab.xcodeproj \
           -scheme LifeLab \
           -sdk iphonesimulator \
           -derivedDataPath ./build

# Install the app
APP_PATH=$(find ./build -name "LifeLab.app" -type d | head -1)
xcrun simctl install booted "$APP_PATH"

# Launch the app
xcrun simctl launch booted com.yourname.LifeLab
```

#### Run Tests
```bash
xcodebuild test \
    -project LifeLab.xcodeproj \
    -scheme LifeLab \
    -sdk iphonesimulator \
    -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

### 2. Fastlane (Recommended for Automation)

Fastlane is a popular tool for iOS automation:

#### Installation
```bash
gem install fastlane
cd LifeLab
fastlane init
```

#### Basic Fastfile
Create `LifeLab/fastlane/Fastfile`:
```ruby
default_platform(:ios)

platform :ios do
  desc "Build the app"
  lane :build do
    build_app(
      workspace: "LifeLab.xcworkspace",
      scheme: "LifeLab"
    )
  end

  desc "Run tests"
  lane :test do
    run_tests(
      workspace: "LifeLab.xcworkspace",
      scheme: "LifeLab"
    )
  end

  desc "Build and run on simulator"
  lane :run do
    build_app(
      workspace: "LifeLab.xcworkspace",
      scheme: "LifeLab",
      destination: "platform=iOS Simulator,name=iPhone 15 Pro"
    )
  end
end
```

#### Usage
```bash
fastlane build
fastlane test
fastlane run
```

### 3. Swift Package Manager Testing

For unit testing individual components:

#### Create Test Package
```bash
mkdir LifeLabTests
cd LifeLabTests
swift package init --type executable
```

#### Run Tests
```bash
swift test
```

### 4. GitHub Actions CI/CD

Automated testing on every commit:

Create `.github/workflows/ios.yml`:
```yaml
name: iOS Tests

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: macos-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Select Xcode Version
      run: sudo xcode-select -s /Applications/Xcode.app
    
    - name: Build
      run: |
        cd LifeLab
        xcodebuild -project LifeLab.xcodeproj \
                   -scheme LifeLab \
                   -sdk iphonesimulator \
                   clean build
    
    - name: Test
      run: |
        cd LifeLab
        xcodebuild test \
          -project LifeLab.xcodeproj \
          -scheme LifeLab \
          -sdk iphonesimulator \
          -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

### 5. Swift REPL (Quick Code Testing)

For quick testing of Swift code snippets:

```bash
swift
# Then type your Swift code interactively
```

### 6. Swift Playgrounds (Limited)

For testing UI components in isolation:
- Create a `.playground` file
- Copy your SwiftUI view code
- Use Xcode's Playground (minimal GUI needed)

## Recommended Workflow

### Daily Development
1. **Use the script**: `./test_without_xcode.sh run`
2. **Check syntax**: `./test_without_xcode.sh check`
3. **Run tests**: `./test_without_xcode.sh test`

### Before Committing
```bash
./test_without_xcode.sh clean
./test_without_xcode.sh build
./test_without_xcode.sh test
```

### CI/CD Setup
Use GitHub Actions (see Option 4 above) for automated testing.

## Troubleshooting

### Simulator Not Found
```bash
# List all simulators
xcrun simctl list devices

# Create a new simulator
xcrun simctl create "iPhone 15 Pro" "iPhone 15 Pro" "iOS17.0"
```

### Build Errors
```bash
# Clean everything
./test_without_xcode.sh clean

# Check for syntax errors
./test_without_xcode.sh check
```

### Permission Issues
```bash
# Make script executable
chmod +x test_without_xcode.sh

# Ensure Xcode command line tools are installed
xcode-select --install
```

## Advantages Over Xcode GUI

✅ **Faster**: No GUI overhead  
✅ **Scriptable**: Automate your workflow  
✅ **CI/CD Ready**: Easy to integrate  
✅ **Less Resource Intensive**: Lower memory usage  
✅ **Reproducible**: Same commands every time  

## Limitations

⚠️ **No Visual Debugging**: Can't use breakpoints visually  
⚠️ **No Interface Builder**: Must edit code directly  
⚠️ **No Live Previews**: SwiftUI previews require Xcode  

## Tips

1. **Use VS Code** with Swift extensions for code editing
2. **Use Simulator.app** separately for visual testing
3. **Set up Fastlane** for complex workflows
4. **Use GitHub Actions** for automated testing

## Next Steps

1. Try the script: `./test_without_xcode.sh run`
2. Set up Fastlane for advanced automation
3. Configure GitHub Actions for CI/CD
4. Create unit tests for your ViewModels
