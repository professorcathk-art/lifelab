# LifeLab - Quick Testing Guide

## 🚀 Fastest Way to Test Your App

### Method 1: Using Make (Easiest)

```bash
cd /Users/mickeylau/lifelab
make run
```

This will:
1. ✅ Boot the iOS Simulator (iPhone 15 Pro)
2. ✅ Build your app
3. ✅ Install it on the simulator
4. ✅ Launch it automatically

### Method 2: Using Xcode (If GUI Works)

1. Open Xcode
2. Open project: `LifeLab/LifeLab.xcodeproj`
3. Select simulator: iPhone 17 Pro Max (or any available simulator)
4. Click Run button (▶️) or press `⌘R`

### Method 3: Command Line (More Control)

```bash
cd /Users/mickeylau/lifelab

# List available simulators
make list-simulators

# Build and run on specific simulator
xcodebuild -project LifeLab/LifeLab.xcodeproj \
           -scheme LifeLab \
           -sdk iphonesimulator \
           -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' \
           build

# Then install and launch manually
```

## 📱 Available Simulators

You have these simulators available:
- iPhone 17 Pro Max ✅ (Recommended - largest screen)
- iPhone 17 Pro
- iPhone 17
- iPhone Air
- iPad Pro 13-inch (M5)
- iPad Pro 11-inch (M5)

## 🎯 Testing Your New Feature

To test the **multiple version generation** feature:

1. **Run the app**: `make run`
2. **Complete Initial Scan**:
   - Select interests
   - Complete strengths questionnaire
   - Rank values
   - Generate Version 1 blueprint
3. **Go to Deepening Exploration**:
   - Complete flow diary (3 entries)
   - Complete values questions
   - Complete resource inventory
   - Complete acquired strengths
   - Complete feasibility assessment
4. **Test Version Generation**:
   - Click "生成更新版生命藍圖 (Version 3)" button
   - Wait for generation
   - Click again to generate Version 4
   - Click again to generate Version 5
   - Each time should create a new version!
5. **Check Profile View**:
   - Go to "個人檔案" tab
   - Scroll to "生命藍圖" section
   - You should see all versions (Version 1, 2, 3, 4, 5...)
   - Each version should have unique content from AI

## 🔍 Viewing Console Logs

To see AI generation logs and verify it's working:

### Option 1: Xcode Console
1. Open Xcode
2. Run app from Xcode
3. View console at bottom (⌘⇧Y)

### Option 2: Terminal Console
```bash
# View simulator logs
xcrun simctl spawn booted log stream --predicate 'processImagePath contains "LifeLab"'
```

### Option 3: Console.app
1. Open Console.app (Applications > Utilities)
2. Select your simulator device
3. Filter by "LifeLab"

## 🐛 Troubleshooting

### Simulator Not Found
```bash
# Check available simulators
make list-simulators

# If Makefile uses wrong simulator, update it:
# Edit Makefile, change SIMULATOR = "iPhone 15 Pro" to SIMULATOR = "iPhone 17 Pro Max"
```

### Build Fails
```bash
# Clean and rebuild
make clean
make run
```

### App Doesn't Launch
```bash
# Manually boot simulator first
make boot-simulator

# Then try again
make run
```

### Can't See AI Logs
- Make sure you're viewing the console while generating blueprints
- Look for logs starting with:
  - `🔵 Making API request...`
  - `✅ Successfully received response...`
  - `✅ Saving Version X blueprint...`

## ✅ Quick Test Checklist

- [ ] App launches successfully
- [ ] Can complete initial scan
- [ ] Version 1 blueprint generates
- [ ] Can complete deepening exploration
- [ ] Can generate Version 3, 4, 5... (multiple times)
- [ ] All versions appear in Profile View
- [ ] Each version has unique AI-generated content
- [ ] Console shows AI API calls and responses

## 📝 Common Commands

```bash
make run              # Build and run app
make build            # Just build (don't run)
make clean            # Clean build files
make list-simulators  # See available simulators
make check            # Check Swift syntax
```

---

**Ready to test?** Just run:
```bash
cd /Users/mickeylau/lifelab
make run
```

That's it! 🎉
