# Complete Testing Guide

## 🚀 Quick Start Testing

### Step 1: Build and Run
```bash
# Option 1: Command line
make run

# Option 2: Xcode
# Open Xcode → Select iPhone 17 Pro Max → Click Run (⌘R)
```

### Step 2: Test Initial Scan (10 seconds timer)
1. App launches → See "興趣選擇"
2. Click "開始" → Timer starts at **10 seconds**
3. Select keywords → Related keywords appear
4. Timer expires → Auto-advances to next step
5. Complete all 6 steps:
   - Interests (10 sec timer)
   - Strengths (5 questions)
   - Values (drag to rank)
   - AI Summary
   - Payment (test mode - no real charge)
   - Life Blueprint

### Step 3: Test Export/Share
- On Life Blueprint screen:
  - Click "分享" → iOS share sheet appears
  - Click "導出" → File saved, share sheet appears

### Step 4: Test Deepening Exploration
- Go to "深化探索" tab
- Complete steps in order:
  1. Flow Diary (3 days)
  2. Values Questions (unlocks after Flow Diary)
  3. Resource Inventory (unlocks after Values Questions)
  4. Acquired Strengths (unlocks after Resource Inventory)
  5. Feasibility Assessment (unlocks after Acquired Strengths)

---

## 📱 Detailed Test Cases

### Test Case 1: Initial Scan Flow

**Objective**: Verify complete initial scan works

**Steps**:
1. Launch app
2. **Interests Selection**:
   - Click "開始"
   - Verify timer shows "剩餘時間：10秒"
   - Select 3-5 keywords
   - Verify selected keywords appear at bottom
   - Wait for timer to expire OR click "繼續"
   - ✅ Should advance to Strengths

3. **Strengths Questionnaire**:
   - Answer Question 1: Select keywords
   - Navigate to Question 2
   - Complete all 5 questions
   - ✅ Should advance to Values

4. **Values Ranking**:
   - Drag values to reorder
   - Verify ranking numbers update
   - Complete ranking
   - ✅ Should advance to AI Summary

5. **AI Summary**:
   - Wait for summary to generate
   - Verify summary text appears
   - ✅ Should advance to Payment

6. **Payment**:
   - Click "立即支付"
   - ✅ Should unlock blueprint (no real charge)

7. **Life Blueprint**:
   - Verify vocation directions appear
   - Test "分享" button
   - Test "導出" button
   - Click "開始深化探索"
   - ✅ Should navigate to MainTabView

**Expected Result**: Complete flow works, data saves

---

### Test Case 2: Deepening Exploration Progressive Unlock

**Objective**: Verify progressive unlocking system

**Steps**:
1. Complete Initial Scan
2. Go to "深化探索" tab
3. **Flow Diary**:
   - Should be unlocked (no lock icon)
   - Click to open
   - Record Day 1: activity, description, energy level
   - Record Day 2
   - Record Day 3
   - Verify progress shows "已完成 3/3 天"
   - Complete flow diary
   - ✅ Values Questions should unlock

4. **Values Questions**:
   - Should now be unlocked
   - Complete all questions
   - ✅ Resource Inventory should unlock

5. **Resource Inventory**:
   - Should now be unlocked
   - Fill all 4 categories
   - ✅ Acquired Strengths should unlock

6. **Acquired Strengths**:
   - Should now be unlocked
   - Fill all 4 categories
   - ✅ Feasibility Assessment should unlock

7. **Feasibility Assessment**:
   - Should now be unlocked
   - Evaluate all 6 paths
   - Complete assessment

**Expected Result**: Each step unlocks the next sequentially

---

### Test Case 3: Dashboard Progress Tracking

**Objective**: Verify progress bars update correctly

**Steps**:
1. Complete Initial Scan
2. Go to Dashboard
3. **Initial Scan Progress**:
   - Should show 100% (green checkmark)
   - Progress bar should be full

4. **Deepening Exploration Progress**:
   - Start at 0%
   - Complete Flow Diary → Should show 20%
   - Complete Values Questions → Should show 40%
   - Complete Resource Inventory → Should show 60%
   - Complete Acquired Strengths → Should show 80%
   - Complete Feasibility Assessment → Should show 100% (checkmark)

