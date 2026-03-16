# Questionnaire Keywords System - Complete Guide

## 📋 Overview

This document shows all keywords used in the questionnaires, their hierarchy levels, and the logic for displaying them. Use this guide to manually improve the keywords list.

---

## 🎯 1. Interests Questionnaire (興趣問卷)

### Structure
- **2 Levels**: First-level (parent) → Second-level (child)
- **Initial Display**: Only first-level keywords shown
- **Dynamic Display**: When user selects a first-level keyword, related second-level keywords appear

### Logic Flow

```
1. User sees: All first-level keywords (20 items)
2. User clicks: First-level keyword (e.g., "設計")
3. System shows: Related second-level keywords (e.g., "UI設計", "平面設計", etc.)
4. User can select: Both first-level and second-level keywords
```

### All Keywords by Level

#### Level 1 (First-Level) - 20 Keywords

| # | Keyword | Related Keywords Count |
|---|---------|------------------------|
| 1 | 設計 | 10 |
| 2 | 寫作 | 10 |
| 3 | 音樂 | 10 |
| 4 | 攝影 | 10 |
| 5 | 程式 | 10 |
| 6 | 教育 | 10 |
| 7 | 商業 | 10 |
| 8 | 藝術 | 10 |
| 9 | 運動 | 10 |
| 10 | 烹飪 | 10 |
| 11 | 旅行 | 10 |
| 12 | 閱讀 | 10 |
| 13 | 社交 | 10 |
| 14 | 科技 | 10 |
| 15 | 健康 | 10 |
| 16 | 科學 | 10 |
| 17 | 語言 | 10 |
| 18 | 創意 | 10 |
| 19 | 媒體 | 10 |
| 20 | 環境 | 10 |

#### Level 2 (Second-Level) - Complete Hierarchy

**1. 設計** (10 related keywords)
- UI設計
- 平面設計
- 產品設計
- 品牌設計
- 視覺設計
- 網頁設計
- 動畫設計
- 包裝設計
- 空間設計
- 時尚設計

**2. 寫作** (10 related keywords)
- 文案寫作
- 內容創作
- 小說寫作
- 技術寫作
- 創意寫作
- 詩歌
- 劇本寫作
- 新聞寫作
- 學術寫作
- 博客寫作

**3. 音樂** (10 related keywords)
- 作曲
- 演奏
- 音樂製作
- 音樂教育
- 音響工程
- 歌唱
- 編曲
- 音樂評論
- 音樂治療
- DJ

**4. 攝影** (10 related keywords)
- 人像攝影
- 風景攝影
- 商業攝影
- 後期製作
- 影片製作
- 街頭攝影
- 婚禮攝影
- 產品攝影
- 航拍
- 微距攝影

**5. 程式** (10 related keywords)
- 網頁開發
- 移動應用開發
- 數據分析
- 人工智慧
- 區塊鏈
- 機器學習
- 雲端計算
- 資訊安全
- 遊戲開發
- 自動化

**6. 教育** (10 related keywords)
- 教學
- 課程設計
- 培訓
- 輔導
- 知識分享
- 線上教育
- 語言教學
- 技能培訓
- 兒童教育
- 成人教育

**7. 商業** (10 related keywords)
- 創業
- 行銷
- 管理
- 策略規劃
- 投資
- 財務分析
- 市場研究
- 品牌管理
- 電子商務
- 顧問

**8. 藝術** (10 related keywords)
- 繪畫
- 雕塑
- 插畫
- 動畫
- 數位藝術
- 書法
- 版畫
- 裝置藝術
- 行為藝術
- 公共藝術

**9. 運動** (10 related keywords)
- 健身
- 瑜伽
- 跑步
- 球類運動
- 戶外活動
- 游泳
- 自行車
- 登山
- 舞蹈
- 武術

**10. 烹飪** (10 related keywords)
- 烘焙
- 料理
- 食譜開發
- 美食評論
- 營養規劃
- 甜點製作
- 調酒
- 咖啡
- 茶藝
- 素食料理

**11. 旅行** (10 related keywords)
- 背包旅行
- 文化探索
- 攝影旅行
- 冒險旅行
- 深度旅遊
- 城市探索
- 自然探索
- 歷史之旅
- 美食之旅
- 極地探險

**12. 閱讀** (10 related keywords)
- 文學
- 歷史
- 科學
- 哲學
- 心理學
- 經濟學
- 社會學
- 藝術史
- 傳記
- 科幻

**13. 社交** (10 related keywords)
- 人際關係
- 溝通技巧
- 領導力
- 團隊合作
- 公關
- 演講
- 談判
- 社交媒體
- 網絡建立
- 社區服務

