# Supabase Apple Sign In 配置修复指南

## 🔍 问题诊断

从console log可以看到以下错误：
```
❌ Apple Sign In Supabase error: OAuth error: {"error":"invalid request","error_description":"Unacceptable audience in id_token: [com.resonance.lifelab]"}
```

**问题原因：**
- Supabase期望接收的是**Service ID**，但实际收到的是**Bundle ID** (`com.resonance.lifelab`)
- Apple Sign In的OAuth配置不正确

## ✅ 解决方案

### 步骤 1: 确认Service ID

1. 登录 [Apple Developer Portal](https://developer.apple.com/account/)
2. 进入 **Certificates, Identifiers & Profiles**
3. 点击 **Identifiers** → **Services IDs**
4. 找到您的Service ID（格式应该是：`com.resonance.lifelab.service` 或类似）
5. **记录下完整的Service ID**

### 步骤 2: 配置Supabase Apple OAuth

1. 登录 [Supabase Dashboard](https://supabase.com/dashboard)
2. 选择您的项目
3. 进入 **Authentication** → **Providers**
4. 找到 **Apple** 并点击配置
5. **重要配置项：**

   **Service ID (Client ID):**
   - 输入您的**Service ID**（不是Bundle ID）
   - 例如：`com.resonance.lifelab.service`
   
   **Secret Key:**
   - 使用之前生成的JWT Secret Key
   - 格式：`-----BEGIN PRIVATE KEY-----...-----END PRIVATE KEY-----`
   
   **Redirect URL:**
   - 格式：`https://[your-project-ref].supabase.co/auth/v1/callback`
   - 例如：`https://inlzhosqbccyynofbmjt.supabase.co/auth/v1/callback`

### 步骤 3: 验证Apple Developer配置

确保在Apple Developer Portal中：

1. **Service ID配置：**
   - 已启用 **Sign In with Apple**
   - **Domains and Subdomains** 已添加：
     - `inlzhosqbccyynofbmjt.supabase.co`
   - **Return URLs** 已添加：
     - `https://inlzhosqbccyynofbmjt.supabase.co/auth/v1/callback`

2. **App ID配置：**
   - Bundle ID: `com.resonance.lifelab`
   - 已启用 **Sign In with Apple**

### 步骤 4: 测试

1. 重新运行app
2. 尝试Apple Sign In
3. 检查console log，应该看到：
   ```
   ✅ Apple Sign In successful
   ✅ Supabase session created
   ✅ Data syncing to Supabase
   ```

## 🔧 如果仍然失败

### 检查清单：

- [ ] Service ID格式正确（不是Bundle ID）
- [ ] Service ID在Apple Developer Portal中已启用Sign In with Apple
- [ ] Supabase中的Service ID与Apple Developer Portal中的完全一致
- [ ] Redirect URL在Apple Developer Portal的Service ID配置中已添加
- [ ] JWT Secret Key格式正确（包含BEGIN和END标记）
- [ ] Supabase项目URL正确

### 常见错误：

1. **"Unacceptable audience"**
   - 原因：Service ID不匹配
   - 解决：确保Supabase中使用的是Service ID，不是Bundle ID

2. **"Invalid redirect_uri"**
   - 原因：Redirect URL未在Apple Developer Portal中配置
   - 解决：在Service ID的Return URLs中添加Supabase callback URL

3. **"Invalid client_secret"**
   - 原因：JWT Secret Key格式错误或过期
   - 解决：重新生成JWT Secret Key并更新Supabase配置

## 📝 当前状态

根据console log：
- ✅ Supabase已初始化
- ✅ 数据保存在本地缓存
- ❌ Apple Sign In OAuth配置错误
- ❌ 数据未同步到Supabase（因为无有效session）

**修复后，数据将自动同步到Supabase！**
