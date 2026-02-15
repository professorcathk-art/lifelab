# Apple Sign In - 逐步配置指南

## 📋 正确的顺序

**必须先创建 App ID，然后才能创建 Service ID**

因为 Service ID 需要关联到一个 App ID。

---

## ✅ Step 1: 创建 App ID（必须先完成）

### 1.1 登录 Apple Developer
- 访问: https://developer.apple.com/account
- 使用您的 Apple Developer 账号登录

### 1.2 进入 Identifiers
- 点击 **Certificates, Identifiers & Profiles**
- 点击左侧 **Identifiers**

### 1.3 创建 App ID
1. 点击右上角 **+** 按钮
2. 选择 **App IDs** → 点击 **Continue**
3. 选择 **App** → 点击 **Continue**
4. 填写信息：
   - **Description**: `LifeLab`
   - **Bundle ID**: 
     - 选择 **Explicit**（不是 Wildcard）
     - 输入: `com.lifelab.LifeLab`
     - ⚠️ **重要**: 这个必须与您 Xcode 项目中的 Bundle ID 完全一致
5. 在 **Capabilities** 部分：
   - ✅ **勾选 Sign In with Apple**
6. 点击 **Continue**
7. 检查信息无误后，点击 **Register**

✅ **完成！您现在有了 App ID: `com.lifelab.LifeLab`**

---

## ✅ Step 2: 创建 Service ID（现在可以创建了）

### 2.1 创建 Service ID
1. 在 **Identifiers** 页面，点击右上角 **+** 按钮
2. 选择 **Services IDs** → 点击 **Continue**
3. 填写信息：
   - **Description**: `LifeLab Service`
   - **Identifier**: `com.lifelab.LifeLab.service`
4. ✅ **勾选 Sign In with Apple**
5. 点击 **Continue**

### 2.2 配置 Sign In with Apple
1. 点击 **Configure** 按钮（在 Sign In with Apple 旁边）
2. 在 **Primary App ID** 下拉菜单中：
   - **选择**: `com.lifelab.LifeLab`（这是您刚创建的 App ID）
3. 在 **Website URLs** 部分：
   - **Domains and Subdomains**: 
     ```
     inlzhosqbccyynofbmjt.supabase.co
     ```
   - **Return URLs**: 
     ```
     https://inlzhosqbccyynofbmjt.supabase.co/auth/v1/callback
     ```
4. 点击 **Save**
5. 点击 **Continue**
6. 检查信息无误后，点击 **Register**

✅ **完成！您现在有了 Service ID: `com.lifelab.LifeLab.service`**

---

## ✅ Step 3: 创建 Key 并生成 Secret

### 3.1 创建 Key
1. 在左侧菜单点击 **Keys**
2. 点击右上角 **+** 按钮
3. **Key Name**: `LifeLab Sign In Key`
4. ✅ **勾选 Sign In with Apple**
5. 点击 **Configure** 按钮
6. 在 **Primary App ID** 下拉菜单中选择：`com.lifelab.LifeLab`
7. 点击 **Save** → **Continue** → **Register**
8. ⚠️ **重要**: 点击 **Download** 下载 `.p8` 文件
   - 文件名类似：`AuthKey_ABC123DEF4.p8`
   - ⚠️ **只能下载一次，请妥善保存！**

### 3.2 获取必要信息
在 Key 详情页面，您可以看到：
- **Key ID**: 例如 `ABC123DEF4`（记下这个）

在 Apple Developer 右上角，点击您的账号，可以看到：
- **Team ID**: 例如 `ABC123DEF4`（记下这个）

### 3.3 生成 Client Secret (JWT Token)

#### 方法 1: 使用 Python 脚本（推荐）

安装依赖：
```bash
pip install PyJWT cryptography
```

创建脚本 `generate_secret.py`:
```python
import jwt
import time
from datetime import datetime

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
print('=' * 60)
print('Client Secret (复制这个):')
print('=' * 60)
print(token)
print('=' * 60)
```

运行：
```bash
python generate_secret.py
```

#### 方法 2: 使用在线工具
- 访问: https://developer.apple.com/documentation/sign_in_with_apple/generate_and_validate_tokens
- 按照说明填写信息

✅ **完成！您现在有了 Client Secret (JWT token)**

---

## ✅ Step 4: 在 Supabase 中配置

### 4.1 进入 Supabase Dashboard
1. 访问: https://supabase.com/dashboard
2. 选择项目: `inlzhosqbccyynofbmjt`
3. 左侧菜单 → **Authentication** → **Providers**

### 4.2 配置 Apple Provider
1. 找到 **Apple** provider
2. 点击展开配置
3. 填写：
   - ✅ **Enabled**: 启用
   - **Client ID (Service ID)**: `com.lifelab.LifeLab.service`
   - **Secret Key**: 粘贴您生成的 JWT token（从 Step 3）
4. 点击 **Save**

✅ **完成！Apple Sign In 已配置**

---

## ✅ Step 5: 在 Xcode 中添加 Capability（可选但推荐）

1. 在 Xcode 中打开项目
2. 选择项目 → **LifeLab** target
3. **Signing & Capabilities** 标签
4. 点击 **+ Capability**
5. 选择 **Sign in with Apple**
6. ✅ 完成

---

## 📋 总结：在 Supabase 中需要填写的信息

基于您的配置：

- **Client ID**: `com.lifelab.LifeLab.service`
- **Secret Key**: 生成的 JWT token（从 Step 3）

---

## 🧪 测试

配置完成后：
1. 运行应用
2. 点击 "Sign in with Apple"
3. 应该能正常登录
4. 在 Supabase Dashboard → Authentication → Users 中查看用户

---

## ⚠️ 常见问题

### Q: 为什么需要先创建 App ID？
A: 因为 Service ID 需要关联到一个 App ID，所以必须先创建 App ID。

### Q: Bundle ID 必须匹配吗？
A: 是的！
- Xcode 项目: `com.lifelab.LifeLab`
- App ID: `com.lifelab.LifeLab`
- Service ID: `com.lifelab.LifeLab.service`

### Q: Return URL 是什么？
A: `https://inlzhosqbccyynofbmjt.supabase.co/auth/v1/callback`

### Q: Client Secret 有效期多久？
A: 6 个月，过期后需要重新生成。
