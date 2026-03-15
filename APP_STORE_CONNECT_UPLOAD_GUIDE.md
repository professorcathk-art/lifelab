# App Store Connect Upload Guide

## Step 1: Check Current Version & Build Numbers

### Current Configuration (from project.pbxproj):
- **Marketing Version**: 1.3.2
- **Current Project Version**: 2

### What to Change:

**For a new submission, you need to increment:**

1. **Build Number** (CURRENT_PROJECT_VERSION):
   - Current: 2
   - **Change to**: 3 (or higher)
   - This MUST be incremented for each upload

2. **Version Number** (MARKETING_VERSION) - Optional:
   - Current: 1.3.2
   - Only change if you want to update the version shown to users
   - For bug fixes: Keep same (1.3.2) or increment patch (1.3.3)
   - For new features: Increment minor (1.4.0)
   - For major changes: Increment major (2.0.0)

## Step 2: Update Build Number in Xcode

### Option A: Via Xcode GUI (Recommended)

1. **Open Xcode**
2. **Select Project** in Navigator (left sidebar)
3. **Select "LifeLab" target**
4. **Go to "General" tab**
5. **Find "Identity" section**:
   - **Version**: 1.3.2 (or update if needed)
   - **Build**: 2 → **Change to 3** (or higher)
6. **Save** (⌘S)

### Option B: Via project.pbxproj (Advanced)

Edit `LifeLab/LifeLab.xcodeproj/project.pbxproj`:
- Find `CURRENT_PROJECT_VERSION = 2;`
- Change to `CURRENT_PROJECT_VERSION = 3;`

## Step 3: Archive the App

### Method 1: Via Xcode GUI

1. **Select "Any iOS Device"** (or "Generic iOS Device") from device selector
   - NOT a simulator
   - Top toolbar, next to Play button

2. **Product → Archive**
   - Or press: ⌘B (Build) then Product → Archive
   - Wait for build to complete (may take 2-5 minutes)

3. **Organizer Window Opens**
   - Shows your archive
   - Date and version info displayed

### Method 2: Via Command Line

```bash
cd /Users/mickeylau/lifelab

# Clean build folder
xcodebuild clean -project LifeLab/LifeLab.xcodeproj -scheme LifeLab

# Create archive
xcodebuild archive \
  -project LifeLab/LifeLab.xcodeproj \
  -scheme LifeLab \
  -configuration Release \
  -archivePath ./build/LifeLab.xcarchive \
  -destination 'generic/platform=iOS'
```

## Step 4: Upload to App Store Connect

### Method 1: Via Xcode Organizer (Recommended)

1. **In Organizer Window** (after archiving):
   - Select your archive
   - Click **"Distribute App"**

2. **Distribution Method**:
   - Select **"App Store Connect"**
   - Click **"Next"**

3. **Distribution Options**:
   - Select **"Upload"**
   - Click **"Next"**

4. **App Thinning**:
   - Select **"All compatible device variants"** (default)
   - Click **"Next"**

5. **Distribution Certificate**:
   - Xcode will automatically manage signing
   - Click **"Next"**

6. **Review**:
   - Review summary
   - Click **"Upload"**

7. **Wait for Upload**:
   - Progress bar shows upload status
   - May take 5-15 minutes depending on app size
   - Don't close Xcode during upload

### Method 2: Via Command Line (xcrun altool)

```bash
# Upload archive
xcrun altool --upload-app \
  --type ios \
  --file "./build/LifeLab.ipa" \
  --apiKey YOUR_API_KEY \
  --apiIssuer YOUR_ISSUER_ID
```

**Note**: Requires App Store Connect API key setup

### Method 3: Via Transporter App

1. **Download Transporter** from Mac App Store
2. **Export IPA** from Xcode Organizer:
   - Right-click archive → Export
   - Select "App Store Connect"
   - Save IPA file
3. **Open Transporter**
4. **Drag IPA** into Transporter
5. **Click "Deliver"**

## Step 5: Verify Upload in App Store Connect

1. **Login to App Store Connect**:
   - https://appstoreconnect.apple.com
   - Use your Apple Developer account

2. **Navigate to Your App**:
   - **My Apps** → **LifeLab**

3. **Check Build Status**:
   - Go to **"TestFlight"** tab (or **"App Store"** → **"Versions"**)
   - Look for your build (Build 3)
   - Status will show:
     - **Processing** (wait 10-30 minutes)
     - **Ready to Submit** (ready!)
     - **Invalid Binary** (if errors - check email)

4. **Wait for Processing**:
   - Apple processes the binary (10-30 minutes)
   - You'll receive email when ready

## Step 6: Submit for Review

### After Build is Processed:

1. **Go to App Store Tab**:
   - In App Store Connect
   - Select your app version

2. **Select Build**:
   - Click **"+ Version"** or **"Select a build"**
   - Choose Build 3 (your new build)
   - Click **"Done"**

3. **Complete App Information**:
   - Screenshots (if needed)
   - Description
   - Keywords
   - Support URL
   - Privacy Policy URL

4. **Answer Export Compliance**:
   - Usually: **"No"** (unless using encryption)
   - Click **"Save"**

5. **Submit for Review**:
   - Click **"Submit for Review"**
   - Confirm submission

## Important Notes

### Build Number Rules:
- ✅ **MUST be incremented** for each upload
- ✅ **Must be unique** (can't reuse previous build numbers)
- ✅ **Can be any integer** (1, 2, 3, 10, 100, etc.)
- ✅ **No decimals** (use integers only)

### Version Number Rules:
- ✅ **Format**: X.Y.Z (e.g., 1.3.2)
- ✅ **X** = Major version (breaking changes)
- ✅ **Y** = Minor version (new features)
- ✅ **Z** = Patch version (bug fixes)

### Common Issues:

1. **"Invalid Binary"**:
   - Check email from Apple
   - Usually: Missing icons, wrong bundle ID, or code signing issues

2. **"Build Already Exists"**:
   - Build number already used
   - Increment build number and re-upload

3. **"Processing Failed"**:
   - Check App Store Connect for details
   - May need to re-upload

## Quick Checklist

Before Uploading:
- [ ] Increment build number (2 → 3)
- [ ] Update version number (if needed)
- [ ] Test app thoroughly
- [ ] Archive app successfully
- [ ] Have App Store Connect account ready

After Uploading:
- [ ] Wait for processing (10-30 min)
- [ ] Check email for status
- [ ] Verify build appears in App Store Connect
- [ ] Select build for version
- [ ] Complete app information
- [ ] Submit for review

## Recommended Build Number

**For this upload**: **3**

**Reason**: Current build is 2, so next should be 3.

## Next Steps After Upload

1. **Wait for Processing** (10-30 minutes)
2. **Check Email** from Apple
3. **Verify Build** in App Store Connect
4. **Select Build** for your app version
5. **Submit for Review**

Good luck! 🚀
