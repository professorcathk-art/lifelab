# Apple Sign In - Domains 和 JWT Secret Key 配置指南

## 📋 当前配置信息

- **Bundle ID**: `com.resonance.lifelab`
- **App ID**: `com.resonance.lifelab`
- **Service ID**: `com.resonance.lifelab.service`
- **Supabase URL**: `https://inlzhosqbccyynofbmjt.supabase.co`

---

## 🌐 问题 1: Domains and Subdomains

### 在 Service ID 配置中填写

当配置 Sign In with Apple 时，需要填写：

#### Domains and Subdomains
```
inlzhosqbccyynofbmjt.supabase.co
```

**说明**:
- 这是您的 Supabase 项目的域名
- 不需要 `https://` 前缀
- 只需要域名部分：`inlzhosqbccyynofbmjt.supabase.co`

#### Return URLs
```
https://inlzhosqbccyynofbmjt.supabase.co/auth/v1/callback
```

**说明**:
- 这是完整的回调 URL
- 需要包含 `https://` 协议
- 必须以 `/auth/v1/callback` 结尾

---

## 🔑 问题 2: 如何获取 JWT Secret Key

### Step 1: 创建 Key

1. **Apple Developer** → **Certificates, Identifiers & Profiles**
2. 点击左侧 **Keys**
3. 点击右上角 **+** 按钮
4. **Key Name**: `LifeLab Apple Sign In Key`
5. ✅ **勾选 Sign In with Apple**
6. 点击 **Continue**
7. 检查信息，点击 **Register**

### Step 2: 下载 Key（仅此一次机会！）

⚠️ **重要**: 您只有一次机会下载 Key 文件！

1. 创建 Key 后，会显示 **Key ID**（例如：`ABC123DEF4`）
2. 点击 **Download** 按钮下载 `.p8` 文件
3. ⚠️ **立即保存**：这个文件无法再次下载！
4. 保存到安全的位置（例如：`~/Downloads/LifeLab_Key_ABC123DEF4.p8`）

### Step 3: 生成 JWT Secret Key

#### 方法 1: 使用在线工具（推荐）

1. 访问：https://jwt.io/
2. 在 **Algorithm** 选择：`ES256`
3. 在 **Decoded** 部分填写：

**Header**:
```json
{
  "alg": "ES256",
  "kid": "YOUR_KEY_ID"
}
```

**Payload**:
```json
{
  "iss": "YOUR_TEAM_ID",
  "iat": 1234567890,
  "exp": 1234567890,
  "aud": "https://appleid.apple.com",
  "sub": "com.resonance.lifelab.service"
}
```

**Private Key**:
- 打开下载的 `.p8` 文件
- 复制整个内容（包括 `-----BEGIN PRIVATE KEY-----` 和 `-----END PRIVATE KEY-----`）

4. 点击 **Encode** 生成 JWT

#### 方法 2: 使用 Node.js 脚本（更可靠）

创建文件 `generate-jwt-secret.js`:

```javascript
const jwt = require('jsonwebtoken');
const fs = require('fs');

// 配置信息
const TEAM_ID = 'YOUR_TEAM_ID'; // 从 Apple Developer → Membership 查看
const KEY_ID = 'YOUR_KEY_ID'; // 创建 Key 时显示的 Key ID
const CLIENT_ID = 'com.resonance.lifelab.service'; // Service ID
const KEY_PATH = './LifeLab_Key_ABC123DEF4.p8'; // Key 文件路径

// 读取 Key 文件
const privateKey = fs.readFileSync(KEY_PATH);

// 创建 JWT
const token = jwt.sign(
  {
    iss: TEAM_ID,
    iat: Math.floor(Date.now() / 1000),
    exp: Math.floor(Date.now() / 1000) + 86400 * 180, // 6个月有效期
    aud: 'https://appleid.apple.com',
    sub: CLIENT_ID
  },
  privateKey,
  {
    algorithm: 'ES256',
    header: {
      alg: 'ES256',
      kid: KEY_ID
    }
  }
);

console.log('JWT Secret Key:');
console.log(token);
```

运行：
```bash
node generate-jwt-secret.js
```

#### 方法 3: 使用 Python 脚本

创建文件 `generate-jwt-secret.py`:

