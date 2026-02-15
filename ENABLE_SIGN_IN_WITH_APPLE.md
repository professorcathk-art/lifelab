# 如何在 Xcode 中啟用 "Sign In with Apple"

## ✅ Step 1: 檢查 Bundle ID

### 當前項目配置
- **Bundle ID**: `com.resonance.lifelab`
- **位置**: Xcode 項目設置

### 驗證步驟
1. 打開 Xcode
2. 選擇項目文件（藍色圖標）→ **LifeLab** target
3. **General** 標籤
4. 查看 **Bundle Identifier** 欄位
5. 確認顯示：`com.resonance.lifelab`

### 在 Apple Developer 中檢查
1. 登錄 [Apple Developer](https://developer.apple.com/account/)
2. **Certificates, Identifiers & Profiles**
3. **Identifiers** → **App IDs**
4. 搜索 `com.resonance.lifelab`
5. 確認存在且已啟用 "Sign In with Apple"

---

## ✅ Step 2: 在 Xcode 中啟用 "Sign In with Apple"

### 方法 1: 通過 Signing & Capabilities（推薦）

#### Step 2.1: 打開項目設置
1. 打開 Xcode
2. 在左側項目導航器中，點擊**藍色項目圖標**（最頂部）
3. 在 TARGETS 下選擇 **LifeLab**

#### Step 2.2: 打開 Signing & Capabilities
1. 點擊頂部的 **Signing & Capabilities** 標籤
2. 確認 **Automatically manage signing** 已勾選
3. 確認 **Team** 已選擇（您的開發團隊）

#### Step 2.3: 添加 Sign In with Apple 功能
1. 點擊 **+ Capability** 按鈕（左上角）
2. 在搜索框中輸入：`Sign In with Apple`
3. 雙擊 **Sign In with Apple** 或點擊 **+** 按鈕
4. 功能會自動添加到列表中

#### Step 2.4: 驗證添加成功
- 在 **Signing & Capabilities** 標籤中，您應該看到：
  - ✅ **Sign In with Apple** 出現在功能列表中
  - ✅ 沒有紅色錯誤標記
  - ✅ 顯示 "Sign In with Apple is enabled"

---

## ✅ Step 3: 檢查 Entitlements 文件

### 自動創建
當您添加 "Sign In with Apple" 功能時，Xcode 會自動：
1. 創建 `LifeLab.entitlements` 文件
2. 添加 `com.apple.developer.applesignin` 權限

### 手動檢查（如果需要）
1. 在項目導航器中查找 `LifeLab.entitlements` 文件
2. 打開文件，應該看到：
```xml
<key>com.apple.developer.applesignin</key>
<array>
    <string>Default</string>
</array>
```

---

## ✅ Step 4: 驗證配置

### 檢查清單
- [ ] Bundle ID 為 `com.resonance.lifelab`
- [ ] Team 已選擇
- [ ] "Sign In with Apple" 功能已添加
- [ ] 沒有紅色錯誤標記
- [ ] Entitlements 文件包含 `com.apple.developer.applesignin`

### 常見問題

#### Q: 看不到 "+ Capability" 按鈕？
A: 確保：
- 選擇了正確的 target（LifeLab）
- 在 **Signing & Capabilities** 標籤中
- 不是 **General** 或其他標籤

#### Q: 添加後出現紅色錯誤？
A: 可能原因：
1. **Bundle ID 不匹配**：確認 Xcode 中的 Bundle ID 與 Apple Developer 中的 App ID 完全一致
2. **未啟用 Sign In with Apple**：在 Apple Developer 中，進入 App ID 設置，啟用 "Sign In with Apple"
3. **證書問題**：確認開發證書有效

#### Q: 如何確認 Apple Developer 中已啟用？
A: 
1. 登錄 [Apple Developer](https://developer.apple.com/account/)
2. **Certificates, Identifiers & Profiles**
3. **Identifiers** → **App IDs**
4. 點擊 `com.resonance.lifelab`
5. 確認 **Sign In with Apple** 已勾選
6. 如果未勾選，點擊 **Edit** → 勾選 **Sign In with Apple** → **Save**

---

## 📸 視覺指南

### Signing & Capabilities 標籤應該看起來像：

```
┌─────────────────────────────────────────┐
│ Signing & Capabilities                  │
├─────────────────────────────────────────┤
│ Team: [您的團隊名稱] ▼                  │
│ ☑ Automatically manage signing         │
│                                         │
│ Capabilities:                          │
│ ┌─────────────────────────────────┐   │
│ │ ✅ Sign In with Apple            │   │
│ │    Sign In with Apple is enabled │   │
│ └─────────────────────────────────┘   │
│                                         │
│ [+ Capability] 按鈕                     │
└─────────────────────────────────────────┘
```

---

## 🎯 快速檢查命令

### 檢查 Bundle ID
```bash
cd /Users/mickeylau/lifelab
grep -r "PRODUCT_BUNDLE_IDENTIFIER" LifeLab/LifeLab.xcodeproj/project.pbxproj | grep -v "//"
```

應該看到：
```
PRODUCT_BUNDLE_IDENTIFIER = com.resonance.lifelab;
```

### 檢查 Entitlements
```bash
find . -name "*.entitlements" -exec cat {} \;
```

應該看到：
```xml
<key>com.apple.developer.applesignin</key>
```

---

## ✅ 完成後

配置完成後：
1. **清理構建**：Product → Clean Build Folder (⇧⌘K)
2. **重新構建**：Product → Build (⌘B)
3. **在真實設備上測試**：選擇您的 iPhone → Run (▶️)

---

## 📝 注意事項

1. **必須在真實設備上測試**：Apple Sign In 在模擬器上可能無法正常工作
2. **Bundle ID 必須完全一致**：包括大小寫和所有字符
3. **需要有效的開發證書**：確保 Team 已選擇且證書有效
4. **首次配置可能需要幾分鐘**：Xcode 需要與 Apple Developer 同步

---

## 🆘 如果仍然出現錯誤 1000

1. **確認所有步驟已完成**
2. **檢查 Apple Developer 中的 App ID 配置**
3. **重新生成開發證書**（如果需要）
4. **在真實設備上測試**（不是模擬器）
5. **查看 Xcode 控制台的詳細錯誤信息**

---

**完成這些步驟後，Apple Sign In 應該可以正常工作！** 🎉
