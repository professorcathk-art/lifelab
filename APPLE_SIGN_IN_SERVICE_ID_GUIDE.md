# 创建 Service ID - 详细步骤

## 📋 当前配置信息

基于您的项目：
- **Bundle ID**: `com.resonance.lifelab`
- **App ID**: `com.resonance.lifelab`
- **Service ID**: `com.resonance.lifelab.service`（即将创建）
- **Supabase Return URL**: `https://inlzhosqbccyynofbmjt.supabase.co/auth/v1/callback`

---

## ✅ Step 2: 创建 Service ID

### 2.1 进入 Service IDs

1. 在 **Apple Developer** 网站
2. 点击左侧 **Identifiers**
3. 点击右上角 **+** 按钮

### 2.2 选择 Service IDs

1. 选择 **Services IDs**（不是 App IDs）
2. 点击 **Continue**

### 2.3 填写 Service ID 信息

1. **Description**: 
   ```
   LifeLab Service
   ```

2. **Identifier**: 
   ```
   com.resonance.lifelab.service
   ```
   ⚠️ **重要**: 必须以 `.service` 结尾

3. 点击 **Continue**

### 2.4 启用 Sign In with Apple

1. 在 **Capabilities** 部分：
   - ✅ **勾选 Sign In with Apple**
2. 点击 **Configure** 按钮（在 Sign In with Apple 旁边）

### 2.5 配置 Sign In with Apple

#### Primary App ID
- **选择**: `com.resonance.lifelab`（这是您刚创建的 App ID）
- 从下拉菜单中选择

#### Return URLs
- 点击 **+** 添加 URL
- 输入：
  ```
  https://inlzhosqbccyynofbmjt.supabase.co/auth/v1/callback
  ```
- 点击 **Save**

### 2.6 完成注册

1. 检查信息无误
2. 点击 **Continue**
3. 点击 **Register**

✅ **完成！您现在有了 Service ID: `com.resonance.lifelab.service`**

---

## 📝 配置检查清单

创建 Service ID 后，确保：

- [ ] Service ID: `com.resonance.lifelab.service`
- [ ] Description: `LifeLab Service`
- [ ] ✅ Sign In with Apple 已启用
- [ ] Primary App ID: `com.resonance.lifelab`
- [ ] Return URL: `https://inlzhosqbccyynofbmjt.supabase.co/auth/v1/callback`

---

## 🔑 重要信息（保存备用）

创建 Service ID 后，您将需要：

1. **Client ID**（用于 Supabase 配置）:
   ```
   com.resonance.lifelab.service
   ```

2. **Return URL**（已在 Service ID 中配置）:
   ```
   https://inlzhosqbccyynofbmjt.supabase.co/auth/v1/callback
   ```

---

## ⚠️ 常见问题

### Q: Service ID 的 Identifier 必须是什么格式？
A: 格式为：`{您的AppID}.service`
   - 例如：`com.resonance.lifelab.service`

### Q: Return URL 可以添加多个吗？
A: 可以，但 Supabase 只需要一个：
   ```
   https://inlzhosqbccyynofbmjt.supabase.co/auth/v1/callback
   ```

### Q: 如果 Service ID 已存在怎么办？
A: 直接编辑现有的 Service ID，确保：
   - Sign In with Apple 已启用
   - Return URL 已配置
   - Primary App ID 已关联

---

## 🎯 下一步

创建 Service ID 后，您需要：

1. ✅ **创建 Key 并生成 Secret**（用于 Supabase）
2. ✅ **在 Supabase 中配置 Apple Sign In**
   - Client ID: `com.resonance.lifelab.service`
   - Client Secret: （从 Key 生成）

---

## 📚 相关文档

- `APPLE_SIGN_IN_STEP_BY_STEP.md` - 完整步骤指南
- `APPLE_SIGN_IN_SUPABASE_CONFIG.md` - Supabase 配置说明
- `BUNDLE_ID_UPDATE.md` - Bundle ID 更新记录
