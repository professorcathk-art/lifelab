# Apple Sign In - Supabase 配置信息

## 📋 在 Supabase Dashboard 中需要填写的信息

基于您的项目配置：
- **Bundle ID**: `com.lifelab.LifeLab`
- **Supabase Project**: `inlzhosqbccyynofbmjt`

---

## 🔑 需要填写的信息

### 1. Client ID (Service ID)
```
com.lifelab.LifeLab.service
```

**说明**: 
- 这是您在 Apple Developer 中创建的 Service ID
- 格式：`{您的BundleID}.service`
- 基于您的 Bundle ID: `com.lifelab.LifeLab`

### 2. Secret Key (Client Secret)
```
eyJraWQiOiJBRU... (很长的 JWT token)
```

**说明**:
- 这是一个 JWT token，需要生成
- 格式：以 `eyJ` 开头，很长的字符串
- 有效期：6 个月

---

## 🚀 快速配置步骤

### Step 1: 先创建 App ID（必须先完成）

1. **登录 Apple Developer**
   - https://developer.apple.com/account
   - **Certificates, Identifiers & Profiles** → **Identifiers**

2. **创建 App ID**
   - 点击 **+** 按钮
   - 选择 **App IDs** → **Continue**
   - 选择 **App** → **Continue**
   - 填写：
     - **Description**: `LifeLab`
     - **Bundle ID**: 选择 **Explicit**，然后输入 `com.lifelab.LifeLab`
   - 在 **Capabilities** 中：
     - ✅ **勾选 Sign In with Apple**
   - 点击 **Continue** → **Register**

### Step 2: 创建 Service ID（需要先有 App ID）

1. **创建 Service ID**
   - 在 **Identifiers** 页面，点击 **+** 按钮
   - 选择 **Services IDs** → **Continue**
   - 填写：
     - **Description**: `LifeLab Service`
     - **Identifier**: `com.lifelab.LifeLab.service`
   - ✅ **勾选 Sign In with Apple**
   - 点击 **Configure** 按钮
   - 在 **Primary App ID** 下拉菜单中选择：`com.lifelab.LifeLab`（这是您刚创建的 App ID）
   - 在 **Website URLs** 部分：
     - **Domains and Subdomains**: `inlzhosqbccyynofbmjt.supabase.co`
     - **Return URLs**: 
       ```
       https://inlzhosqbccyynofbmjt.supabase.co/auth/v1/callback
       ```
   - 点击 **Save**
   - 点击 **Continue** → **Register**

### Step 3: 创建 Key 并生成 Secret

1. **创建 Key**
   - **Keys** → **+**
   - **Key Name**: `LifeLab Sign In Key`
   - ✅ 勾选 **Sign In with Apple**
   - **Configure** → 选择 App ID: `com.lifelab.LifeLab`
   - **Save** → **Continue** → **Register**
   - ⚠️ **Download** `.p8` 文件（只能下载一次！）

2. **获取信息**
   - **Team ID**: 右上角账号信息 → **Membership** → **Team ID**
   - **Key ID**: 在 Key 详情页面查看
   - **Service ID**: `com.lifelab.LifeLab.service`

3. **生成 Client Secret**

   使用 Python 脚本（最简单）：

   ```python
   import jwt
   import time
   
   # 从下载的 .p8 文件读取私钥
   with open('AuthKey_XXXXX.p8', 'r') as f:
       private_key = f.read()
   
   # 替换为您的实际信息
   team_id = 'YOUR_TEAM_ID'  # 例如: ABC123DEF4
   client_id = 'com.lifelab.LifeLab.service'
   key_id = 'YOUR_KEY_ID'  # 例如: ABC123DEF4
   
   headers = {
       'kid': key_id,
       'alg': 'ES256'
   }
   
   payload = {
       'iss': team_id,
       'iat': int(time.time()),
       'exp': int(time.time()) + 15768000,  # 6 months
       'aud': 'https://appleid.apple.com',
       'sub': client_id
   }
   
   token = jwt.encode(payload, private_key, algorithm='ES256', headers=headers)
   print('Client Secret:', token)
   ```

   或使用在线工具：
   - https://developer.apple.com/documentation/sign_in_with_apple/generate_and_validate_tokens
   - 需要填写：
     - **Team ID**: 您的 Team ID
     - **Client ID**: `com.lifelab.LifeLab.service`
     - **Key ID**: 您的 Key ID
     - **Private Key**: 从 `.p8` 文件复制

### Step 4: 在 Supabase 中配置

1. **Supabase Dashboard**
   - https://supabase.com/dashboard
   - 项目: `inlzhosqbccyynofbmjt`
   - **Authentication** → **Providers** → **Apple**

2. **填写信息**
   - ✅ **Enabled**: 启用
   - **Client ID**: `com.lifelab.LifeLab.service`
   - **Secret Key**: 生成的 JWT token（从 Step 2）

3. **Save**

---

## ✅ 配置检查清单（按顺序）

- [ ] **Step 1**: 创建了 App ID: `com.lifelab.LifeLab`（包含 Sign In with Apple capability）
- [ ] **Step 2**: 创建了 Service ID: `com.lifelab.LifeLab.service`（关联到 App ID）
- [ ] **Step 2**: 配置了 Return URL: `https://inlzhosqbccyynofbmjt.supabase.co/auth/v1/callback`
- [ ] **Step 3**: 创建了 Key 并下载了 `.p8` 文件
- [ ] **Step 3**: 获取了 Team ID 和 Key ID
- [ ] **Step 3**: 生成了 Client Secret (JWT token)
- [ ] **Step 4**: 在 Supabase 中填写了 Client ID 和 Secret Key
- [ ] **额外**: 在 Xcode 中添加了 Sign in with Apple capability

---

## 🔍 如何找到必要信息

### Team ID
- Apple Developer 右上角 → 账号信息 → **Membership** → **Team ID**
- 格式：`ABC123DEF4`

### Key ID
- **Keys** 页面 → 点击创建的 Key → **Key ID** 显示在名称下方
- 格式：`ABC123DEF4`

### Service ID (Client ID)
- 您创建的 Service ID: `com.lifelab.LifeLab.service`

---

## ⚠️ 重要提醒

1. **Return URL 必须是**:
   ```
   https://inlzhosqbccyynofbmjt.supabase.co/auth/v1/callback
   ```

2. **Bundle ID 必须匹配**:
   - Xcode 项目: `com.lifelab.LifeLab`
   - App ID: `com.lifelab.LifeLab`
   - Service ID: `com.lifelab.LifeLab.service`

3. **.p8 文件安全**:
   - ⚠️ 只能下载一次
   - 请妥善保存
   - 不要提交到代码库

4. **Client Secret 有效期**:
   - 6 个月
   - 过期后需要重新生成

---

## 🧪 测试

配置完成后：
1. 运行应用
2. 点击 "Sign in with Apple"
3. 应该能正常登录
4. 在 Supabase Dashboard → Authentication → Users 中查看用户

---

## 📚 参考

- 详细步骤: `APPLE_SIGN_IN_SETUP.md`
- 快速指南: `APPLE_SIGN_IN_QUICK_GUIDE.md`
