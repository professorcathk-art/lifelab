# How to Install iOS Simulator Runtime

## 🎯 The Problem

You see "iOS 26.2 not installed" at the top of Xcode. This means you need to download the iOS Simulator runtime.

## ✅ Solution: 3 Ways to Install

### Method 1: Click the Device Picker (Easiest!)

**In Xcode:**
1. Look at the **top toolbar** where you see the device picker (Mac icon with "iOS 26.2 not installed")
2. **Click on that device picker** (the dropdown)
3. You should see an option like **"Download more simulator runtimes..."** or **"Get Started"**
4. Click it and follow the prompts to download

### Method 2: Xcode Settings > Components

**In Xcode:**
1. **Xcode > Settings** (⌘,)
2. Click **"Components"** tab (NOT Platforms - that's old)
3. You'll see a list of available runtimes
4. Click the **download button** (⬇️) next to iOS 17.0 or iOS 18.0
5. Wait for download to complete

### Method 3: Command Line

```bash
# Try this command
xcodebuild -downloadPlatform iOS

# Or download all platforms
xcodebuild -downloadAllPlatforms
```

**Note:** This might take a while (several GB download)

## 🔍 Where to Find It in Xcode

**The device picker is at the top:**
```
[Mac] [iOS 26.2 not installed] [Play Button]
  ↑
Click here!
```

**Or in Settings:**
```
Xcode > Settings (⌘,) > Components tab
```

## ⏱️ How Long Does It Take?

- **Download size:** ~5-10 GB
- **Time:** 10-30 minutes (depends on internet speed)
- **You can keep using Xcode** while it downloads

## ✅ After Installation

Once installed, you'll see:
- Device picker shows available simulators
- "iOS 26.2 not installed" disappears
- You can run `make run` from command line!

## 🚀 Quick Test

After installation, test it:
```bash
make list-simulators
```

You should see available iPhone simulators!

## 💡 Pro Tip

If you're not sure which iOS version to download:
- **iOS 17.0** - Good for most testing
- **Latest version** - Best for newest features

You only need ONE iOS runtime, not all of them!
