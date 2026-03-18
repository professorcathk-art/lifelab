# Supabase Email OTP 設定

## ⚠️ 重要：為什麼第一個 Token 顯示「invalid / expired」？

LifeLab 的註冊流程會傳入 `data`（例如姓名）給 `signInWithOTP`。  
**當有傳入 `data` 時，Supabase 會使用「Confirm signup」模板，而不是「Magic Link」模板。**

參考：[GitHub #9285](https://github.com/supabase/supabase/issues/9285) — 使用 `data` 時會觸發 signup confirmation 流程。

### 必須修改的模板

| 流程 | 使用的模板 | 需修改 |
|------|------------|--------|
| 註冊（有傳 name） | **Confirm signup** | ✅ 必須 |
| 重設密碼 | **Recovery** | ✅ 必須 |
| 登入（無 data） | Magic Link | 選用 |

**若只改了 Magic Link 而沒改 Confirm signup，註冊時會用錯模板，導致 token invalid/expired。**

### 為何會「Token invalid and expired」？

1. **Email prefetch**：部分信箱（如 Microsoft Safe Links）會預先點擊連結，導致 token 被消耗。
2. **模板含 `{{ .ConfirmationURL }}`**：若有連結，信箱可能 prefetch 並消耗 token。
3. **解法**：在 OTP 流程中**只使用** `{{ .Token }}`，**完全移除** `{{ .ConfirmationURL }}`。

參考：[Supabase Email Templates](https://supabase.com/docs/guides/auth/auth-email-templates#email-prefetching)

---

## 啟用 OTP 驗證

LifeLab 使用 Email OTP 進行：
1. **註冊**：signUp (觸發 Confirm signup 模板) + verifyOTP (type: signup)
2. **重設密碼**：resetPasswordForEmail + verifyOTP (type: recovery)

**註**：`signInWithOTP` 固定使用 Magic Link 模板；`signUp` 使用 Confirm signup 模板。故註冊流程改用 `signUp`。

## Supabase Dashboard 設定

### 1. 修改 Email 模板

前往 **Supabase Dashboard** → **Authentication** → **Email Templates**

#### Confirm signup 模板（註冊用）— 必改

- 註冊時會傳入 `data`（姓名），因此使用此模板
- 將內容改為**只使用** `{{ .Token }}`
- **務必移除** `{{ .ConfirmationURL }}`，避免 prefetch 消耗 token

#### Recovery 模板（重設密碼用）

- 同樣改為只使用 `{{ .Token }}`，移除 `{{ .ConfirmationURL }}`

### 2. 範例模板（OTP 專用）

**Confirm signup（註冊）：**
```html
<h2>確認您的註冊</h2>
<p>您的驗證碼是：<strong>{{ .Token }}</strong></p>
<p>請在 LifeLab App 中輸入此驗證碼完成註冊。</p>
<p>請勿點擊任何連結，直接輸入驗證碼即可。</p>
```

**Recovery（重設密碼）：**
```html
<h2>重設密碼</h2>
<p>您的驗證碼是：<strong>{{ .Token }}</strong></p>
<p>請在 App 中輸入此驗證碼並設定新密碼。</p>
```

### 3. 重要提醒

- **絕對不要**在 OTP 流程的模板中保留 `{{ .ConfirmationURL }}`，否則信箱 prefetch 可能消耗 token
- 若只要 OTP，請**只使用** `{{ .Token }}`

### 4. Redirect URLs

確保在 **Authentication** → **URL Configuration** 中已加入：
- `lifelab://auth-callback`
- `lifelab://reset-password`

## 流程說明

### 註冊流程
1. 用戶輸入 email → `sendSignUpOTP` (signUp，觸發 Confirm signup 模板)
2. 用戶收到 OTP → 輸入 OTP + 密碼 + 確認密碼
3. `verifySignUpOTP` (verifyOTP type: .signup) → 建立 session
4. `updateUser` 設定密碼

### 重設密碼流程
1. 用戶輸入 email → `sendRecoveryOTP` (resetPasswordForEmail)
2. 用戶收到 OTP → 輸入 OTP + 新密碼 + 確認密碼
3. `verifyRecoveryOTP` (verifyOTP type: .recovery) → 建立 session
4. `updateUser` 設定新密碼
