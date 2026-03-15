# 重新提交应用指南 - Resubmission Guide

## ✅ Health Check 结果

### Build Status
- ✅ **构建成功**：无错误、无警告
- ✅ **代码质量**：通过检查
- ✅ **价格显示修复**：已修复（Apple Guideline 3.1.2(c)）
- ✅ **货币一致性**：已修复（使用 StoreKit priceFormatStyle）

### 待修改（App Store Connect）
- ⚠️ **应用描述**：需要在 App Store Connect 中修改，明确说明需要订阅

---

## 📋 重新提交步骤

### ⚠️ 重要：是否需要更改 Build Number？

**答案：取决于你的情况**

#### 情况 1：只修改了 Metadata（应用描述）
- ✅ **不需要更改 Build Number**
- ✅ **不需要上传新 Build**
- ✅ **只需要在 App Store Connect 中修改描述**

#### 情况 2：修改了代码（价格显示修复）
- ✅ **需要更改 Build Number**
- ✅ **需要上传新 Build**
- ✅ **需要修改描述**

### 当前 Build Number

根据项目配置：
- **Current Project Version (Build Number)**: `3`
- **Marketing Version (Version Number)**: `1.3.2`

---

## 🚀 重新提交流程（完整版）

### Step 1: 修改 App Store Connect Metadata

