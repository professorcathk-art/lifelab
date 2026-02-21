# App Store Connect - 應用內購買設置指南

## 問題：缺少元資料 (Missing Metadata)

當產品狀態顯示"缺少元資料"時，需要完成以下必填項目：

## 必填項目清單

### 1. 產品資訊 (Product Information)

#### 產品 ID (Product ID)
根據您的代碼，應該使用：
- **年付**: `com.resonance.lifelab.yearly`
- **季付**: `com.resonance.lifelab.quarterly`
- **月付**: `com.resonance.lifelab.monthly`

**重要**: 確保在 App Store Connect 中創建的產品 ID 與代碼中的完全一致！

#### 產品類型 (Product Type)
選擇：**自動續訂訂閱** (Auto-Renewable Subscription)

### 2. 本地化資訊 (Localization)

#### 繁體中文 (zh-Hant)
- **顯示名稱**: `LifeLab 年付訂閱` (或 `LifeLab Yearly Subscription`)
- **描述**: 
  ```
  解鎖 LifeLab 完整功能，包括：
  • AI 個人化生命藍圖生成
  • 深度自我探索工具
  • 專屬行動計劃與里程碑
  • 持續更新與優化
  
  訂閱將自動續訂，您可以在 App Store 設定中隨時取消。
  ```

#### 英文 (en-US) - 可選但推薦
- **Display Name**: `LifeLab Yearly Subscription`
- **Description**: 
  ```
  Unlock full LifeLab features including:
  • AI-powered personalized life blueprint
  • Deep self-exploration tools
  • Customized action plans and milestones
  • Continuous updates and improvements
  
  Subscription auto-renews. Cancel anytime in App Store settings.
  ```

### 3. 訂閱資訊 (Subscription Information)

#### 訂閱組 (Subscription Group)
- 如果還沒有訂閱組，需要先創建一個
- 組名：`LifeLab Premium` 或 `LifeLab Subscription`
- 在同一個組內，用戶只能同時擁有一個訂閱

#### 訂閱期限 (Subscription Duration)
- **年付**: 1 年 (1 Year)
- **季付**: 3 個月 (3 Months)
- **月付**: 1 個月 (1 Month)

#### 價格 (Price)
- 選擇價格等級（Price Tier）
- 根據您的代碼，建議：
  - 年付：約 $7.9/月（年付）
  - 季付：約 $9.9/月（季付）
  - 月付：約 $18.99/月

### 4. 審核資訊 (Review Information)

#### 審核備註 (Review Notes)
```
此應用內購買用於解鎖 LifeLab 的完整功能，包括：
- AI 生成個人化生命藍圖
- 深度自我探索工具
- 行動計劃與里程碑追蹤

測試帳號：[提供測試帳號]
測試步驟：
1. 完成初步掃描問卷
2. 進入支付頁面
3. 選擇訂閱方案
4. 完成購買流程
```

### 5. 可選但推薦

#### 產品截圖 (Screenshots)
- 上傳支付頁面的截圖
- 顯示訂閱選項和價格
- 幫助審核人員理解產品

#### 促銷圖片 (Promotional Image)
- 可選，但可以提升轉換率

## 設置步驟

### 步驟 1: 創建訂閱組（如果還沒有）
1. 在 App Store Connect 中，進入 **App 內購買項目**
2. 點擊 **訂閱組** (Subscription Groups)
3. 點擊 **+** 創建新組
4. 輸入組名：`LifeLab Premium`
5. 保存

### 步驟 2: 編輯產品元資料
1. 點擊您的產品 "LifeLab Yearly Subscription"
2. 點擊 **編輯** (Edit)
3. 完成所有必填項目：
   - ✅ 產品 ID（確認與代碼一致）
   - ✅ 本地化資訊（至少繁體中文）
   - ✅ 訂閱組（選擇剛創建的組）
   - ✅ 訂閱期限（1 年）
   - ✅ 價格
   - ✅ 審核資訊

### 步驟 3: 保存並提交審核
1. 完成所有必填項目後，點擊 **儲存** (Save)
2. 狀態應該從"缺少元資料"變為"準備提交"
3. 點擊 **提交以供審核** (Submit for Review)

## 常見問題

### Q: 產品 ID 必須與代碼完全一致嗎？
**A**: 是的！產品 ID 必須完全匹配，包括大小寫。

### Q: 需要為所有語言提供本地化嗎？
**A**: 至少需要提供應用支援的主要語言（繁體中文）。英文可選但推薦。

### Q: 價格如何設置？
**A**: 使用價格等級（Price Tier）系統，選擇對應的等級即可。系統會自動轉換為各地貨幣。

### Q: 訂閱組是什麼？
**A**: 訂閱組用於管理多個訂閱選項。同一組內的訂閱是互斥的（用戶只能選一個）。

## 檢查清單

在提交前，確認：
- [ ] 產品 ID 與代碼中的完全一致
- [ ] 已填寫至少一種語言的本地化資訊
- [ ] 已選擇訂閱組
- [ ] 已設置訂閱期限
- [ ] 已選擇價格
- [ ] 已填寫審核資訊
- [ ] 狀態顯示為"準備提交"而非"缺少元資料"

## 下一步

完成設置後：
1. 在 Xcode 中測試應用內購買（使用沙盒測試帳號）
2. 確保代碼中的產品 ID 與 App Store Connect 中的一致
3. 提交應用和應用內購買項目一起審核

