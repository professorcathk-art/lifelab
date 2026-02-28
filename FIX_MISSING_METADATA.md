# 修复订阅产品"缺少元資料"问题

## ⚠️ 问题说明

订阅产品状态显示 **"缺少元資料"（Missing Metadata）** 意味着：
- 订阅产品还没有完成所有必需的信息填写
- **必须先完成这些信息，才能提交订阅产品**

**不需要改变 Build 版本号！** Build 版本号（1.0.0）是正确的。

---

## ✅ 修复步骤

### 步骤 1：进入订阅产品编辑页面

1. **App Store Connect** → **My Apps** → **LifeLab**
2. 点击 **Features** 标签（顶部导航）
3. 点击左侧 **In-App Purchases**
4. 点击你的订阅组（LifeLab Premium Subscriptions）
5. 点击每个订阅产品（年付、季付、月付）

### 步骤 2：检查并填写缺失的信息

对**每个订阅产品**（年付、季付、月付），检查以下部分：

---

#### 📋 必需信息检查清单

##### 1. Basic Information（基本信息）
- [ ] **Subscription Reference Name**（订阅参考名称）
  - 例如：`LifeLab Annual Subscription`
- [ ] **Product ID**（产品 ID）
  - ✅ 应该已经填写：`com.resonance.lifelab.annually`（年付）
  - ✅ 应该已经填写：`com.resonance.lifelab.quarterly`（季付）
  - ✅ 应该已经填写：`com.resonance.lifelab.monthly`（月付）
- [ ] **Subscription Duration**（订阅持续时间）
  - 年付：`1 Year`
  - 季付：`3 Months`
  - 月付：`1 Month`

##### 2. Subscription Pricing（订阅定价）
- [ ] **已添加定价**
  - 点击 **Add Subscription Pricing**
  - 选择 **United States**（或其他主要市场）
  - 设置价格：
    - 年付：`$89.99` 或 `$91.08`（$7.59 × 12）
    - 季付：`$29.97`（$9.99 × 3）
    - 月付：`$17.99`
  - 点击 **Next** → **Create**

##### 3. Localization（本地化）- **这是最容易缺失的部分！**

**⚠️ 必须至少添加英文（U.S.）本地化！**

对每个产品，点击 **Add Localization**：

**年付（Annual）产品：**

**English (U.S.):**
- **Display Name（显示名称）：** `LifeLab Annual Subscription` 或 `Annual`
- **Description（描述）：** 
  ```
  Unlock your personalized life blueprint with annual subscription. 
  Save 58% compared to monthly pricing.
  ```

**Chinese (Traditional - Taiwan):**
- **Display Name：** `LifeLab 年付訂閱` 或 `年付`
- **Description：** 
  ```
  解鎖您的個人化生命藍圖，年付訂閱可節省 58% 費用。
  ```

**Chinese (Simplified - China):**
- **Display Name：** `LifeLab 年付订阅` 或 `年付`
- **Description：** 
  ```
  解锁您的个性化生命蓝图，年付订阅可节省 58% 费用。
  ```

**季付（Quarterly）产品：**

**English (U.S.):**
- **Display Name：** `LifeLab Quarterly Subscription` 或 `Quarterly`
- **Description：** 
  ```
  Unlock your personalized life blueprint with quarterly subscription. 
  Save 48% compared to monthly pricing.
  ```

**Chinese (Traditional):**
- **Display Name：** `LifeLab 季付訂閱` 或 `季付`
- **Description：** 
  ```
  解鎖您的個人化生命藍圖，季付訂閱可節省 48% 費用。
  ```

**Chinese (Simplified):**
- **Display Name：** `LifeLab 季付订阅` 或 `季付`
- **Description：** 
  ```
  解锁您的个性化生命蓝图，季付订阅可节省 48% 费用。
  ```

**月付（Monthly）产品：**

**English (U.S.):**
- **Display Name：** `LifeLab Monthly Subscription` 或 `Monthly`
- **Description：** 
  ```
  Unlock your personalized life blueprint with monthly subscription.
  ```

