# App Store Connect 添加訂閱項目完整指南

## 📋 前提条件

在开始之前，确保您已经：
- ✅ 拥有 Apple Developer 账号（$99/年）
- ✅ 已在 App Store Connect 中创建了应用
- ✅ 应用已通过审核（或正在审核中）
- ✅ 已准备好订阅产品的详细信息

## 🚀 步骤 1：进入 App Store Connect

1. **登录 App Store Connect**
   - 访问：https://appstoreconnect.apple.com
   - 使用您的 Apple Developer 账号登录

2. **选择您的应用**
   - 点击 **"我的 App"** (My Apps)
   - 选择 **LifeLab** 应用

## 📦 步骤 2：创建订阅组（Subscription Group）

### 2.1 进入订阅管理页面

1. 在应用页面左侧菜单中，点击 **"App 內購買項目"** (In-App Purchases)
2. 如果这是您第一次添加订阅，会看到提示创建订阅组

### 2.2 创建订阅组

1. 点击 **"管理"** (Manage) 或 **"+"** 按钮
2. 选择 **"訂閱群組"** (Subscription Group)
3. **訂閱群組參考名稱** (Reference Name)：
   - 输入：`LifeLab Premium Subscription`
   - 这个名称只在 App Store Connect 中显示，用户看不到
4. 点击 **"建立"** (Create)

## 💳 步骤 3：添加订阅产品

### 3.1 创建新的订阅产品

1. 在订阅组页面，点击 **"+"** 按钮
2. 选择 **"建立訂閱項目"** (Create Subscription)

### 3.2 填写产品信息

#### 基本信息

1. **產品類型** (Product Type)：
   - 选择 **"自動續訂訂閱"** (Auto-Renewable Subscription)

2. **產品 ID** (Product ID)：
   - 格式：`com.resonance.lifelab.annually`
   - ⚠️ 重要：必须与代码中的 Product ID 完全一致
   - ⚠️ 注意：年付使用 `annually` 而不是 `yearly`
   - 只能使用小写字母、数字、连字符和点号
   - 一旦创建，无法修改

3. **參考名稱** (Reference Name)：
   - 输入：`LifeLab Annual Subscription`
   - 这个名称只在 App Store Connect 中显示

4. **訂閱群組** (Subscription Group)：
   - 选择已创建的订阅群組 ID：`21943118`
   - 或选择订阅群組名称：`LifeLab Premium Subscription`

5. **訂閱持續時間** (Subscription Duration)：
   - 选择：**1 年** (1 Year)

6. **價格** (Price)：
   - 选择价格等级：**USD 89.99/年**
   - 或选择 **"自訂價格"** (Custom Price) 设置特定价格

### 3.3 本地化信息（至少需要中文）

点击 **"本地化"** (Localization) 标签：

1. **顯示名稱** (Display Name)：
   - 输入：`LifeLab 年付訂閱`
   - 这是用户在 App Store 中看到的产品名称

2. **描述** (Description)：
   - 输入：
   ```
   解鎖完整的 LifeLab 功能：
   - 專屬生命藍圖生成
   - 深度自我探索工具
   - 個人化行動計劃
   - 任務管理和追蹤
   - 優先客戶支援
   ```

3. **審查資訊** (Review Information)：
   - **審查備註** (Review Notes)：
     ```
     這是一個年度訂閱產品，用戶可以解鎖完整的 LifeLab 功能。
     訂閱將自動續訂，用戶可以在 App Store 設置中取消。
     ```
   - **審查截圖** (Review Screenshots)：
     - 上传应用内订阅页面的截图（可选但推荐）

### 3.4 訂閱價格和可用性

1. **價格時間表** (Price Schedule)：
   - 选择 **"立即開始"** (Start Immediately)
   - 或设置特定开始日期

2. **可用性** (Availability)：
   - 选择所有国家/地区
   - 或选择特定国家/地区

### 3.5 訂閱優惠（可选）

如果您想提供免费试用或促销价格：

1. **免費試用** (Free Trial)：
   - 选择试用期长度（例如：7 天、14 天、1 个月）
   - 设置试用期开始和结束日期

2. **介紹性優惠** (Introductory Offer)：
   - 设置促销价格（例如：首月 HK$ 1）
   - 设置促销期长度

### 3.6 保存并提交

