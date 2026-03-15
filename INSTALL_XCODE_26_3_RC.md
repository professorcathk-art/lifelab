# Installing Xcode 26.3 Release Candidate

## Pre-Installation Checklist

### Step 1: Backup Current Xcode (Optional but Recommended)
```bash
# Rename current Xcode to keep both versions
sudo mv /Applications/Xcode.app /Applications/Xcode-26.2.app

# Or create a backup
sudo cp -R /Applications/Xcode.app /Applications/Xcode-26.2-backup.app
```

### Step 2: Download Xcode 26.3 RC
- File: `Xcode 26.3 Release Candidate Apple silicon.xip`
- Size: ~10-15 GB
- Download from: Apple Developer Portal

### Step 3: Install Xcode 26.3 RC
```bash
# Extract the .xip file (double-click in Finder, or use command line)
cd ~/Downloads
xip -x Xcode_26.3_RC.xip

# Move to Applications folder
sudo mv Xcode.app /Applications/Xcode-26.3-RC.app

# Or replace existing (if you backed it up)
sudo mv Xcode.app /Applications/Xcode.app
```

### Step 4: Set Active Xcode Version
```bash
# Switch to Xcode 26.3 RC
sudo xcode-select -s /Applications/Xcode-26.3-RC.app/Contents/Developer

# Or if you replaced the main Xcode
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer

# Verify
xcodebuild -version
# Should show: Xcode 26.3
```

### Step 5: Accept License and Install Components
```bash
sudo xcodebuild -runFirstLaunch
```

### Step 6: Verify iOS 26.3 Simulator
```bash
# Check available runtimes
xcrun simctl list runtimes
# Should show: iOS 26.3

# Check available devices
xcrun simctl list devices available
# Should show devices with iOS 26.3
```

## Using Both Xcode Versions (If You Kept Both)

If you kept both versions:

```bash
# Switch to Xcode 26.2
sudo xcode-select -s /Applications/Xcode-26.2.app/Contents/Developer

# Switch to Xcode 26.3 RC
sudo xcode-select -s /Applications/Xcode-26.3-RC.app/Contents/Developer
```

## Testing Your App on iOS 26.3

```bash
cd /Users/mickeylau/lifelab

# Build for iOS 26.3 simulator
xcodebuild -project LifeLab/LifeLab.xcodeproj \
  -scheme LifeLab \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max,OS=26.3' \
  build

# Or test on iPad Air 11-inch (M3) - matches Apple review device
xcodebuild -project LifeLab/LifeLab.xcodeproj \
  -scheme LifeLab \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPad Air 11-inch (M3),OS=26.3' \
  build
```

## Important Notes

⚠️ **Release Candidate**: This is not the final release, but it's stable enough for testing.

✅ **Benefits**:
- Exact match with Apple's review environment
- iOS 26.3 simulator included
- Latest features and bug fixes

📝 **When Final Version Releases**:
- You can update to final version later
- Or keep RC until final is available

## Quick Verification Commands

```bash
# Check Xcode version
xcodebuild -version

# Check active Xcode path
xcode-select -p

# List simulator runtimes
xcrun simctl list runtimes

# List available devices
xcrun simctl list devices available | grep "iOS 26.3"
```
