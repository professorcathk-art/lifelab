# Fix Xcode 26.3 Installation

## Current Status
✅ Xcode 26.3 is installed in `/Applications/Xcode.app`
✅ Command line tools are working (`xcodebuild -version` shows 26.3)
⚠️ Simulator runtimes still show iOS 26.2 (need to install iOS 26.3 runtime)

## Steps to Complete Installation

### Step 1: Accept Xcode License
Open Terminal and run:
```bash
sudo xcodebuild -license accept
```
(Enter your Mac password when prompted)

### Step 2: Run First Launch Setup
This installs simulator components:
```bash
sudo xcodebuild -runFirstLaunch
```
(Enter your Mac password when prompted)

### Step 3: Open Xcode GUI to Complete Setup
1. Open **Finder**
2. Go to **Applications**
3. Double-click **Xcode.app**
4. If prompted:
   - Click **"Get Started"**
   - Accept any agreements
   - Wait for "Installing Components" to complete
   - This may take 10-20 minutes

### Step 4: Verify iOS 26.3 Simulator is Installed
After setup completes, check:
```bash
xcrun simctl list runtimes
```
Should show: `iOS 26.3`

### Step 5: Clean Up Downloads Folder (Optional)
If you have a duplicate Xcode.app in Downloads:
```bash
# Check size first
du -sh ~/Downloads/Xcode.app

# If it's smaller or incomplete, remove it
rm -rf ~/Downloads/Xcode.app
```

## If Xcode Won't Launch

### Option A: Launch from Terminal
```bash
open /Applications/Xcode.app
```

### Option B: Reset Xcode Preferences
```bash
# Close Xcode first, then:
rm -rf ~/Library/Preferences/com.apple.dt.Xcode.plist
rm -rf ~/Library/Developer/Xcode/DerivedData/*
```

### Option C: Check System Requirements
- macOS version compatibility
- Available disk space (need ~15GB free)

## Quick Test
After completing setup, test your app:
```bash
cd /Users/mickeylau/lifelab
xcodebuild -project LifeLab/LifeLab.xcodeproj -scheme LifeLab -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' build
```

## If Still Having Issues
1. Check Xcode version: `xcodebuild -version`
2. Check active path: `xcode-select -p`
3. Try switching: `sudo xcode-select -s /Applications/Xcode.app/Contents/Developer`
4. Check disk space: `df -h`