#### 1.1 登录 App Store Connect
1. 访问 [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
2. 登录你的开发者账户
3. 选择你的应用（LifeLab）

#### 1.2 修改应用描述
1. 点击 **"App 信息"** → **"描述"**
2. 添加明确的订阅说明（参考 `APP_STORE_DESCRIPTION_FIX.md`）
3. 保存

#### 1.3 检查其他 Metadata
- [ ] 副标题（Subtitle）：如果有，检查是否需要修改
- [ ] 促销文本（Promotional Text）：如果有，检查是否需要修改
- [ ] 截图（Screenshots）：检查是否暗示功能免费

### Step 2: 更新 Build Number（如果需要）

#### 2.1 检查是否需要新 Build

**如果只修改了描述（Metadata）**：
- ✅ **不需要更改 Build Number**
- ✅ **不需要上传新 Build**
- ✅ **直接跳到 Step 3**

**如果修改了代码（价格显示修复）**：
- ✅ **需要更改 Build Number**
- ✅ **需要上传新 Build**
- ✅ **继续 Step 2.2**

#### 2.2 更改 Build Number

**方法 1：在 Xcode 中修改**
1. 打开 Xcode
2. 选择项目 → LifeLab target
3. 进入 **"General"** 标签
4. 找到 **"Version"** 和 **"Build"**
5. **Build** 从 `3` 改为 `4`
6. **Version** 保持不变 `1.3.2`（或改为 `1.3.3` 如果你想要）

**方法 2：在 project.pbxproj 中修改**
```bash
# 当前 Build Number: 3
# 改为: 4
```

**修改位置**：
```
LifeLab/LifeLab.xcodeproj/project.pbxproj
- CURRENT_PROJECT_VERSION = 3;  →  CURRENT_PROJECT_VERSION = 4;
```

#### 2.3 构建新版本
```bash
cd /Users/mickeylau/lifelab
xcodebuild -project LifeLab/LifeLab.xcodeproj \
           -scheme LifeLab \
           -configuration Release \
           -sdk iphoneos \
           archive \
           -archivePath ./build/LifeLab.xcarchive
```

#### 2.4 导出 IPA
```bash
xcodebuild -exportArchive \
           -archivePath ./build/LifeLab.xcarchive \
           -exportPath ./build/export \
           -exportOptionsPlist ExportOptions.plist
```

### Step 3: 上传到 App Store Connect

#### 3.1 使用 Xcode Organizer（推荐）
1. 打开 Xcode
2. **Window** → **Organizer**
3. 选择你的 Archive
4. 点击 **"Distribute App"**
5. 选择 **"App Store Connect"**
6. 按照向导完成上传

#### 3.2 使用命令行（Transporter）
```bash
# 使用 Transporter app 上传
open -a Transporter
# 然后拖拽 IPA 文件到 Transporter
```

#### 3.3 使用 altool（命令行）
```bash
xcrun altool --upload-app \
             --type ios \
             --file ./build/export/LifeLab.ipa \
             --apiKey YOUR_API_KEY \
             --apiIssuer YOUR_ISSUER_ID
```

### Step 4: 在 App Store Connect 中提交

#### 4.1 选择 Build
1. 登录 App Store Connect
2. 选择你的应用
3. 进入 **"版本"** 或 **"Versions"**
4. 点击 **"+ Version"** 或选择现有版本
5. 在 **"Build"** 部分，点击 **"+"**
6. 选择刚上传的新 Build（Build Number 4）
7. 点击 **"Done"**

#### 4.2 填写版本信息
- **版本号**：`1.3.2`（或 `1.3.3`）
- **构建版本**：`4`（新 Build Number）
- **描述**：已修改（包含订阅说明）

#### 4.3 回答 App Review 问题
在 **"App Review Information"** 部分：
- **联系信息**：填写你的联系信息
- **备注**：可以添加说明

#### 4.4 提交审核
1. 检查所有信息
2. 点击 **"提交以供审核"** 或 **"Submit for Review"**
3. 确认提交

### Step 5: 给 Apple 的回复（可选但推荐）

在 App Review 回复中，可以说明：

```
我们已经解决了以下问题：

1. 【Guideline 2.3.2 - Metadata】
   - 已更新应用描述，明确说明应用需要订阅才能使用
   - 列出了所有需要订阅的功能
   - 包含了订阅价格和周期信息
   - 说明了自动续订机制

2. 【Guideline 3.1.2(c) - Subscription Pricing】（如果上传了新 Build）
   - 已修复价格显示问题
   - 账单金额现在是最突出的显示元素
   - 月度等效价格显示为次要信息
   - 使用 StoreKit 的实际价格，支持多货币

应用现在完全符合 Apple 的审核指南要求。
```

---

## 📊 两种情况的对比

### 情况 A：只修改 Metadata（应用描述）

| 步骤 | 操作 | 是否需要 |
|------|------|----------|
| 修改描述 | App Store Connect | ✅ 必须 |
| 更改 Build Number | Xcode | ❌ 不需要 |
| 上传新 Build | Xcode/Transporter | ❌ 不需要 |
| 选择 Build | App Store Connect | ❌ 不需要（使用现有 Build） |
| 提交审核 | App Store Connect | ✅ 必须 |

**时间**：5-10 分钟  
**难度**：简单

### 情况 B：修改了代码 + Metadata

| 步骤 | 操作 | 是否需要 |
|------|------|----------|
| 修改描述 | App Store Connect | ✅ 必须 |
| 更改 Build Number | Xcode | ✅ 必须 |
| 上传新 Build | Xcode/Transporter | ✅ 必须 |
| 选择 Build | App Store Connect | ✅ 必须（选择新 Build） |
| 提交审核 | App Store Connect | ✅ 必须 |

**时间**：30-60 分钟  
**难度**：中等

---

## 🎯 推荐流程（根据你的情况）

### 你的情况分析

根据之前的修复：
- ✅ **价格显示修复**：已修改代码（使用 StoreKit priceFormatStyle）
- ⚠️ **应用描述**：需要在 App Store Connect 中修改

**结论**：你需要 **情况 B**（修改代码 + Metadata）

### 推荐步骤

1. **先修改 App Store Connect 描述**（5分钟）
   - 明确说明需要订阅
   - 列出订阅功能
   - 包含价格信息

2. **更改 Build Number**（2分钟）
   - 从 `3` 改为 `4`
   - 在 Xcode 中修改

3. **构建并上传新 Build**（20-30分钟）
   - 使用 Xcode Archive
   - 上传到 App Store Connect

4. **提交审核**（5分钟）
   - 选择新 Build（Build 4）
   - 填写版本信息
   - 提交审核

5. **给 Apple 回复**（可选）
   - 说明已修复的问题

---

## ✅ 检查清单

提交前，确保：

### App Store Connect
- [ ] 应用描述已修改，明确说明需要订阅
- [ ] 副标题已检查（如果有）
- [ ] 促销文本已检查（如果有）
- [ ] 截图已检查（如果提到功能）

### Build
- [ ] Build Number 已更新（从 3 改为 4）
- [ ] 新 Build 已成功构建
- [ ] 新 Build 已上传到 App Store Connect
- [ ] 新 Build 已通过处理（Processing）

### 提交
- [ ] 选择了正确的 Build（Build 4）
- [ ] 版本信息已填写
- [ ] App Review 信息已填写
- [ ] 已点击"提交以供审核"

---

## 📝 快速命令参考

### 检查当前 Build Number
```bash
grep "CURRENT_PROJECT_VERSION" LifeLab/LifeLab.xcodeproj/project.pbxproj
```

### 更改 Build Number（如果需要）
```bash
# 在 Xcode 中修改，或手动编辑 project.pbxproj
# CURRENT_PROJECT_VERSION = 3; → CURRENT_PROJECT_VERSION = 4;
```

### 构建 Archive
```bash
xcodebuild -project LifeLab/LifeLab.xcodeproj \
           -scheme LifeLab \
           -configuration Release \
           -sdk iphoneos \
           archive \
           -archivePath ./build/LifeLab.xcarchive
```

---

## 🎉 总结

**你的情况**：
- ✅ 需要修改 App Store Connect 描述
- ✅ 需要更改 Build Number（从 3 改为 4）
- ✅ 需要上传新 Build
- ✅ 需要提交审核

**预计时间**：30-60 分钟  
**难度**：中等

**最重要**：先修改描述，然后上传新 Build，最后提交审核！