**14. 科技** (10 related keywords)
- 新科技探索
- 產品評測
- 技術研究
- 創新應用
- 科技趨勢
- 物聯網
- 虛擬實境
- 擴增實境
- 量子計算
- 生物科技

**15. 健康** (10 related keywords)
- 養生
- 心理健康
- 營養學
- 運動醫學
- 健康管理
- 冥想
- 正念
- 睡眠優化
- 壓力管理
- 長壽研究

**16. 科學** (10 related keywords)
- 物理學
- 化學
- 生物學
- 天文學
- 地質學
- 數學
- 統計學
- 研究
- 實驗設計
- 科學傳播

**17. 語言** (10 related keywords)
- 英語
- 日語
- 韓語
- 法語
- 西班牙語
- 德語
- 翻譯
- 口譯
- 語言教學
- 語言學習

**18. 創意** (10 related keywords)
- 腦力激盪
- 創新思維
- 問題解決
- 設計思考
- 創意寫作
- 視覺化
- 概念設計
- 原型製作
- 用戶體驗
- 服務設計

**19. 媒體** (10 related keywords)
- 影片製作
- 播客
- 直播
- 內容創作
- 社交媒體
- 數位行銷
- 品牌故事
- 視覺敘事
- 紀錄片
- 廣告

**20. 環境** (10 related keywords)
- 環保
- 永續發展
- 再生能源
- 氣候變遷
- 生態保護
- 綠色生活
- 零廢棄
- 有機農業
- 環境教育
- 碳足跡

### Summary
- **Total First-Level Keywords**: 20
- **Total Second-Level Keywords**: 200 (20 × 10)
- **Total Keywords**: 220

---

## 💪 2. Strengths Questionnaire (天賦問卷)

### Structure
- **5 Questions**: Each question has its own keyword hierarchy
- **2 Levels**: First-level (parent) → Second-level (child)
- **Dynamic Display**: When user selects a first-level keyword, related second-level keywords appear
- **Question-Specific**: Each question has different keywords

### Logic Flow

```
1. User sees: All first-level keywords for current question
2. User clicks: First-level keyword (e.g., "數據分析")
3. System shows: Related second-level keywords (e.g., "數據可視化", "統計分析", etc.)
4. User can select: Both first-level and second-level keywords
5. When no first-level selected: Only show first-level keywords
6. When first-level selected: Show both first-level + related second-level keywords
```

### Question 1: "哪些事情對你來說是「輕而易舉」的？"

#### First-Level Keywords (13 keywords)
1. 數據分析
2. 人際溝通
3. 寫作
4. 邏輯思考
5. 創意表達
6. 組織規劃
7. 技術能力
8. 視覺設計
9. 音樂
10. 運動
11. 語言
12. 教學
13. 領導
14. 協作

#### Second-Level Keywords (Complete hierarchy)

**數據分析** → 數據可視化, 統計分析, 財務分析, 市場研究, 數據挖掘, 商業智能, Excel精通, 數據庫管理

**人際溝通** → 同理心, 傾聽能力, 情緒管理, 衝突解決, 團隊合作, 跨文化溝通, 公開演講, 談判能力

**寫作** → 創意寫作, 技術寫作, 文案寫作, 內容創作, 故事敘述, 邏輯表達, 文字編輯, 學術寫作

**邏輯思考** → 問題解決, 批判性思考, 系統分析, 戰略思考, 決策制定, 風險評估, 流程優化, 質量控制

**創意表達** → 視覺設計, 藝術創作, 創新思維, 概念設計, 品牌策劃, 內容創作, 視頻製作, 動畫製作

**組織規劃** → 項目管理, 時間管理, 資源管理, 流程優化, 供應鏈管理, 運營管理, 戰略規劃, 活動策劃

**技術能力** → 程式設計, 網頁設計, 移動應用開發, 人工智能, 機器學習, 雲計算, 網絡安全, 自動化

**視覺設計** → UI設計, 平面設計, 產品設計, 用戶體驗設計, 界面設計, 品牌設計, 包裝設計, 時尚設計

**音樂** → 作曲, 演奏, 音樂製作, 編曲, 音頻編輯, 音樂教育, 音響工程, DJ

**運動** → 健身, 瑜伽, 球類運動, 戶外活動, 舞蹈, 武術, 體能訓練, 運動教練

**語言** → 多語言能力, 翻譯, 口譯, 語言教學, 語言學習, 跨文化溝通, 語言分析, 語言表達

**教學** → 課程設計, 知識分享, 培訓發展, 輔導, 教育規劃, 學習設計, 教學方法, 教育技術

**領導** → 團隊管理, 決策制定, 戰略思考, 變革管理, 組織發展, 人才培養, 績效評估, 企業文化

