# Quick Testing Reference

## 🚀 Fastest Way to Test

```bash
# Build and run app
./test_without_xcode.sh run

# Or using Make
make run
```

## 📋 All Commands

### Using the Script
```bash
./test_without_xcode.sh run      # Build and run
./test_without_xcode.sh test     # Run tests
./test_without_xcode.sh build    # Build only
./test_without_xcode.sh clean    # Clean build
./test_without_xcode.sh list     # List simulators
./test_without_xcode.sh check    # Check syntax
```

### Using Make
```bash
make run              # Build and run
make test             # Run tests
make build            # Build only
make clean            # Clean build
make list-simulators # List simulators
make check            # Check syntax
```

### Direct Command Line
```bash
# Build
xcodebuild -project LifeLab/LifeLab.xcodeproj \
           -scheme LifeLab \
           -sdk iphonesimulator \
           clean build

# Run on simulator
xcrun simctl list devices
xcrun simctl boot "iPhone 15 Pro"
# Then install and launch app
```

## 🎯 Common Workflows

### Daily Development
```bash
make run    # Quick test
```

### Before Committing
```bash
make clean
make build
make test
```

### Check for Errors
```bash
make check
```

## 📱 Simulator Management

```bash
# List all simulators
xcrun simctl list devices

# Boot specific simulator
xcrun simctl boot "iPhone 15 Pro"

# Open Simulator app
open -a Simulator

# Shutdown simulator
xcrun simctl shutdown all
```

## 🔧 Troubleshooting

**Simulator not found?**
```bash
make list-simulators
# Then update SIMULATOR in Makefile or script
```

**Build fails?**
```bash
make clean
make build
```

**Permission denied?**
```bash
chmod +x test_without_xcode.sh
```

## 📱 See UI on Real Device (TestFlight)

**TestFlight shows the full UI on real iPhones/iPads!**

```bash
# Build for TestFlight
./setup_testflight.sh archive

# Then upload via Xcode Organizer
# Testers install via TestFlight app
# They see YOUR full UI! 🎉
```

See [TESTFLIGHT_EXPLAINED.md](TESTFLIGHT_EXPLAINED.md) for details.

## 📚 More Info

- Full guide: [TESTING.md](TESTING.md)
- Setup guide: [SETUP.md](SETUP.md)
- TestFlight guide: [TESTFLIGHT_EXPLAINED.md](TESTFLIGHT_EXPLAINED.md)
- SwiftUI alternatives: [SWIFTUI_TESTING_ALTERNATIVES.md](SWIFTUI_TESTING_ALTERNATIVES.md)
