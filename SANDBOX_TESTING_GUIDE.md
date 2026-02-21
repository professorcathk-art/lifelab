# Sandbox 测试账号设置指南

## ❌ 错误信息

```
You are not authorised to make purchases of this in-app in sandbox at this time.
This apple account does not have permission to make in-app purchases
```

## 🔍 问题原因

这个错误通常是因为：
1. **使用了真实的 Apple ID** 而不是 Sandbox 测试账号
2. **Sandbox 测试账号未正确创建或配置**
3. **设备上登录的是真实 Apple ID**，而不是 Sandbox 账号

---

## ✅ 解决方案

### 步骤 1: 创建 Sandbox 测试账号

1. **登录 App Store Connect**
   - 前往 [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
   - 登录您的开发者账号

2. **创建 Sandbox 测试账号**
   - 进入 **用户和访问** → **沙盒技术测试员**
   - 点击 **+** 按钮添加新测试员
   - 填写信息：
     - **名字**: 测试（例如：Test User）
     - **姓氏**: User
     - **电子邮件**: 使用一个**不存在的邮箱地址**（例如：`testuser1@example.com`）
     - **密码**: 设置一个密码（至少 8 个字符）
     - **国家或地区**: 选择您的目标市场
   - 点击 **创建**

3. **重要提醒**
   - Sandbox 测试账号的邮箱**不需要真实存在**
   - 可以使用任何格式的邮箱（例如：`test1@test.com`）
   - 每个 App Store Connect 账号最多可以创建 2000 个 Sandbox 测试账号

---

### 步骤 2: 在设备上使用 Sandbox 账号

#### 方法 A: 在设置中退出真实 Apple ID（推荐）

1. **退出真实 Apple ID**
   - 打开 **设置** → **App Store**
   - 点击您的 Apple ID
   - 选择 **退出登录**

2. **使用 Sandbox 账号登录**
   - 打开您的应用
   - 尝试进行购买
   - 系统会提示登录
   - **使用 Sandbox 测试账号登录**（不是真实 Apple ID）

3. **验证登录**
   - 登录后，系统会显示 "Sandbox" 标识
   - 现在可以测试购买了

#### 方法 B: 在应用内登录（如果应用支持）

如果您的应用有登录功能，确保使用 Sandbox 测试账号登录。

---

### 步骤 3: 测试购买流程

1. **确保产品已配置**
   - App Store Connect → **App 內購買項目**
   - 检查产品状态为 **準備提交** 或 **已批准**

2. **在真实设备上测试**
   - ⚠️ **重要**: Sandbox 测试必须在**真实设备**上进行
   - 模拟器无法测试 Sandbox 购买

3. **测试步骤**
   - 打开应用
   - 进入支付页面
   - 点击 "開啟我的理想人生"
   - 使用 Sandbox 测试账号登录
   - 完成购买测试

---

## 🔧 常见问题排查

### Q1: 仍然显示 "not authorised" 错误？

**检查清单**:
- [ ] 是否使用了 Sandbox 测试账号（不是真实 Apple ID）？
- [ ] Sandbox 测试账号是否在 App Store Connect 中正确创建？
- [ ] 是否在真实设备上测试（不是模拟器）？
- [ ] 是否在设置中退出了真实 Apple ID？
- [ ] 产品状态是否为 "準備提交" 或 "已批准"？

### Q2: 如何确认使用的是 Sandbox 账号？

**检查方法**:
- 购买时，系统会显示 "Sandbox" 标识
- 如果看到 "Sandbox" 字样，说明使用的是 Sandbox 账号
- 如果没有看到，说明使用的是真实 Apple ID

### Q3: 可以在模拟器上测试吗？

**答案**: ❌ 不可以
- Sandbox 购买测试**必须在真实设备**上进行
- 模拟器无法连接到 Sandbox 环境
- 使用真实 iPhone 或 iPad 进行测试

### Q4: Sandbox 购买会收费吗？

**答案**: ✅ 不会
- Sandbox 购买是**完全免费的**
- 不会产生任何实际费用
- 仅用于测试目的

### Q5: 如何重置 Sandbox 测试账号？

**方法**:
- 在 App Store Connect 中删除并重新创建 Sandbox 测试账号
- 或者在设备上退出 Sandbox 账号，重新登录

---

## 📋 测试检查清单

在测试购买前，确保：

- [ ] **Sandbox 测试账号已创建**
  - App Store Connect → 用户和访问 → 沙盒技术测试员
  - 已创建至少一个测试账号

- [ ] **设备准备**
  - 使用真实 iPhone 或 iPad（不是模拟器）
  - 已在设置中退出真实 Apple ID

- [ ] **产品配置**
  - IAP 产品状态为 "準備提交" 或 "已批准"
  - Product ID 匹配：`com.resonance.lifelab.yearly`

- [ ] **应用状态**
  - 应用已安装到设备上
  - 应用版本包含 IAP 功能

- [ ] **测试流程**
  - 打开应用
  - 进入支付页面
  - 点击购买按钮
  - 使用 Sandbox 测试账号登录
  - 完成购买测试

---

## 🎯 快速测试步骤

1. **创建 Sandbox 测试账号**（App Store Connect）
   ```
   用户和访问 → 沙盒技术测试员 → + → 填写信息 → 创建
   ```

2. **在设备上退出真实 Apple ID**
   ```
   设置 → App Store → Apple ID → 退出登录
   ```

3. **打开应用并测试购买**
   ```
   打开应用 → 支付页面 → 点击购买 → 使用 Sandbox 账号登录
   ```

4. **验证购买成功**
   ```
   检查是否显示 "Sandbox" 标识
   完成购买流程
   验证蓝图生成功能
   ```

---

## ⚠️ 重要提醒

1. **Sandbox 测试账号与真实 Apple ID 不同**
   - Sandbox 账号仅用于测试
   - 不能用于真实购买
   - 邮箱不需要真实存在

2. **必须在真实设备上测试**
   - 模拟器不支持 Sandbox 购买
   - 使用真实 iPhone 或 iPad

3. **产品状态很重要**
   - 如果产品状态为 "Draft"，可能无法测试
   - 确保产品状态为 "準備提交" 或 "已批准"

4. **测试环境限制**
   - Sandbox 环境可能与生产环境略有不同
   - 某些功能可能在 Sandbox 中不可用

---

## 📞 如果仍然无法解决

如果按照上述步骤操作后仍然无法测试，请检查：

1. **App Store Connect 配置**
   - 确保 IAP 产品已添加到应用提交中
   - 确保产品信息完整（Display Name, Description, Price）

2. **开发者账号状态**
   - 确保开发者账号处于活跃状态
   - 确保已签署最新协议

3. **联系 Apple 支持**
   - 如果问题持续，可以联系 Apple Developer Support
   - 提供错误信息和测试步骤

---

**现在按照步骤操作，应该可以成功测试 Sandbox 购买了！** 🚀
