# How to Install iOS 26.3 Simulator

## Current Status
- **Your Xcode Version**: 26.2
- **Available Simulator**: iOS 26.2
- **Required for Testing**: iOS 26.3 (to match Apple's review devices)

## Option 1: Update Xcode to 26.3 (Recommended)

### Step 1: Download Xcode 26.3
1. Visit [Apple Developer Downloads](https://developer.apple.com/download/all/)
2. Sign in with your Apple Developer account
3. Search for "Xcode 26.3"
4. Download the latest version (or Release Candidate if available)

### Step 2: Install Xcode 26.3
- **Option A**: Install alongside existing Xcode (rename current to `Xcode-26.2.app`)
- **Option B**: Replace existing Xcode (backup first)

### Step 3: Verify Installation
```bash
xcodebuild -version
# Should show: Xcode 26.3

xcrun simctl list runtimes
# Should show: iOS 26.3
```

## Option 2: Install iOS 26.3 Runtime Only (If Available)

### Via Xcode Settings
1. Open Xcode
2. Go to **Xcode** → **Settings** (or **Preferences**)
3. Click **Components** tab
4. Look for **iOS 26.3** runtime
5. Click **Get** button to download

### Via Terminal
```bash
# Set Xcode as active developer toolchain
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer

# Download iOS 26.3 runtime (if available)
xcodebuild -downloadPlatform iOS -exportPath ~/Downloads

# Verify installation
xcrun simctl runtime list
```

## Option 3: Use iOS 26.2 for Testing (Temporary)

If iOS 26.3 is not yet available, you can test with iOS 26.2:

```bash
# List available devices
xcrun simctl list devices available

# Boot iPhone 17 Pro Max (closest to review device)
xcrun simctl boot "iPhone 17 Pro Max"

# Or boot iPad Air 11-inch (M3)
xcrun simctl boot "iPad Air 11-inch (M3)"
```

**Note**: Apple reviewers use iOS 26.3, but testing on iOS 26.2 should be sufficient for most compatibility checks.

## Quick Check Commands

```bash
# Check current Xcode version
xcodebuild -version

# Check available simulator runtimes
xcrun simctl list runtimes

# Check available devices
xcrun simctl list devices available

# Boot a specific device
xcrun simctl boot "iPhone 17 Pro Max"
```

## Testing Your App

Once iOS 26.3 is installed:

```bash
# Build and run on iOS 26.3 simulator
cd /Users/mickeylau/lifelab
xcodebuild -project LifeLab/LifeLab.xcodeproj \
  -scheme LifeLab \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max,OS=26.3' \
  build

# Or for iPad Air 11-inch (M3)
xcodebuild -project LifeLab/LifeLab.xcodeproj \
  -scheme LifeLab \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPad Air 11-inch (M3),OS=26.3' \
  build
```

## Important Notes

- **iOS 26.3 Runtime Size**: ~2-8 GB (download may take 20+ minutes)
- **Xcode Update**: Full Xcode update is ~10-15 GB
- **Compatibility**: iOS 26.2 testing should work for most cases, but iOS 26.3 matches Apple's review environment exactly

## If iOS 26.3 is Not Available Yet

If iOS 26.3 simulator runtime is not yet publicly available:
1. Test with iOS 26.2 (should be compatible)
2. Wait for Xcode 26.3 release
3. Apple reviewers will test on iOS 26.3 regardless

Your app should work on both iOS 26.2 and 26.3 since they're minor version differences.
