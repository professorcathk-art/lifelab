# 在真實設備上測試 Apple Sign In

## ✅ 為什麼需要真實設備？

**Apple Sign In 在模擬器上不支持！**
- ❌ iOS 模擬器不支持 Apple Sign In
- ✅ 必須在真實 iPhone/iPad 上測試
- ✅ 這是 Apple 的限制，不是應用問題

---

## 📱 方法 1: 直接通過 Xcode 安裝（最簡單）

### Step 1: 連接 iPhone
1. 使用 USB 線連接 iPhone 到 Mac
2. **解鎖 iPhone**
3. 如果提示，選擇 **信任此電腦**

### Step 2: 在 Xcode 中選擇設備
1. 打開 Xcode
2. 打開項目：`LifeLab/LifeLab.xcodeproj`
3. 在頂部工具欄，點擊 **設備選擇器**
4. 選擇您的 **iPhone**（應該會顯示您的設備名稱）

### Step 3: 構建並運行
1. 點擊 **Run** 按鈕（▶️）或按 **⌘R**
2. Xcode 會：
   - 構建應用
   - 安裝到您的 iPhone
   - 自動啟動

### 首次使用可能需要：
- **信任開發者證書**：
  - iPhone: 設置 > 通用 > VPN 與設備管理
  - 找到您的開發者證書
  - 點擊 **信任**

- **啟用開發者模式**：
  - iPhone: 設置 > 隱私與安全性 > 開發者模式
  - 啟用開發者模式
  - 重啟 iPhone

---

## 🔧 方法 2: 使用命令行（如果 Xcode GUI 有問題）

### Step 1: 檢查設備連接
```bash
xcrun xctrace list devices
```

您應該看到您的 iPhone 列在其中。

### Step 2: 構建應用
```bash
cd /Users/mickeylau/lifelab
xcodebuild -project LifeLab/LifeLab.xcodeproj \
           -scheme LifeLab \
           -sdk iphoneos \
           -destination 'generic/platform=iOS' \
           -configuration Debug \
           CODE_SIGN_IDENTITY="Apple Development" \
           CODE_SIGNING_REQUIRED=YES \
           CODE_SIGNING_ALLOWED=YES \
           build
```

### Step 3: 安裝到設備
構建完成後，應用會在 `build/` 文件夾中。然後：
1. 打開 Xcode
2. Window > Devices and Simulators
3. 選擇您的 iPhone
4. 點擊 **+** 在 "Installed Apps" 下
5. 選擇 `.app` 文件

---

## 🆓 方法 3: 免費開發者帳號（推薦用於測試）

**不需要 $99 付費帳號！**

### 設置：
1. **打開 Xcode**
2. **Xcode > Settings** (⌘,)
3. **Accounts** 標籤
4. 點擊 **+** → **Apple ID**
5. **登錄** 您的 Apple ID（免費！）
6. **選擇您的帳號** → 勾選 "Personal Team"

### 然後：
1. 在 Xcode 項目設置中：
   - 選擇 **LifeLab** target
   - **Signing & Capabilities** 標籤
   - **Team:** 選擇您的 Personal Team
   - Xcode 會自動創建配置文件

2. **連接 iPhone** → **Run** (▶️)

**注意**：免費帳號的限制：
- 應用 7 天後過期
- 需要每週重新安裝
- 不能分發給其他人

但對於 **測試您自己的應用** 來說完全足夠！

---

## 🚀 快速開始（推薦）

**最簡單的方法：**

1. **連接 iPhone**（USB，解鎖，信任）
2. **打開 Xcode**
3. **打開** `LifeLab/LifeLab.xcodeproj`
4. **選擇 iPhone** 從設備選擇器（頂部工具欄）
5. **點擊 Run** (▶️)

完成！應用會安裝並在您的 iPhone 上運行！

---

## ✅ 測試 Apple Sign In

安裝後：
1. 打開應用
2. 點擊 **Apple Sign In** 按鈕
3. 完成 Apple 認證流程
4. 驗證登錄成功

---

## ❓ 故障排除

### "No devices found"
- 確保 iPhone 已解鎖
- 在 iPhone 上信任此電腦
- 嘗試不同的 USB 線/端口

### "Code signing error"
- 在 Xcode Settings > Accounts 中添加您的 Apple ID
- 在項目設置中選擇您的團隊
- 啟用 "Automatically manage signing"

### "Developer mode required"
- iPhone: 設置 > 隱私與安全性 > 開發者模式 > 啟用
- 重啟 iPhone

### "Untrusted developer"
- iPhone: 設置 > 通用 > VPN 與設備管理
- 信任您的開發者證書

---

## 🎯 優勢

在真實設備上測試：
- ✅ **真實性能** - 看到實際速度
- ✅ **真實 UI** - 完美渲染
- ✅ **觸摸手勢** - 測試交互
- ✅ **Apple Sign In** - 完全支持
- ✅ **比模擬器更好** - 更準確

---

## 📝 下一步

1. **連接您的 iPhone** 到 Mac
2. **打開 Xcode** → 打開 `LifeLab/LifeLab.xcodeproj`
3. **選擇 iPhone** 從設備選擇器
4. **點擊 Run** (▶️)

**比模擬器好得多！** 🎉
