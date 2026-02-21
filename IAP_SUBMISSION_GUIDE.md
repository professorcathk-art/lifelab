# In-App Purchase 产品提交指南

## 您的情况

- **产品名称**: LifeLab Yearly Subscription
- **Product ID**: `com.resonance.lifelab.yearly` ✅ (与代码匹配)
- **Apple ID**: 6759212702
- **当前状态**: Draft / 準備提交

## 为什么状态是 "Draft"？

**这是正常的！** In-App Purchase 产品需要与应用一起提交审核，不能单独上线。

根据 [Apple 官方文档](https://developer.apple.com/help/app-store-connect/reference/in-app-purchases-and-subscriptions/in-app-purchase-information)：

> In-App Purchase 产品必须与应用版本一起提交审核。产品状态会保持为 "Draft" 或 "準備提交" 直到应用审核通过。

## 如何让 IAP 产品上线？

### 步骤 1：确保 IAP 产品信息完整

在 App Store Connect → **App 內購買項目** → 选择您的产品，检查：

- [x] **Reference Name**: LifeLab Yearly Subscription ✅
- [x] **Product ID**: com.resonance.lifelab.yearly ✅
- [ ] **Display Name** (显示名称): 必须填写（至少 2 个字符，最多 30 个字符）
- [ ] **Description** (描述): 必须填写（最多 45 个字符）
- [ ] **Price** (价格): 必须设置
- [ ] **Subscription Group** (订阅组): 如果是首次创建，需要创建订阅组
- [ ] **Review Notes** (审核备注): 可选，但建议填写（最多 4000 字符）
- [ ] **App Review Screenshot** (审核截图): 必须上传（显示订阅内容）

### 步骤 2：将 IAP 产品添加到应用提交

1. **进入应用提交页面**:
   - App Store Connect → **我的 App** → **LifeLab**
   - 点击 **App Store** → **App 審核** (或创建新版本)

2. **添加 IAP 产品**:
   - 在提交页面，找到 **In-App Purchases** 部分
   - 点击 **+** 或 **添加 In-App Purchase**
   - 选择您的产品: **LifeLab Yearly Subscription** (Apple ID: 6759212702)
   - 点击 **完成**

3. **检查产品状态**:
   - 产品状态应该变为 **準備提交** (Ready to Submit)
   - 如果显示 **缺少元資料** (Missing Metadata)，请完成步骤 1 中的必填项

### 步骤 3：提交应用审核

1. **完成应用信息**:
   - 确保应用版本信息完整
   - 上传构建版本
   - 填写所有必填信息

2. **提交审核**:
   - 点击 **提交以供審核** (Submit for Review)
   - **IAP 产品会与应用一起提交审核**

3. **等待审核**:
   - Apple 会同时审核应用和 IAP 产品
   - 审核通过后，**应用和 IAP 产品会同时上线**

## 重要提醒

### ❌ 不需要等待应用先审核通过
- IAP 产品**必须与应用一起提交**，不能单独提交
- 应用和 IAP 产品会**同时审核**，同时上线

### ✅ 产品状态说明

- **Draft** (草稿): 产品信息不完整，需要填写必填项
- **準備提交** (Ready to Submit): 产品信息完整，可以添加到应用提交中
- **等待審核** (Waiting for Review): 已添加到应用提交，等待 Apple 审核
- **審核中** (In Review): Apple 正在审核
- **已批准** (Approved): 审核通过，产品已上线
- **已拒絕** (Rejected): 审核被拒，需要修改后重新提交

### 📋 检查清单

在提交前，确保：

- [ ] IAP 产品的 **Display Name** 已填写（中文：例如 "LifeLab 年度訂閱"）
- [ ] IAP 产品的 **Description** 已填写（中文：例如 "解鎖完整功能，包括 AI 生命藍圖生成和行動計劃"）
- [ ] IAP 产品的 **Price** 已设置（选择价格等级）
- [ ] IAP 产品的 **Subscription Group** 已创建（如果是首次创建订阅）
- [ ] IAP 产品的 **App Review Screenshot** 已上传（显示订阅内容）
- [ ] IAP 产品已添加到应用提交中
- [ ] 应用版本信息完整
- [ ] 应用构建版本已上传
- [ ] 已回复 Apple 的审核问题（使用 `APPLE_REVIEW_RESPONSE_FINAL.txt`）

## 常见问题

### Q: 为什么我不能单独提交 IAP 产品？
**A**: Apple 要求 IAP 产品必须与应用一起提交审核，这是为了确保产品功能与应用一致。

### Q: 产品状态一直是 "Draft"，怎么办？
**A**: 检查是否填写了所有必填项（Display Name, Description, Price, Screenshot）。

### Q: 产品显示 "缺少元資料"，怎么办？
**A**: 点击产品，检查哪些字段是红色的（必填但未填写），完成这些字段。

### Q: 应用审核通过后，IAP 产品会自动上线吗？
**A**: 是的，如果 IAP 产品与应用一起提交审核，审核通过后会同时上线。

### Q: 我可以先提交应用，稍后再添加 IAP 产品吗？
**A**: 可以，但需要创建新版本并重新提交审核。建议第一次提交时就包含 IAP 产品。

## 下一步操作

1. **完成 IAP 产品信息**:
   - 填写 Display Name（中文）
   - 填写 Description（中文）
   - 设置价格
   - 创建订阅组（如果需要）
   - 上传审核截图

2. **创建应用版本**:
   - 上传新构建版本（参考 `UPLOAD_NEW_BUILD.md`）
   - 等待构建版本处理完成

3. **添加 IAP 产品到提交**:
   - 在应用提交页面添加 IAP 产品
   - 检查产品状态变为 "準備提交"

4. **提交审核**:
   - 回复 Apple 的问题（使用 `APPLE_REVIEW_RESPONSE_FINAL.txt`）
   - 确保 App Privacy 信息已更新
   - 点击 **提交以供審核**

---

**参考文档**: [Apple In-App Purchase Information](https://developer.apple.com/help/app-store-connect/reference/in-app-purchases-and-subscriptions/in-app-purchase-information)
