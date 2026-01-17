# Fix Unresponsive/Unclickable UI

## 🚨 Quick Fixes (Try These First!)

### Fix 1: Force Close and Restart App

**In Simulator:**
1. **Double-click Home button** (or swipe up from bottom)
2. **Swipe up** on LifeLab app to force close
3. **Click LifeLab icon** to restart

**In Xcode:**
1. **Stop** (⏹️) button
2. **Clean Build Folder** (⇧⌘K)
3. **Run** (▶️) again

---

### Fix 2: Reset Simulator

1. **Simulator > Device > Erase All Content and Settings**
2. Wait for reset
3. **Run app again**

---

### Fix 3: Check Console for Errors

1. **Window > Devices and Simulators**
2. Select your simulator
3. **Open Console**
4. Look for red error messages
5. Share the error - that will tell us what's wrong!

---

## 🔍 Common Causes

### Issue 1: Timer Blocking UI
**Symptom**: UI freezes when timer is running

**Fix**: Timer should already be fixed, but if it happens:
- Force close app
- Restart

### Issue 2: Navigation Loop
**Symptom**: App stuck between screens

**Fix**: 
- Force close app
- Or use "返回" button if visible

### Issue 3: Memory Issue
**Symptom**: App becomes slow/unresponsive

**Fix**:
- Force close app
- Restart simulator
- Clean build folder

### Issue 4: View State Issue
**Symptom**: Buttons don't respond

**Fix**:
- Navigate away and back
- Or force close and restart

---

## 🛠️ Debug Steps

### Step 1: Check What Screen You're On
- Which screen is frozen?
- Can you see any buttons?
- Is timer running?

### Step 2: Try Navigation
- Try swiping back (if possible)
- Try tapping different areas
- Try home button

### Step 3: Force Close
- Always works to reset UI state

### Step 4: Check Console
- Look for error messages
- Check for memory warnings

---

## 🔧 If Still Not Working

### Option 1: Reset App Data
1. Go to **Settings** tab (if accessible)
2. Click **"清除所有數據"**
3. Start fresh

### Option 2: Rebuild App
```bash
make clean
make build
make run
```

### Option 3: Check Specific Screen
Tell me which screen is frozen:
- Initial Scan?
- Deepening Exploration?
- Dashboard?
- Specific step?

---

## 💡 Prevention

**To avoid UI freezing:**
1. Don't leave timer running too long
2. Complete steps in order
3. Don't rapidly tap buttons
4. Close app properly when done testing

---

## 🎯 Quick Actions Right Now

**If UI is frozen RIGHT NOW:**

1. **Force close app** (double-click home → swipe up)
2. **Restart app**
3. **If still frozen**: Reset simulator
4. **If still frozen**: Clean build and rebuild

---

## 📝 Report Back

After trying fixes, let me know:
1. Which screen was frozen?
2. What were you doing when it froze?
3. Did force close fix it?
4. Any error messages in console?

This will help me fix the root cause!
