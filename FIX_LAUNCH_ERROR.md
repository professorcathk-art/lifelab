# Fix "No such process" Launch Error

This error usually means the app crashes immediately on launch. Here's how to fix it:

## 🔧 Quick Fixes (Try These First)

### Fix 1: Clean Build Folder
1. In Xcode: **Product > Clean Build Folder** (⇧⌘K)
2. Close Simulator
3. Run again (⌘R)

### Fix 2: Reset Simulator
1. **Simulator > Device > Erase All Content and Settings**
2. Wait for reset
3. Run again

### Fix 3: Check Code Signing
1. Select **LifeLab** project in navigator
2. Select **LifeLab** target
3. **Signing & Capabilities** tab
4. Make sure **"Automatically manage signing"** is checked
5. Select your **Team** (or Personal Team)
6. Run again

### Fix 4: Check Minimum iOS Version
1. Select **LifeLab** target
2. **General** tab
3. **Minimum Deployments** should be **iOS 16.0** or lower
4. Simulator is iOS 26.2, so this should be fine

---

## 🐛 Common Causes

### Issue 1: App Sandbox Enabled
Your project has `ENABLE_APP_SANDBOX = YES` which might cause issues.

**Fix:**
1. Select **LifeLab** target
2. **Signing & Capabilities** tab
3. Remove **App Sandbox** capability (if present)
4. Or disable it in Build Settings

### Issue 2: Missing Info.plist Entries
SwiftUI apps need certain Info.plist entries.

**Fix:**
1. Select **LifeLab** target
2. **Info** tab
3. Make sure these exist:
   - `UIApplicationSceneManifest`
   - `UILaunchScreen`

### Issue 3: App Crashes on Launch
Check Console for crash logs.

**Fix:**
1. **Window > Devices and Simulators**
2. Select your simulator
3. Click **Open Console**
4. Look for crash logs
5. Check what's causing the crash

---

## 🔍 Debug Steps

### Step 1: Check Console Logs
1. **Window > Devices and Simulators**
2. Select simulator
3. **Open Console** button
4. Look for error messages when app launches

### Step 2: Enable Exception Breakpoints
1. In Xcode: **Debug > Breakpoints > Create Exception Breakpoint**
2. Run again
3. See where it crashes

### Step 3: Check Build Log
1. **View > Navigators > Report Navigator** (⌘9)
2. Click latest build
3. Look for warnings/errors

---

## ✅ Most Likely Fix

**Try this first:**

1. **Product > Clean Build Folder** (⇧⌘K)
2. **Simulator > Device > Erase All Content and Settings**
3. In Xcode project:
   - Select **LifeLab** target
   - **Signing & Capabilities**
   - Make sure **Team** is selected
   - **Automatically manage signing** is checked
4. **Run** (⌘R)

---

## 🚨 If Still Not Working

Check if the app entry point is correct:

1. Make sure `LifeLabApp.swift` has `@main` attribute
2. Make sure `ContentView` exists and is valid
3. Check for any import errors

Let me know what you see in the Console logs!
