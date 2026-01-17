# Quick Fix: Unresponsive UI

## 🚨 Immediate Actions

### Step 1: Force Close App (Do This First!)

**In Simulator:**
1. **Double-click Home button** (or swipe up from bottom)
2. **Swipe up** on LifeLab app card
3. **Click LifeLab icon** to restart

**This fixes 90% of UI freezing issues!**

---

### Step 2: If Still Frozen - Reset Simulator

1. **Simulator > Device > Erase All Content and Settings**
2. Wait for reset
3. **Run app again** (⌘R)

---

### Step 3: If Still Frozen - Clean Build

**In Xcode:**
1. **Product > Clean Build Folder** (⇧⌘K)
2. **Stop** (⏹️)
3. **Run** (▶️) again

**Or command line:**
```bash
make clean
make run
```

---

## 🔍 What Screen Is Frozen?

Tell me which screen:
- [ ] Initial Scan (興趣選擇, etc.)
- [ ] Dashboard
- [ ] Deepening Exploration
- [ ] Profile/Settings
- [ ] Review Mode

This helps me fix the specific issue!

---

## 💡 Common Causes & Fixes

### Cause 1: Timer Running
**Fix**: Force close app (timer stops)

### Cause 2: AI Loading
**Fix**: Wait for loading to finish, or force close

### Cause 3: Navigation Issue
**Fix**: Force close and restart

### Cause 4: Memory Issue
**Fix**: Reset simulator

---

## 🛠️ Debug: Check Console

1. **Window > Devices and Simulators**
2. Select simulator
3. **Open Console**
4. Look for:
   - Red error messages
   - Memory warnings
   - Thread issues

**Share any errors you see!**

---

## ✅ Prevention

**To avoid freezing:**
- Don't leave timer running indefinitely
- Complete steps in order
- Don't rapidly tap buttons
- Close app properly when done

---

## 🎯 Right Now

**Try this order:**
1. ✅ **Force close app** (double-click home → swipe up)
2. ✅ **Restart app**
3. ✅ **If still frozen**: Reset simulator
4. ✅ **If still frozen**: Clean build

**Most likely fix**: Force close and restart! 🎉