**Expected Result**: Progress bars update in real-time

---

### Test Case 4: Data Persistence

**Objective**: Verify data saves and persists

**Steps**:
1. Complete Initial Scan
2. Complete Flow Diary (Day 1 only)
3. **Close app completely**:
   - Double-click home
   - Swipe up on app
4. **Reopen app**:
   - Launch app again
5. **Verify**:
   - Should resume at correct step
   - Flow Diary Day 1 should still be there
   - All data intact

**Expected Result**: All data persists after app close

---

### Test Case 5: Export Functionality

**Objective**: Verify export/share works

**Steps**:
1. Complete Initial Scan
2. View Life Blueprint
3. **Test Share**:
   - Click "分享"
   - Verify iOS share sheet appears
   - Can share via Messages, Email, etc.

4. **Test Export**:
   - Click "導出"
   - Verify file is created
   - Verify share sheet appears
   - Can save to Files app

5. **Test Settings Export**:
   - Go to Settings tab
   - Click "導出所有數據"
   - Verify complete data export
   - Verify file contains all information

**Expected Result**: Export/share functions work correctly

---

## 🔄 How to Restart/Reset

### Restart App in Simulator:
1. **Double-click Home button** (or swipe up from bottom)
2. **Swipe up** on LifeLab app card
3. **Click LifeLab icon** to restart

### Restart from Xcode:
1. **Stop** (⏹️) button
2. **Run** (▶️) or press **⌘R**

### Reset All Data:
1. Go to **Settings** tab
2. Click **"清除所有數據"**
3. Confirm deletion
4. App resets to initial state

### Reset Simulator:
1. **Simulator > Device > Erase All Content and Settings**
2. Wait for reset
3. Run app again

---

## ✅ Test Checklist

### Initial Scan
- [ ] Timer starts at 10 seconds
- [ ] Timer counts down correctly
- [ ] Keywords can be selected
- [ ] Related keywords appear
- [ ] Navigation between steps works
- [ ] Data saves after each step
- [ ] Payment unlocks blueprint
- [ ] Share/Export buttons work

### Deepening Exploration
- [ ] Flow Diary unlocks first
- [ ] Can record 3 days
- [ ] Progress indicator works
- [ ] Values Questions unlocks after Flow Diary
- [ ] All questions can be answered
- [ ] Resource Inventory unlocks after Values Questions
- [ ] All 4 categories can be filled
- [ ] Acquired Strengths unlocks after Resource Inventory
- [ ] All 4 categories can be filled
- [ ] Feasibility Assessment unlocks after Acquired Strengths
- [ ] All 6 paths can be evaluated

### Dashboard
- [ ] Progress bars display correctly
- [ ] Completion status updates
- [ ] Life Blueprint preview shows

### Settings
- [ ] Export all data works
- [ ] Clear data works (with confirmation)
- [ ] Version number displays

### Data Persistence
- [ ] Data saves automatically
- [ ] Data persists after app close
- [ ] App resumes at correct step

---

## 🎯 Quick Test Commands

```bash
# Build only
make build

# Build and run
make run

# Clean build
make clean

# List simulators
make list-simulators

# Check syntax
make check
```

---

## 📝 Testing Notes

- **Timer**: Now 10 seconds (was 60) for faster testing
- **Payment**: Test mode - no real charge
- **AI**: Currently mocked - generates sample data
- **Data**: Saves to UserDefaults automatically

---

## 🐛 If Something Breaks

1. **Clean Build**: `make clean && make build`
2. **Reset Simulator**: Erase All Content and Settings
3. **Check Console**: Window > Devices and Simulators > Open Console
4. **Restart Xcode**: Sometimes helps with build issues

---

## ✅ Health Check Status

- ✅ **Build**: SUCCESS
- ✅ **Errors**: 0
- ✅ **Critical Warnings**: 0
- ✅ **Code Quality**: Good
- ✅ **Architecture**: MVVM followed
- ✅ **Ready for Testing**: YES

---

## 🚀 You're Ready!

The app is healthy and ready to test. Follow the test cases above to verify everything works!