1. 检查所有信息是否正确
2. 点击 **"儲存"** (Save)
3. 产品状态会显示为 **"準備提交"** (Ready to Submit)

## 📝 步骤 4：添加其他订阅选项（可选）

如果您想添加月付和季付选项：

### 4.1 月付订阅

重复步骤 3，但使用以下信息：
- **產品 ID**：`com.resonance.lifelab.monthly`
- **參考名稱**：`LifeLab Monthly Subscription`
- **訂閱持續時間**：1 個月
- **顯示名稱**：`LifeLab 月付訂閱`

### 4.2 季付订阅

重复步骤 3，但使用以下信息：
- **產品 ID**：`com.resonance.lifelab.quarterly`
- **參考名稱**：`LifeLab Quarterly Subscription`
- **訂閱持續時間**：3 個月
- **顯示名稱**：`LifeLab 季付訂閱`

## ✅ 步骤 5：提交审核

### 5.1 将订阅附加到应用版本

1. 回到应用主页面
2. 进入 **"版本"** (Versions) 或 **"TestFlight"** 标签
3. 选择要提交的版本
4. 在 **"App 內購買項目"** (In-App Purchases) 部分：
   - 点击 **"+"** 按钮
   - 选择您创建的订阅产品
   - 点击 **"完成"** (Done)

### 5.2 提交审核

1. 填写所有必需的应用信息
2. 上传截图和描述
3. 点击 **"提交以供審查"** (Submit for Review)

## 🔍 步骤 6：验证配置

### 6.1 检查 Product ID 匹配

确保代码中的 Product ID 与 App Store Connect 中的完全一致：

```swift
// PaymentService.swift
let productIDs = [
    "com.resonance.lifelab.yearly",
    "com.resonance.lifelab.quarterly",
    "com.resonance.lifelab.monthly"
]
```

### 6.2 测试订阅（使用 Sandbox）

1. 在 App Store Connect 中创建 Sandbox 测试账号
2. 在设备上使用 Sandbox 账号测试购买流程
3. 验证订阅是否正确激活

## 📊 步骤 7：监控和管理

### 7.1 查看订阅状态

1. 在 App Store Connect 中，进入 **"銷售和趨勢"** (Sales and Trends)
2. 查看订阅产品的销售数据
3. 监控订阅续订率

### 7.2 管理订阅

1. **修改价格**：
   - 进入订阅产品页面
   - 点击 **"價格時間表"** (Price Schedule)
   - 添加新的价格计划

2. **暂停订阅**：
   - 在订阅组页面
   - 选择订阅产品
   - 点击 **"暫停"** (Pause)

3. **删除订阅**：
   - ⚠️ 注意：删除后无法恢复
   - 只能删除未提交审核的订阅

## ⚠️ 常见问题和注意事项

### 问题 1：产品状态显示 "缺少元資料" (Missing Metadata)

**解决方案**：
- 确保所有必需字段都已填写
- 检查本地化信息是否完整
- 确保至少有一种语言的显示名称和描述

### 问题 2：Product ID 不匹配

**解决方案**：
- 检查代码中的 Product ID 是否与 App Store Connect 中的完全一致
- 注意大小写（Product ID 必须全小写）
- 确保没有多余的空格或特殊字符

### 问题 3：订阅无法在应用中找到

**解决方案**：
- 确保订阅已附加到应用版本
- 检查订阅状态是否为 "準備提交" 或 "審查中"
- 确保使用正确的 Sandbox 账号测试

### 问题 4：价格显示不正确

**解决方案**：
- 检查价格时间表设置
- 确保选择了正确的货币
- 验证价格等级是否正确

## 📚 参考资源

- [App Store Connect 帮助文档](https://help.apple.com/app-store-connect/)
- [In-App Purchase 指南](https://developer.apple.com/in-app-purchase/)
- [StoreKit 2 文档](https://developer.apple.com/documentation/storekit)

## 🎯 快速检查清单

在提交审核前，确保：

- [ ] 订阅组已创建
- [ ] 所有订阅产品已创建
- [ ] Product ID 与代码中一致
- [ ] 本地化信息完整（至少中文）
- [ ] 价格设置正确
- [ ] 订阅已附加到应用版本
- [ ] 已使用 Sandbox 账号测试
- [ ] 所有必需的应用信息已填写

---

**最后更新**: 2024年
**版本**: 1.0