**Chinese (Traditional):**
- **Display Name：** `LifeLab 月付訂閱` 或 `月付`
- **Description：** 
  ```
  解鎖您的個人化生命藍圖，月付訂閱。
  ```

**Chinese (Simplified):**
- **Display Name：** `LifeLab 月付订阅` 或 `月付`
- **Description：** 
  ```
  解锁您的个性化生命蓝图，月付订阅。
  ```

##### 4. Subscription Display Name（订阅显示名称）

在本地化部分下方，有一个 **Subscription Display Name** 字段：

- **English：** `Annual` / `Quarterly` / `Monthly`
- **Chinese (Traditional)：** `年付` / `季付` / `月付`
- **Chinese (Simplified)：** `年付` / `季付` / `月付`

##### 5. Review Information（审核信息）- 可选但推荐

- **Review Notes（审核说明）：** 
  ```
  This is a subscription for LifeLab premium features. 
  Users can unlock their personalized life blueprint after completing the initial questionnaire.
  ```
- **Screenshot（截图）：** 上传订阅页面的截图（可选）

---

### 步骤 3：保存每个产品

1. **填写完所有必需信息后**
2. 点击页面右上角或底部的 **Save** 按钮
3. 等待保存完成
4. **对每个产品重复此过程**（年付、季付、月付）

### 步骤 4：检查状态

保存后，检查每个产品的状态：

1. **回到 In-App Purchases 列表**
2. **查看每个产品的状态**
3. **应该从 "缺少元資料" 变为 "準備提交"（Ready to Submit）**

---

## 🔍 如何找到缺失的信息

### 在订阅产品编辑页面：

1. **查看页面顶部的警告**
   - Apple 通常会显示红色警告，指出缺失的信息
   - 例如："Missing: Display Name" 或 "Missing: Description"

2. **检查每个部分**
   - 滚动页面，检查每个部分
   - 如果有红色警告或感叹号，说明该部分缺失信息

3. **最常见的缺失项：**
   - ❌ 没有添加本地化（Localization）
   - ❌ 没有设置价格（Subscription Pricing）
   - ❌ Display Name 或 Description 为空

---

## ✅ 快速检查清单

对每个订阅产品（年付、季付、月付），确认：

- [ ] **基本信息已填写**
  - [ ] Subscription Reference Name
  - [ ] Product ID（必须与代码中的完全匹配）
  - [ ] Subscription Duration

- [ ] **价格已设置**
  - [ ] 已添加 Subscription Pricing
  - [ ] 已选择市场（至少 United States）
  - [ ] 价格已设置

- [ ] **本地化已添加（至少英文）**
  - [ ] English (U.S.) 已添加
  - [ ] Display Name 已填写
  - [ ] Description 已填写
  - [ ] （可选）中文本地化已添加

- [ ] **Subscription Display Name 已填写**
  - [ ] 英文显示名称
  - [ ] （可选）中文显示名称

- [ ] **已保存**
  - [ ] 点击了 Save 按钮
  - [ ] 状态变为 "準備提交"

---

## 🎯 完成后的下一步

当所有 3 个产品的状态都变为 **"準備提交"（Ready to Submit）** 后：

1. **回到 App Store 标签**
2. **进入版本页面**
3. **现在应该能看到订阅产品选项了**
4. **或者可以直接提交 App 版本**

---

## ❓ 如果还是显示"缺少元資料"

请告诉我：
1. **你看到的具体警告信息是什么？**
   - 例如："Missing: Display Name" 或 "Missing: Description"
2. **你已经填写了哪些信息？**
   - 基本信息？
   - 价格？
   - 本地化？
3. **截图**（如果可能）
   - 订阅产品编辑页面的截图
   - 显示警告信息的部分

这样我可以更准确地帮你定位问题。

---

## 💡 重要提示

**不需要改变 Build 版本号！**
- Build 版本号（1.0.0）是正确的
- 问题在于订阅产品的元数据不完整
- 完成元数据后，状态会变为 "準備提交"
