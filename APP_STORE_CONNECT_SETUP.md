# App Store Connect 设置指南

## 问题：是否需要创建新应用？

### ✅ **是的，您需要创建新应用**

在 App Store Connect 中创建应用是必需的，因为：
1. **创建订阅产品**：必须在应用下创建
2. **应用审核**：需要应用信息才能提交审核
3. **测试环境**：Sandbox 测试需要应用存在

---

## 📋 创建应用的步骤

### Step 1: 登录 App Store Connect

1. 访问：https://appstoreconnect.apple.com
2. 使用您的 **Apple Developer 账号**登录
   - 需要付费的 Apple Developer Program（$99/年）
   - 如果没有，需要先注册

### Step 2: 创建新应用

1. 点击 **"我的 App"**
2. 点击左上角 **"+"** → **"新 App"**

### Step 3: 填写应用信息

#### 必需信息：

**平台**：
- ✅ 选择 **iOS**

**名称**：
- 例如：`LifeLab` 或 `生命藍圖`

**主要语言**：
- 选择 **简体中文** 或 **繁体中文**

**Bundle ID**：
- 选择 **`com.resonance.lifelab`**
- 如果列表中没有，需要先在 **Certificates, Identifiers & Profiles** 中创建 App ID

**SKU**：
- 唯一标识符，例如：`lifelab-001`

**用户访问权限**：
- 选择 **"完整访问权限"**（因为需要用户数据）

### Step 4: 创建 App ID（如果还没有）

如果 Bundle ID `com.resonance.lifelab` 不存在：

1. 访问：https://developer.apple.com/account/resources/identifiers/list
2. 点击 **"+"** → **"App IDs"**
3. 选择 **"App"**
4. 填写：
   - **描述**：LifeLab
   - **Bundle ID**：`com.resonance.lifelab`
   - **Capabilities**：启用 **"Sign In with Apple"** 和 **"In-App Purchase"**
5. 点击 **"Continue"** → **"Register"**

### Step 5: 保存应用

1. 填写完所有信息后
2. 点击 **"创建"**
3. 应用创建成功！

---

## ⚠️ 重要注意事项

### 1. Apple Developer Program

**需要付费账号**：
- 费用：$99/年（美国）或等值当地货币
- 如果没有，需要先注册

**免费账号限制**：
- ❌ 无法在 App Store Connect 创建应用
- ❌ 无法创建订阅产品
- ✅ 可以在 Xcode 中测试（但无法测试真实支付）

### 2. Bundle ID 必须匹配

- Xcode 中的 Bundle ID：`com.resonance.lifelab`
- App Store Connect 中的 Bundle ID：`com.resonance.lifelab`
- **必须完全一致！**

### 3. 应用状态

创建应用后，状态为 **"准备提交"**：
- 可以创建订阅产品
- 可以测试 Sandbox 环境
- 需要填写更多信息才能提交审核

---

## 🎯 创建应用后的下一步

### 1. 创建订阅产品
- 在应用下创建三个订阅产品
- 参考 `PAYMENT_SETUP_GUIDE.md`

### 2. 创建 Sandbox 测试账户
- 用于测试支付功能

### 3. 测试应用
- 在真实设备上测试支付流程

---

## 📚 参考资源

### Apple 官方文档
- [App Store Connect 帮助](https://help.apple.com/app-store-connect/)
- [创建 App ID](https://developer.apple.com/help/app-store-connect/manage-apps/create-an-app-record)

### 相关指南
- `PAYMENT_SETUP_GUIDE.md` - 支付设置指南
- `APPLE_SIGN_IN_ERROR_1000_FIX.md` - Apple Sign In 设置

---

## ✅ 总结

**是的，您需要创建新应用！**

步骤：
1. ✅ 登录 App Store Connect
2. ✅ 创建新应用
3. ✅ 填写应用信息（Bundle ID: `com.resonance.lifelab`）
4. ✅ 创建订阅产品
5. ✅ 测试支付功能

完成这些步骤后，您的应用就可以使用支付功能了！🎉
