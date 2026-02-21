# Apple Sign In 与 Supabase 配置修复指南

## 🔴 问题

错误信息：
```
Unacceptable audience in id_token: [com.resonance.lifelab]
```

**原因**：
- Apple Sign In 默认使用 **Bundle ID** (`com.resonance.lifelab`) 作为 audience
- Supabase 期望的是 **Service ID**（例如：`com.resonance.lifelab.service`）
- Bundle ID 和 Service ID 不匹配导致验证失败

## ✅ 解决方案

### 方案 1：在 Supabase 中使用 Bundle ID（推荐，最简单）

**步骤**：

1. **登录 Supabase Dashboard**
   - 访问 https://app.supabase.com
   - 选择你的项目

2. **配置 Apple OAuth**
   - 左侧菜单：**Authentication** → **Providers**
   - 找到 **Apple** 并点击

3. **设置 Service ID**
   - **Service ID**: 输入你的 **Bundle ID** `com.resonance.lifelab`
   - **Secret Key**: 从 Apple Developer Portal 下载的 `.p8` 密钥文件内容
   - **Redirect URL**: `https://inlzhosqbccyynofbmjt.supabase.co/auth/v1/callback`
   - 点击 **Save**

4. **在 Apple Developer Portal 配置**
   - 登录 https://developer.apple.com/account
   - **Certificates, Identifiers & Profiles** → **Identifiers**
   - 找到你的 **App ID** (`com.resonance.lifelab`)
   - 确保 **Sign In with Apple** 功能已启用
   - **Services** → **Sign In with Apple** → **Configure**
   - 添加 **Redirect URL**: `https://inlzhosqbccyynofbmjt.supabase.co/auth/v1/callback`
   - 保存

### 方案 2：创建并使用 Service ID（更标准，但需要额外配置）

**步骤**：

1. **在 Apple Developer Portal 创建 Service ID**
   - 登录 https://developer.apple.com/account
   - **Certificates, Identifiers & Profiles** → **Identifiers**
   - 点击 **+** → 选择 **Services IDs** → **Continue**
   - **Description**: `LifeLab Supabase Service`
   - **Identifier**: `com.resonance.lifelab.service`（或任何你喜欢的格式）
   - 点击 **Continue** → **Register**

2. **配置 Service ID**
   - 选择刚创建的 Service ID
   - 勾选 **Sign In with Apple**
   - 点击 **Configure**
   - **Primary App ID**: 选择你的 App ID (`com.resonance.lifelab`)
   - **Website URLs**:
     - **Domains**: `inlzhosqbccyynofbmjt.supabase.co`
     - **Return URLs**: `https://inlzhosqbccyynofbmjt.supabase.co/auth/v1/callback`
   - 点击 **Save** → **Continue** → **Save**

3. **在 Supabase 中配置**
   - Supabase Dashboard → **Authentication** → **Providers** → **Apple**
   - **Service ID**: `com.resonance.lifelab.service`（你刚创建的）
   - **Secret Key**: 从 Apple Developer Portal 下载的 `.p8` 密钥文件内容
   - **Redirect URL**: `https://inlzhosqbccyynofbmjt.supabase.co/auth/v1/callback`
   - 点击 **Save**

4. **修改代码（如果需要）**
   - 如果使用方案 2，需要在 iOS 代码中指定 Service ID
   - 但通常 iOS 应用使用 Bundle ID 即可，Supabase 会自动处理

## 🔑 获取 Secret Key (.p8 文件)

1. **在 Apple Developer Portal**
   - **Certificates, Identifiers & Profiles** → **Keys**
   - 点击 **+** 创建新密钥
   - **Key Name**: `Supabase Apple Sign In`
   - 勾选 **Sign In with Apple**
   - 点击 **Continue** → **Register**

2. **下载密钥**
   - 点击刚创建的密钥
   - 点击 **Download**（只能下载一次！）
   - 保存 `.p8` 文件

3. **获取 Key ID**
   - 在密钥详情页面可以看到 **Key ID**（例如：`ABC123DEF4`）

4. **在 Supabase 中配置**
   - **Secret Key**: 打开 `.p8` 文件，复制全部内容（包括 `-----BEGIN PRIVATE KEY-----` 和 `-----END PRIVATE KEY-----`）
   - **Key ID**: 输入 Key ID

## 📝 验证配置

### 检查清单

- [ ] Apple Developer Portal 中 App ID 已启用 Sign In with Apple
- [ ] Service ID（或使用 Bundle ID）已配置 Redirect URL
- [ ] Supabase Dashboard 中 Apple OAuth 已启用
- [ ] Supabase 中 Service ID 与 Apple Developer Portal 一致
- [ ] Secret Key 已正确配置
- [ ] Redirect URL 匹配

### 测试步骤

1. **在 iOS 应用中测试**
   - 点击 Apple Sign In 按钮
   - 完成登录流程
   - 检查控制台日志

2. **检查 Supabase**
   - Supabase Dashboard → **Authentication** → **Users**
   - 应该能看到新创建的用户

3. **检查数据同步**
   - Supabase Dashboard → **Table Editor** → **user_profiles**
   - 应该能看到用户数据

## ⚠️ 常见问题

### 问题 1: "Unacceptable audience" 仍然出现

**解决方案**：
- 确保 Supabase 中的 Service ID 与 Apple Developer Portal 中的完全一致
- 如果使用 Bundle ID，确保 Supabase 中也使用 Bundle ID
- 清除应用缓存并重新登录

### 问题 2: Redirect URL 不匹配

**解决方案**：
- 确保 Apple Developer Portal 中的 Redirect URL 与 Supabase 中的完全一致
- 格式：`https://[your-project-ref].supabase.co/auth/v1/callback`
- 注意：必须以 `https://` 开头，不能有尾随斜杠

### 问题 3: Secret Key 无效

**解决方案**：
- 确保复制了完整的 `.p8` 文件内容（包括 BEGIN/END 标记）
- 确保 Key ID 正确
- 如果密钥已删除，需要创建新密钥并重新配置

## 🎯 推荐方案

**使用方案 1（Bundle ID）**，因为：
- ✅ 更简单，不需要创建额外的 Service ID
- ✅ iOS 应用默认使用 Bundle ID
- ✅ Supabase 支持使用 Bundle ID
- ✅ 减少配置步骤

## 📚 参考资源

- [Supabase Apple OAuth 文档](https://supabase.com/docs/guides/auth/social-login/auth-apple)
- [Apple Sign In with Apple 文档](https://developer.apple.com/sign-in-with-apple/)
- [Apple Service ID 配置指南](https://developer.apple.com/documentation/sign_in_with_apple/sign_in_with_apple_rest_api)

---

**最后更新**: 2024年
**版本**: 1.0
