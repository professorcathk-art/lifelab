# Apple Sign In 配置指南

## 📋 在 Supabase 中配置 Apple Sign In 所需的信息

### 需要的信息：
1. **Client ID (Service ID)** - 例如：`com.yourcompany.lifelab.service`
2. **Secret Key (Client Secret)** - 一个 JWT token

---

## 🔧 步骤 1: 在 Apple Developer 创建 Service ID

### 1.1 登录 Apple Developer
- 访问: https://developer.apple.com/account
- 使用您的 Apple Developer 账号登录

### 2.2 创建 App ID（如果还没有）
1. 进入 **Certificates, Identifiers & Profiles**
2. 点击 **Identifiers**
3. 点击 **+** 按钮
4. 选择 **App IDs** → **Continue**
5. 选择 **App** → **Continue**
6. 填写：
   - **Description**: LifeLab
   - **Bundle ID**: `com.yourcompany.lifelab` (例如：`com.lifelab.app`)
7. 在 **Capabilities** 中勾选：
   - ✅ **Sign In with Apple**
8. 点击 **Continue** → **Register**

### 2.3 创建 Service ID（用于 Supabase）
1. 在 **Identifiers** 页面，点击 **+** 按钮
2. 选择 **Services IDs** → **Continue**
3. 填写：
   - **Description**: LifeLab Service (for Supabase)
   - **Identifier**: `com.yourcompany.lifelab.service` (例如：`com.lifelab.app.service`)
4. 点击 **Continue** → **Register**

### 2.4 配置 Service ID
1. 点击刚创建的 Service ID
2. 勾选 **Sign In with Apple**
3. 点击 **Configure**
4. 在 **Primary App ID** 中选择您的 App ID（例如：`com.yourcompany.lifelab`）
5. **Website URLs**:
   - **Domains and Subdomains**: `inlzhosqbccyynofbmjt.supabase.co`
   - **Return URLs**: `https://inlzhosqbccyynofbmjt.supabase.co/auth/v1/callback`
6. 点击 **Save** → **Continue** → **Save**

---

## 🔑 步骤 2: 创建 Client Secret (Secret Key)

### 2.1 创建 Key
1. 在 **Certificates, Identifiers & Profiles** 页面
2. 点击 **Keys**
3. 点击 **+** 按钮
4. 填写：
   - **Key Name**: LifeLab Sign In with Apple Key
   - 勾选 **Sign In with Apple**
5. 点击 **Configure**
6. 选择您的 **Primary App ID**（例如：`com.yourcompany.lifelab`）
7. 点击 **Save** → **Continue** → **Register**

### 2.2 下载 Key 文件
1. 点击刚创建的 Key
2. 点击 **Download** 下载 `.p8` 文件
3. ⚠️ **重要**: 这个文件只能下载一次，请妥善保存！

### 2.3 生成 Client Secret (JWT)
您需要使用下载的 `.p8` 文件生成 JWT token。有以下几种方法：

#### 方法 1: 使用在线工具（推荐，简单）
1. 访问: https://developer.apple.com/documentation/sign_in_with_apple/generate_and_validate_tokens
2. 或使用在线 JWT 生成器：
   - https://jwt.io
   - 需要填写：
     - **Header**: 
       ```json
       {
         "alg": "ES256",
         "kid": "YOUR_KEY_ID"
       }
       ```
     - **Payload**:
       ```json
       {
         "iss": "YOUR_TEAM_ID",
         "iat": CURRENT_TIMESTAMP,
         "exp": CURRENT_TIMESTAMP + 15768000,
         "aud": "https://appleid.apple.com",
         "sub": "YOUR_SERVICE_ID"
       }
       ```
     - **Private Key**: 从 `.p8` 文件中复制

#### 方法 2: 使用脚本生成（更安全）
创建一个 Node.js 脚本：

