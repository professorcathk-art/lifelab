# 创建测试账号指南

## 🎯 测试账号信息

**Email**: `test@lifelab.app`  
**Password**: `Test123456`

---

## 📋 方法 1: 在 Supabase Dashboard 创建（推荐）

### Step 1: 登录 Supabase Dashboard

1. **访问**：https://supabase.com/dashboard
2. **登录**您的 Supabase 账号
3. **选择项目**：LifeLab

### Step 2: 创建用户

1. **进入 Authentication**：
   - 左侧菜单 → **Authentication**
   - 点击 **Users** 标签

2. **添加用户**：
   - 点击 **"Add user"** 或 **"Create user"**
   - 填写信息：
     - **Email**: `test@lifelab.app`
     - **Password**: `Test123456`
     - **Auto Confirm User**: ✅ 勾选（自动确认，无需邮箱验证）
   - 点击 **"Create user"**

3. **验证创建**：
   - 用户应该出现在用户列表中
   - 状态应该是 **"Confirmed"**

### Step 3: 测试登录

在应用中：
1. 打开应用
2. 进入登录页面
3. 输入：
   - Email: `test@lifelab.app`
   - Password: `Test123456`
4. 点击登录
5. 应该成功登录

---

## 📋 方法 2: 通过应用注册（备选）

### Step 1: 在应用中注册

1. **打开应用**
2. **进入注册页面**
3. **填写信息**：
   - Email: `test@lifelab.app`
   - Password: `Test123456`
   - Name: `Test User`
4. **点击注册**

### Step 2: 确认邮箱（如果需要）

如果 Supabase 设置了邮箱验证：
1. 检查邮箱（`test@lifelab.app`）
2. 点击验证链接
3. 或直接在 Supabase Dashboard 中确认用户

---

## 📋 方法 3: 使用 Supabase SQL（高级）

### Step 1: 在 Supabase Dashboard 执行 SQL

1. **进入 SQL Editor**：
   - 左侧菜单 → **SQL Editor**
   - 点击 **"New query"**

2. **执行 SQL**：

```sql
-- 创建测试用户
INSERT INTO auth.users (
    instance_id,
    id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    created_at,
    updated_at,
    raw_app_meta_data,
    raw_user_meta_data,
    is_super_admin,
    confirmation_token,
    recovery_token
) VALUES (
    '00000000-0000-0000-0000-000000000000',
    gen_random_uuid(),
    'authenticated',
    'authenticated',
    'test@lifelab.app',
    crypt('Test123456', gen_salt('bf')), -- 加密密码
    NOW(), -- 自动确认
    NOW(),
    NOW(),
    '{"provider":"email","providers":["email"]}',
    '{"name":"Test User"}',
    false,
    '',
    ''
);
```

**注意**：这个方法比较复杂，推荐使用方法 1。

---

## ✅ 推荐方法

### 使用 Supabase Dashboard（方法 1）

**优点**：
- ✅ 最简单
- ✅ 可视化界面
- ✅ 可以设置自动确认
- ✅ 可以立即测试

**步骤**：
1. Supabase Dashboard → Authentication → Users
2. Add user
3. Email: `test@lifelab.app`
4. Password: `Test123456`
5. Auto Confirm User: ✅
6. Create user

---

## 🔍 验证测试账号

### 在 Supabase Dashboard

1. **进入 Authentication → Users**
2. **查找** `test@lifelab.app`
3. **确认状态**：
   - Email Confirmed: ✅
   - User ID: 应该有 UUID

### 在应用中测试

1. **打开应用**
2. **登录**：
   - Email: `test@lifelab.app`
   - Password: `Test123456`
3. **应该成功登录**

---

## 📝 App Store Connect 审查信息

### 在 App Store Connect 中填写

**App 审查信息 → 备注**：

```
测试账号信息：
- Email: test@lifelab.app
- Password: Test123456

此账号已创建并确认，审查员可以使用此账号登录并测试所有功能。
```

---

## ⚠️ 重要提示

### 邮箱域名

`test@lifelab.app` 是一个示例邮箱。如果这个域名不存在：

**选项 1**: 使用真实邮箱
- 例如：`test.lifelab@gmail.com`
- 或您自己的邮箱

**选项 2**: 使用临时邮箱服务
- 例如：`test@mailinator.com`
- 或 `test@tempmail.com`

**选项 3**: 使用 Supabase 的测试邮箱
- Supabase 允许使用任何邮箱格式
- 只要设置了 "Auto Confirm"，就不需要真实邮箱

---

## 🎯 推荐配置

### 在 Supabase Dashboard

1. **Authentication → Settings**
2. **Email Auth**：
   - ✅ Enable Email Signup
   - ✅ Enable Email Confirmations（可选，测试时可以关闭）
   - ✅ Auto Confirm Users（推荐开启，方便测试）

3. **创建测试用户**：
   - Email: `test@lifelab.app`
   - Password: `Test123456`
   - Auto Confirm: ✅

---

## ✅ 完成！

测试账号创建完成后：

1. ✅ 在 Supabase Dashboard 中可见
2. ✅ 可以在应用中登录
3. ✅ 可以在 App Store Connect 中提供给审查员

**下一步**：在 App Store Connect 的 "App 审查信息" 中填写测试账号信息。
