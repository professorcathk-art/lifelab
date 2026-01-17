# Install LifeLab on Your iPhone - Step by Step

Since you have an iPhone, this is the **BEST** way to test! No simulator needed!

## 🎯 Method 1: Direct Install via Xcode (Easiest)

### Step 1: Connect iPhone
1. **Connect iPhone to Mac** via USB cable
2. **Unlock your iPhone**
3. **Trust this computer** (if prompted on iPhone)

### Step 2: Open Xcode
1. **Open Xcode** (even if GUI is broken, this might work)
2. **Open project:** `LifeLab/LifeLab.xcodeproj`

### Step 3: Select iPhone as Destination
1. At the **top toolbar**, click the **device selector**
2. You should see your iPhone name
3. **Select your iPhone**

### Step 4: Build and Run
1. Click **Run** button (▶️) or press **⌘R**
2. Xcode will:
   - Build the app
   - Install on your iPhone
   - Launch automatically

**First time?** You might need to:
- Trust developer certificate on iPhone: Settings > General > VPN & Device Management
- Enable Developer Mode: Settings > Privacy & Security > Developer Mode

---

## 🔧 Method 2: Command Line (If Xcode GUI Broken)

### Step 1: Connect iPhone
Same as above - connect via USB, unlock, trust.

### Step 2: Check if iPhone is detected
```bash
xcrun xctrace list devices
```

You should see your iPhone listed.

### Step 3: Build for device
```bash
cd /Users/mickeylau/lifelab
xcodebuild -project LifeLab/LifeLab.xcodeproj \
           -scheme LifeLab \
           -sdk iphoneos \
           -destination 'generic/platform=iOS' \
           -configuration Debug \
           CODE_SIGN_IDENTITY="" \
           CODE_SIGNING_REQUIRED=NO \
           build
```

### Step 4: Install via Xcode Organizer
1. Open Xcode
2. **Window > Devices and Simulators**
3. Select your iPhone
4. Click **+** under Installed Apps
5. Select the `.app` file from `build/` folder

---

## 🆓 Method 3: Free Developer Account (Recommended)

**No $99 fee needed for testing on your own device!**

### Setup:
1. **Open Xcode**
2. **Xcode > Settings** (⌘,)
3. **Accounts** tab
4. Click **+** → **Apple ID**
5. **Sign in** with your Apple ID (free!)
6. **Select your account** → Check "Personal Team"

### Then:
1. In Xcode project settings:
   - Select **LifeLab** target
   - **Signing & Capabilities** tab
   - **Team:** Select your Personal Team
   - Xcode will auto-create provisioning profile

2. **Connect iPhone** → **Run** (▶️)

**Note:** Free accounts have limitations:
- Apps expire after 7 days
- Need to reinstall weekly
- Can't distribute to others

But perfect for **testing your own app**!

---

## 🚀 Quick Start (Recommended)

**Easiest way:**

1. **Connect iPhone** (USB, unlock, trust)
2. **Open Xcode**
3. **Open** `LifeLab/LifeLab.xcodeproj`
4. **Select iPhone** from device picker (top toolbar)
5. **Click Run** (▶️)

That's it! App installs and runs on your iPhone!

---

## ❓ Troubleshooting

### "No devices found"
- Make sure iPhone is unlocked
- Trust this computer on iPhone
- Try different USB cable/port

### "Code signing error"
- Add your Apple ID in Xcode Settings > Accounts
- Select your team in project settings
- Enable "Automatically manage signing"

### "Developer mode required"
- iPhone: Settings > Privacy & Security > Developer Mode > Enable
- Restart iPhone

### "Untrusted developer"
- iPhone: Settings > General > VPN & Device Management
- Trust your developer certificate

---

## ✅ Advantages of Real Device Testing

- ✅ **Real performance** - See actual speed
- ✅ **Real UI** - Perfect rendering
- ✅ **Touch gestures** - Test interactions
- ✅ **No simulator issues** - Works reliably
- ✅ **Better than simulator** - More accurate

---

## 🎯 What to Do Now

1. **Connect your iPhone** to Mac
2. **Open Xcode** → Open `LifeLab/LifeLab.xcodeproj`
3. **Select iPhone** from device picker
4. **Click Run** (▶️)

**Much better than simulators!** 🎉