```python
import jwt
import time
from datetime import datetime, timedelta

# 配置信息
TEAM_ID = 'YOUR_TEAM_ID'  # 从 Apple Developer → Membership 查看
KEY_ID = 'YOUR_KEY_ID'  # 创建 Key 时显示的 Key ID
CLIENT_ID = 'com.resonance.lifelab.service'  # Service ID
KEY_PATH = './LifeLab_Key_ABC123DEF4.p8'  # Key 文件路径

# 读取 Key 文件
with open(KEY_PATH, 'r') as f:
    private_key = f.read()

# 创建 JWT
now = int(time.time())
token = jwt.encode(
    {
        'iss': TEAM_ID,
        'iat': now,
        'exp': now + 86400 * 180,  # 6个月有效期
        'aud': 'https://appleid.apple.com',
        'sub': CLIENT_ID
    },
    private_key,
    algorithm='ES256',
    headers={
        'kid': KEY_ID
    }
)

print('JWT Secret Key:')
print(token)
```

运行：
```bash
python3 generate-jwt-secret.py
```

---

## 📝 如何找到 Team ID

1. **Apple Developer** → **Membership**
2. 查看 **Team ID**（例如：`ABC123DEF4`）
3. 或在 **Account** → **Membership** 中查看

---

## 🔐 在 Supabase 中配置

### 所需信息：

1. **Client ID**: `com.resonance.lifelab.service`
2. **Client Secret**: （使用上面生成的 JWT）
3. **Key ID**: （创建 Key 时显示的 ID）
4. **Team ID**: （从 Membership 查看）

### 在 Supabase Dashboard：

1. **Authentication** → **Providers**
2. 找到 **Apple**
3. 填写：
   - **Enabled**: ✅ 开启
   - **Client ID**: `com.resonance.lifelab.service`
   - **Client Secret**: （粘贴生成的 JWT）
   - **Key ID**: （您的 Key ID）
   - **Team ID**: （您的 Team ID）

---

## ⚠️ 重要提醒

### 关于 Key 文件：
- ⚠️ **只能下载一次**！请立即保存
- 🔒 不要提交到 Git 仓库
- 📁 保存在安全的位置

### 关于 JWT Secret：
- 🔄 JWT 有有效期（通常 6 个月）
- ⏰ 过期后需要重新生成
- 📝 建议设置提醒，在过期前更新

### 关于 Domains：
- ✅ Domains: `inlzhosqbccyynofbmjt.supabase.co`
- ✅ Return URL: `https://inlzhosqbccyynofbmjt.supabase.co/auth/v1/callback`
- ⚠️ 两者必须都填写

---

## ✅ 完整配置检查清单

### Apple Developer:
- [ ] App ID: `com.resonance.lifelab`（已启用 Sign In with Apple）
- [ ] Service ID: `com.resonance.lifelab.service`
  - [ ] Domains: `inlzhosqbccyynofbmjt.supabase.co`
  - [ ] Return URL: `https://inlzhosqbccyynofbmjt.supabase.co/auth/v1/callback`
- [ ] Key 已创建并下载（`.p8` 文件）
- [ ] 已记录 Key ID 和 Team ID

### Supabase:
- [ ] Client ID: `com.resonance.lifelab.service`
- [ ] Client Secret: （生成的 JWT）
- [ ] Key ID: （已填写）
- [ ] Team ID: （已填写）

---

## 🛠️ 快速参考

### 您的配置信息：

```
Bundle ID: com.resonance.lifelab
App ID: com.resonance.lifelab
Service ID: com.resonance.lifelab.service
Domain: inlzhosqbccyynofbmjt.supabase.co
Return URL: https://inlzhosqbccyynofbmjt.supabase.co/auth/v1/callback
```

### 需要获取的信息：

1. **Team ID**: Apple Developer → Membership
2. **Key ID**: 创建 Key 后显示
3. **Key 文件**: 下载的 `.p8` 文件
4. **JWT Secret**: 使用上述方法生成

---

## 📚 相关文档

- `APPLE_SIGN_IN_STEP_BY_STEP.md` - 完整步骤指南
- `APPLE_SIGN_IN_SUPABASE_CONFIG.md` - Supabase 配置说明
- `BUNDLE_ID_UPDATE.md` - Bundle ID 更新记录
