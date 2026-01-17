# How to Refresh App with Updated Version

## 🚀 Quick Refresh (Recommended)

### Method 1: Stop and Run Again

**In Xcode:**
1. **Stop** the app (⏹️ button or ⌘.)
2. **Run** again (▶️ button or ⌘R)

**Command Line:**
```bash
# Stop current app, then:
make run
```

---

### Method 2: Clean Build (If Changes Don't Appear)

**In Xcode:**
1. **Stop** app (⏹️)
2. **Product > Clean Build Folder** (⇧⌘K)
3. **Run** again (⌘R)

**Command Line:**
```bash
make clean
make run
```

---

## 🔄 Full Reset (If App Still Shows Old Version)

### Step 1: Stop App
- **Xcode**: Click ⏹️ (Stop button)
- **Simulator**: Double-click Home → Swipe up on app

### Step 2: Clean Build
```bash
make clean
```

Or in Xcode: **Product > Clean Build Folder** (⇧⌘K)

### Step 3: Erase Simulator (Optional)
- **Simulator > Device > Erase All Content and Settings**
- This clears all app data

### Step 4: Rebuild and Run
```bash
make run
```

Or in Xcode: **Run** (⌘R)

---

## 📱 Force Close App in Simulator

If app is frozen or not responding:

1. **Double-click Home button** (or swipe up from bottom)
2. **Swipe up** on LifeLab app card
3. **Click LifeLab icon** to restart

---

## 🔍 Verify New Version

After refreshing, check:

1. **AI Integration**: Complete Initial Scan → Should use Claude API (check console for API calls)
2. **New Features**: 
   - Strengths questionnaire has text boxes
   - Values ranking has grey out button
   - Flow Diary shows "3個心流事件"
   - Task completion works
   - Action plan auto-generates

---

## ⚡ Quick Commands Reference

```bash
# Quick refresh
make run

# Clean and rebuild
make clean && make run

# Just build (no run)
make build

# Check build status
make build 2>&1 | grep -E "BUILD|succeeded|failed"
```

---

## 🐛 If Changes Don't Appear

1. **Clean Build Folder** (⇧⌘K)
2. **Quit Xcode** completely
3. **Restart Xcode**
4. **Clean Build Folder** again
5. **Run** (⌘R)

---

## ✅ After Refresh

Your app should now have:
- ✅ Real AI integration (Claude 4.5 Sonnet)
- ✅ Text boxes in strengths questionnaire
- ✅ Grey out button in values ranking
- ✅ Flow Diary with 3 events (not days)
- ✅ Task completion functionality
- ✅ Auto-generated action plans

---

## 🎯 Right Now

**Try this:**
```bash
make clean
make run
```

This will clean old build files and rebuild with all latest changes!
