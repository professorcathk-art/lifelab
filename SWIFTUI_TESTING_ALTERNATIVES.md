# SwiftUI Testing Alternatives (Expo Go Equivalent)

Since Expo Go only works with React Native/Expo apps, here are the best alternatives for testing your SwiftUI app:

## 🎯 Best Options for SwiftUI

### 1. **TestFlight** (Most Similar to Expo Go Experience)
**Best for**: Real device testing, sharing with testers

**Setup**:
```bash
# Build for TestFlight
xcodebuild -project LifeLab/LifeLab.xcodeproj \
           -scheme LifeLab \
           -configuration Release \
           archive -archivePath ./build/LifeLab.xcarchive

# Upload to App Store Connect (requires Apple Developer account)
# Then distribute via TestFlight
```

**Advantages**:
- ✅ Test on real devices
- ✅ Easy sharing with testers
- ✅ Over-the-air updates
- ✅ No need to connect via cable
- ✅ Similar to Expo Go's ease of use

**Requirements**: Apple Developer account ($99/year)

---

### 2. **Swift Playgrounds** (Quick UI Testing)
**Best for**: Testing individual views/components quickly

**How to use**:
1. Create a `.playground` file
2. Copy your SwiftUI view code
3. Run in Playgrounds app

**Example**:
```swift
import SwiftUI
import PlaygroundSupport

struct TestView: View {
    var body: some View {
        Text("Hello, SwiftUI!")
    }
}

PlaygroundPage.current.setLiveView(TestView())
```

**Advantages**:
- ✅ Fast iteration
- ✅ No full app build needed
- ✅ Free
- ✅ Good for component testing

**Limitations**:
- ⚠️ Limited to single views
- ⚠️ Can't test full app flow
- ⚠️ No access to app lifecycle

---

### 3. **iOS Simulator via Command Line** (Already Set Up!)
**Best for**: Daily development, quick testing

**What you have**:
```bash
./test_without_xcode.sh run
make run
```

**Advantages**:
- ✅ Fast
- ✅ No Xcode GUI needed
- ✅ Free
- ✅ Already configured!

**Limitations**:
- ⚠️ Requires Mac
- ⚠️ Simulator only (not real device)

---

### 4. **Hot Reload with InjectionIII** (Like Expo's Fast Refresh)
**Best for**: Live code updates without rebuilding

**Installation**:
1. Download [InjectionIII](https://github.com/johnno1962/InjectionIII) from Mac App Store
2. Add to your app:

```swift
#if DEBUG
import InjectionIII
#endif

@main
struct LifeLabApp: App {
    init() {
        #if DEBUG
        InjectionIII.load()
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

**Advantages**:
- ✅ Live code updates
- ✅ Similar to Expo's hot reload
- ✅ Faster iteration

---

### 5. **Previews in Xcode** (Minimal GUI Usage)
**Best for**: Quick UI iteration

Even if you avoid Xcode GUI, you can use Previews for quick checks:

```swift
#Preview {
    ContentView()
}
```

Then use `⌘⌥P` to refresh previews.

---

## 🚀 Recommended Workflow

### For Daily Development:
```bash
# Use command line (already set up!)
make run
```

### For Real Device Testing:
1. Use **TestFlight** (requires Apple Developer account)
2. Or use **Xcode's wireless debugging** (iOS 16+)

### For Quick Component Testing:
- Use **Swift Playgrounds** for isolated views
- Use **Previews** for quick checks

---

## 📱 Real Device Testing Without Xcode GUI

### Option A: Wireless Debugging (iOS 16+)
```bash
# Enable wireless debugging on your iPhone:
# Settings > Developer > Wireless Debugging

# Then connect via command line
# (Xcode still needed for initial pairing, but then you can use CLI)
```

### Option B: TestFlight (Best Option)
1. Build archive
2. Upload to App Store Connect
3. Distribute via TestFlight
4. Install TestFlight app on iPhone
5. Test over-the-air

---

## 🔄 If You Want Expo Go Experience

### Option 1: Migrate to React Native/Expo
**Pros**:
- ✅ Expo Go for instant testing
- ✅ Cross-platform (iOS + Android)
- ✅ Hot reload built-in
- ✅ Easier sharing

**Cons**:
- ❌ Complete rewrite required
- ❌ Lose native SwiftUI performance
- ❌ Different architecture

**Migration effort**: ~2-4 weeks for your current app

### Option 2: Stay with SwiftUI + Better Tooling
**Pros**:
- ✅ Keep native performance
- ✅ Keep SwiftUI (modern, declarative)
- ✅ Better iOS integration

**Cons**:
- ❌ No Expo Go equivalent
- ❌ iOS only (unless you add SwiftUI for macOS)

**Current setup**: Already optimized for CLI testing!

---

## 💡 My Recommendation

**Stick with SwiftUI** and use:
1. **Command line tools** (already set up) for daily testing
2. **TestFlight** for real device testing and sharing
3. **Swift Playgrounds** for quick component tests
4. **InjectionIII** for hot reload experience

This gives you 90% of Expo Go's benefits while keeping native performance!

---

## 🛠️ Quick Setup for TestFlight Alternative

If you want the easiest real-device testing:

1. **Get Apple Developer account** ($99/year)
2. **Build and upload**:
```bash
# Archive
xcodebuild archive -project LifeLab/LifeLab.xcodeproj \
                   -scheme LifeLab \
                   -archivePath ./build/LifeLab.xcarchive

# Export (requires manual steps in Xcode or use fastlane)
```

3. **Distribute via TestFlight** - testers install TestFlight app and get your app instantly!

---

## 📚 Resources

- [TestFlight Guide](https://developer.apple.com/testflight/)
- [InjectionIII](https://github.com/johnno1962/InjectionIII)
- [Swift Playgrounds](https://www.apple.com/swift-playgrounds/)
- [Wireless Debugging](https://developer.apple.com/documentation/xcode/installing-apps-on-devices-wirelessly)