**協作** → 團隊合作, 溝通技巧, 衝突解決, 項目協調, 跨部門合作, 網絡建立, 關係維護, 共識建立

---

### Question 2: "從事哪些活動時，會讓你感到精神振奮、充滿活力？"

#### First-Level Keywords (18 keywords)
1. 教學
2. 問題解決
3. 創意設計
4. 領導
5. 協作
6. 學習
7. 挑戰
8. 創新
9. 探索
10. 創造
11. 幫助他人
12. 競爭
13. 表演
14. 運動
15. 藝術創作
16. 研究
17. 創業
18. 社交
19. 冒險
20. 音樂

*(See StrengthsQuestions.swift for complete second-level keywords)*

---

### Question 3: "別人經常稱讚你哪些方面的表現？"

#### First-Level Keywords (40+ keywords)
1. 同理心
2. 溝通表達
3. 耐心
4. 創意
5. 組織能力
6. 專業技能
7. 領導力
8. 解決問題
9. 可靠性
10. 效率
... (and 30+ more)

*(See StrengthsQuestions.swift for complete list)*

---

### Question 4: "你學習什麼類型的事物特別快？"

#### First-Level Keywords (40+ keywords)
1. 語言學習
2. 技術學習
3. 運動技能
4. 音樂
5. 視覺學習
6. 邏輯分析
7. 記憶力
8. 模仿能力
... (and 30+ more)

*(See StrengthsQuestions.swift for complete list)*

---

### Question 5: "回想你感到最有成就感的經歷，這些經歷有什麼共同特質？"

#### First-Level Keywords (8 keywords)
1. 幫助他人
2. 知識分享
3. 問題解決
4. 影響力
5. 成就感
6. 成長
7. 貢獻
8. 價值創造

*(See StrengthsQuestions.swift for complete second-level keywords)*

---

## 💎 3. Values Questionnaire (價值觀問卷)

### Structure
- **No Keywords**: Uses predefined values (CoreValue enum)
- **10 Core Values**: User ranks them 1-10
- **No Hierarchy**: Flat list of values

### All Values

1. 誠信/真實
2. 成長/學習
3. 關愛/連結
4. 自由/自主
5. 成就/貢獻
6. 安全/穩定
7. 創意/創新
8. 公正/公平
9. 健康/平衡
10. 快樂/樂趣

### Logic Flow

```
1. User sees: All 10 values (can be greyed out as "unimportant")
2. User ranks: Values from 1-10 (1 = most important, 10 = least important)
3. User can: Mark values as "unimportant" (greyed out, rank = -1)
4. User can: Add related memories for each value
```

---

## 📝 How to Improve Keywords

### For Interests Questionnaire

1. **Add New First-Level Keywords**:
   ```swift
   "新類別": ["子關鍵詞1", "子關鍵詞2", ...]
   ```

2. **Add More Second-Level Keywords**:
   ```swift
   "設計": ["UI設計", "平面設計", ..., "新關鍵詞"]
   ```

3. **Remove Keywords**: Simply remove from dictionary

4. **Modify Keywords**: Update the string values

### For Strengths Questionnaire

1. **Add Keywords to Existing Questions**:
   - Add to `suggestedKeywords` array
   - Add to `keywordHierarchy` dictionary

2. **Add New Questions**:
   - Create new `StrengthsQuestion` object
   - Add to `questions` array

3. **Modify Hierarchy**:
   - Update `keywordHierarchy` dictionary
   - Add/remove second-level keywords

### Best Practices

1. **Consistency**: Keep keyword naming consistent
2. **Relevance**: Ensure keywords are relevant to the question
3. **Balance**: Don't make hierarchies too deep (max 2 levels)
4. **Coverage**: Cover diverse interests/strengths
5. **Clarity**: Use clear, understandable keywords

---

## 🔧 Code Location

- **Interests**: `LifeLab/LifeLab/Utilities/InterestDictionary.swift`
- **Strengths**: `LifeLab/LifeLab/Utilities/StrengthsQuestions.swift`
- **Values**: `LifeLab/LifeLab/Models/UserProfile.swift` (CoreValue enum)
- **Logic**: `LifeLab/LifeLab/ViewModels/InitialScanViewModel.swift`

---

## 📊 Statistics

### Interests
- First-Level: 20 keywords
- Second-Level: 200 keywords
- Total: 220 keywords

### Strengths
- Questions: 5
- First-Level Keywords: ~100+ (across all questions)
- Second-Level Keywords: ~500+ (across all questions)
- Total: ~600+ keywords

### Values
- Total Values: 10
- No hierarchy

### Grand Total
- **~830+ keywords** across all questionnaires
