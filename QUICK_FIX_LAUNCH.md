# Quick Fix for Launch Error

The build succeeds but app crashes on launch. Try these fixes:

## ✅ Fix 1: Clean and Reset (Most Likely to Work)

**In Xcode:**
1. **Product > Clean Build Folder** (⇧⌘K)
2. **Simulator > Device > Erase All Content and Settings**
3. Wait for reset
4. **Run** (⌘R) again

---

## ✅ Fix 2: Disable App Sandbox

Your project has App Sandbox enabled which can cause launch issues:

1. Select **LifeLab** project (blue icon)
2. Select **LifeLab** target
3. **Signing & Capabilities** tab
4. If you see **App Sandbox**, click the **-** button to remove it
5. **Run** again

---

## ✅ Fix 3: Check Console for Crash Log

**See what's actually crashing:**

1. **Window > Devices and Simulators**
2. Select your simulator
3. Click **Open Console** button
4. **Run** the app again
5. Look for red error messages
6. Share the error message - that will tell us what's wrong!

---

## ✅ Fix 4: Simplify App Entry Point (Test)

**Temporarily simplify to see if it's a code issue:**

Try changing `LifeLabApp.swift` to:

```swift
import SwiftUI

@main
struct LifeLabApp: App {
    var body: some Scene {
        WindowGroup {
            Text("Hello LifeLab!")
                .padding()
        }
    }
}
```

If this works, the issue is in `ContentView` or dependencies.

---

## 🎯 Most Likely Solution

**Try this order:**

1. **Clean Build Folder** (⇧⌘K)
2. **Erase Simulator** (Device > Erase All Content)
3. **Remove App Sandbox** (if present)
4. **Run** (⌘R)

If still not working, **check Console logs** and share the error message!

---

## 📱 Alternative: Install on Real iPhone

Since you have an iPhone, this might work better:

1. Connect iPhone via USB
2. Select iPhone as destination in Xcode
3. Click Run

Real devices sometimes work when simulators don't!
