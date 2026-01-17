# How to Use `make run` - Step by Step Guide

## 🚀 Quick Start

### First Time Setup (If No Simulators)

**You need to set up simulators first:**

```bash
# Run the setup script
./setup_simulator.sh
```

**Or manually:**
1. Open Xcode (just once)
2. Xcode > Settings (⌘,) > Platforms
3. Download iOS Simulator runtime
4. Close Xcode

### Then Run Your App

```bash
make run
```

This will:
1. ✅ Boot the iOS Simulator
2. ✅ Build your app
3. ✅ Install it on the simulator
4. ✅ Launch it automatically
5. ✅ Show you the UI!

## 📋 Prerequisites

Before running `make run`, make sure you have:

### 1. Xcode Installed
```bash
# Check if Xcode is installed
xcodebuild -version
```

If not installed:
- Download from Mac App Store
- Or install Xcode Command Line Tools: `xcode-select --install`

### 2. iOS Simulators Available

**First time setup** (if no simulators):
1. Open Xcode (just once, to set up simulators)
2. Xcode > Settings > Platforms
3. Download iOS Simulator (if needed)
4. Or: Xcode > Window > Devices and Simulators > Simulators > + (add simulator)

**Check available simulators:**
```bash
make list-simulators
# Or
xcrun simctl list devices available
```

### 3. Project Structure

Make sure you're in the project root:
```bash
cd /Users/mickeylau/lifelab
```

## 🎯 Step-by-Step: Running Your App

### Step 1: Navigate to Project
```bash
cd /Users/mickeylau/lifelab
```

### Step 2: Check Available Simulators
```bash
make list-simulators
```

**If no simulators found:**
- Open Xcode once to initialize simulators
- Or install via: Xcode > Settings > Platforms > iOS

### Step 3: Run the App!
```bash
make run
```

**What happens:**
1. 🔌 Simulator boots (iPhone 15 Pro)
2. 🔨 Project builds
3. 📱 App installs on simulator
4. ▶️  App launches automatically
5. 🎉 You see your UI!

### Step 4: See Your App!

The Simulator window will open showing:
- Your LifeLab app
- InitialScanView (興趣選擇)
- All your UI working!

## 🔧 Troubleshooting

### Problem: "Simulator not found"

**Solution:**
```bash
# List all simulators
xcrun simctl list devices

# If empty, open Xcode once to set up simulators
open -a Xcode
# Then: Xcode > Window > Devices and Simulators
# Add a simulator if needed
```

### Problem: "Build failed"

**Solution:**
```bash
# Clean and try again
make clean
make run
```

### Problem: "Permission denied"

**Solution:**
```bash
# Make sure Makefile is executable (it should be)
# Check if you're in the right directory
pwd
# Should show: /Users/mickeylau/lifelab
```

### Problem: "Scheme not found"

**Solution:**
- Make sure Xcode project exists: `LifeLab/LifeLab.xcodeproj`
- Open project in Xcode once to verify it's valid

## 📱 Alternative: Use the Script

If `make` doesn't work, use the bash script:

```bash
./test_without_xcode.sh run
```

## 🎬 What You'll See

When `make run` succeeds:

```
🔌 Booting simulator: iPhone 15 Pro...
✅ Simulator ready
📲 Building and running app...
🔨 Building project...
📱 Installing app...
▶️  Launching app...
✅ App launched
```

Then the Simulator window opens with your app running!

## 💡 Tips

1. **First time?** Open Xcode once to set up simulators
2. **Simulator too slow?** Try a different device: Edit `SIMULATOR` in Makefile
3. **Want to see logs?** Check Console.app or Xcode's device console
4. **Close simulator?** `xcrun simctl shutdown all`

## 🎯 Common Commands

```bash
make run              # Build and run (what you want!)
make build            # Just build, don't run
make clean            # Clean build files
make list-simulators  # See available simulators
make check            # Check for syntax errors
```

## ✅ Ready to Go?

Just run:
```bash
make run
```

That's it! Your app will appear in the Simulator. 🎉
