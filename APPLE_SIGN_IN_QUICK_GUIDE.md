# Apple Sign In 快速配置指南

## 🎯 在 Supabase 中需要填写的信息

### Client ID (Service ID)
```
格式: com.yourcompany.lifelab.service
示例: com.lifelab.LifeLab.service
```

### Secret Key (Client Secret)
```
格式: JWT token (以 eyJ 开头)
示例: eyJraWQiOiJBRU... (很长的字符串)
```

---

## 📋 快速步骤

### Step 1: 创建 Service ID（5 分钟）

1. **登录 Apple Developer**
   - https://developer.apple.com/account
   - 进入 **Certificates, Identifiers & Profiles**

2. **创建 Service ID**
   - 点击 **Identifiers** → **+** → **Services IDs**
   - **Description**: `LifeLab Service`
   - **Identifier**: `com.lifelab.LifeLab.service` (基于您的 Bundle ID: com.lifelab.LifeLab)
   - 勾选 **Sign In with Apple**
   - **Configure** → 选择您的 App ID
   - **Return URLs**: `https://inlzhosqbccyynofbmjt.supabase.co/auth/v1/callback`
   - **Save**

### Step 3: 创建 Key 并生成 Secret（10 分钟）

1. **创建 Key**
   - **Keys** → **+** → **Key Name**: `LifeLab Sign In Key`
   - 勾选 **Sign In with Apple** → **Configure** → 选择 App ID
   - **Save** → **Download** `.p8` 文件

2. **获取必要信息**
   - **Team ID**: 右上角账号信息中查看
   - **Key ID**: 在 Key 详情页面查看
   - **Service ID**: `com.lifelab.LifeLab.service`

3. **生成 Client Secret**
   
   使用以下 Python 脚本（最简单）：

   ```python
   import jwt
   import time
   from datetime import datetime, timedelta
   
   # 从 .p8 文件读取私钥
   with open('AuthKey_XXXXX.p8', 'r') as f:
       private_key = f.read()
   
   # 配置信息
   team_id = 'YOUR_TEAM_ID'  # 替换为您的 Team ID
   client_id = 'com.lifelab.LifeLab.service'  # Service ID
   key_id = 'YOUR_KEY_ID'  # 替换为您的 Key ID
   
   # 生成 JWT
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
   - 或使用 https://jwt.io（需要手动填写）

### Step 4: 在 Supabase 中配置（2 分钟）

1. **Supabase Dashboard**
   - Authentication → Providers → Apple

2. **填写信息**
   - **Enabled**: ✅
   - **Client ID**: `com.lifelab.LifeLab.service`
   - **Secret Key**: 生成的 JWT token

3. **Save**

---

## 🔍 如何找到必要信息

### Team ID
- Apple Developer 右上角 → 账号信息 → **Membership** → **Team ID**

### Key ID
- **Keys** 页面 → 点击创建的 Key → **Key ID** 显示在名称下方

### Service ID
- 您创建的 Service ID（例如：`com.yourcompany.lifelab.service`）

---

## ⚠️ 重要提醒

1. **Return URL 必须是**:
   ```
   https://inlzhosqbccyynofbmjt.supabase.co/auth/v1/callback
   ```

2. **.p8 文件只能下载一次**，请妥善保存

3. **Client Secret 有效期 6 个月**，过期后需重新生成

4. **Bundle ID 必须匹配**:
   - Xcode 项目中的 Bundle ID 必须与 App ID 匹配
   - 您的 Bundle ID: `com.lifelab.LifeLab`

---

## 🧪 测试

配置完成后：
1. 运行应用
2. 点击 "Sign in with Apple"
3. 应该能正常登录
4. 在 Supabase Dashboard → Authentication → Users 中查看用户

---

## 📚 详细文档

完整步骤请参考：`APPLE_SIGN_IN_SETUP.md`