```javascript
const jwt = require('jsonwebtoken');
const fs = require('fs');

const teamId = 'YOUR_TEAM_ID'; // 从 Apple Developer 获取
const clientId = 'com.yourcompany.lifelab.service'; // Service ID
const keyId = 'YOUR_KEY_ID'; // 从创建的 Key 中获取
const privateKey = fs.readFileSync('path/to/AuthKey_XXXXX.p8', 'utf8');

const token = jwt.sign(
  {
    iss: teamId,
    iat: Math.floor(Date.now() / 1000),
    exp: Math.floor(Date.now() / 1000) + 15768000, // 6 months
    aud: 'https://appleid.apple.com',
    sub: clientId
  },
  privateKey,
  {
    algorithm: 'ES256',
    header: {
      kid: keyId,
      alg: 'ES256'
    }
  }
);

console.log('Client Secret:', token);
```

#### 方法 3: 使用 Supabase 的说明
Supabase Dashboard 中可能有自动生成工具，检查：
- Authentication > Providers > Apple
- 可能有 "Generate Client Secret" 按钮

---

## 📝 步骤 3: 在 Supabase 中配置

### 3.1 进入 Supabase Dashboard
1. 访问: https://supabase.com/dashboard
2. 选择项目: `inlzhosqbccyynofbmjt`
3. 进入 **Authentication** → **Providers**
4. 找到 **Apple** provider

### 3.2 填写配置信息
- **Enabled**: ✅ 启用
- **Client ID (Service ID)**: `com.yourcompany.lifelab.service`
  - 这是您创建的 Service ID
- **Secret Key**: 
  - 这是您生成的 JWT token（Client Secret）
  - 格式类似：`eyJraWQiOi...`（很长的字符串）

### 3.3 保存配置
点击 **Save** 保存配置

---

## 🔍 如何获取必要信息

### Team ID
1. 登录 Apple Developer
2. 右上角点击您的账号
3. 在 **Membership** 部分可以看到 **Team ID**
   - 格式：`ABC123DEF4`

### Key ID
1. 进入 **Keys** 页面
2. 点击您创建的 Key
3. **Key ID** 显示在 Key 名称下方
   - 格式：`ABC123DEF4`

### Service ID (Client ID)
- 这是您创建的 Service ID
- 格式：`com.yourcompany.lifelab.service`

---

## ⚠️ 重要注意事项

1. **Client Secret 有效期**
   - Client Secret (JWT) 通常有效期为 6 个月
   - 过期后需要重新生成

2. **.p8 文件安全**
   - ⚠️ 只能下载一次
   - 请妥善保存
   - 不要提交到代码库

3. **Return URL**
   - 必须是：`https://inlzhosqbccyynofbmjt.supabase.co/auth/v1/callback`
   - 在 Apple Developer 配置 Service ID 时必须使用这个 URL

4. **Bundle ID**
   - 在 Xcode 项目中的 Bundle ID 必须与 App ID 匹配
   - 例如：`com.yourcompany.lifelab`

---

## 🧪 测试配置

配置完成后，可以测试：

1. **在应用中测试**
   - 运行应用
   - 点击 "Sign in with Apple"
   - 应该能正常登录

2. **检查 Supabase Dashboard**
   - Authentication > Users
   - 应该能看到通过 Apple Sign In 创建的用户

---

## 📚 参考资源

- Apple Sign In 文档: https://developer.apple.com/sign-in-with-apple/
- Supabase Apple Auth: https://supabase.com/docs/guides/auth/social-login/auth-apple
- JWT 生成: https://jwt.io

---

## 🆘 常见问题

### Q: 找不到 Team ID？
A: 在 Apple Developer 右上角账号信息中查看

### Q: Client Secret 格式是什么？
A: 是一个 JWT token，以 `eyJ` 开头，很长的一串字符

### Q: Return URL 是什么？
A: `https://inlzhosqbccyynofbmjt.supabase.co/auth/v1/callback`

### Q: Service ID 和 App ID 的区别？
A: 
- **App ID**: 用于 iOS 应用本身
- **Service ID**: 用于第三方服务（如 Supabase）与 Apple 通信

---

## ✅ 配置检查清单

- [ ] 创建了 App ID（包含 Sign In with Apple capability）
- [ ] 创建了 Service ID
- [ ] 配置了 Service ID 的 Return URL
- [ ] 创建了 Key 并下载了 .p8 文件
- [ ] 生成了 Client Secret (JWT)
- [ ] 在 Supabase 中填写了 Client ID 和 Secret Key
- [ ] 测试了 Apple Sign In 功能
