# Supabase 邮箱确认链接配置指南

## 问题描述

当用户使用邮箱注册时，Supabase 会发送确认邮件，但邮件中的链接显示 "localhost" 并且无法打开。这是因为 Supabase 的邮箱模板中配置的重定向 URL 不正确。

## 解决方案

### 方法 1：在 Supabase Dashboard 中配置 Site URL（推荐）

1. **登录 Supabase Dashboard**
   - 访问：https://supabase.com/dashboard
   - 选择你的项目：`inlzhosqbccyynofbmjt`

2. **进入 Authentication 设置**
   - 点击左侧菜单的 **Authentication**
   - 点击 **URL Configuration**

3. **配置 Site URL**
   - **Site URL**: 设置为你的应用网站 URL 或自定义 URL scheme
   - 例如：
     - `https://yourdomain.com` (如果你有网站)
     - `lifelab://` (iOS 自定义 URL scheme)
     - `https://inlzhosqbccyynofbmjt.supabase.co` (临时使用 Supabase 项目 URL)

4. **配置 Redirect URLs**
   - 在 **Redirect URLs** 中添加以下 URL：
     ```
     lifelab://auth/confirm
     https://yourdomain.com/auth/confirm
     ```
   - 点击 **Add URL** 添加每个 URL

5. **保存设置**
   - 点击 **Save** 保存配置

### 方法 2：使用 Universal Links（iOS 推荐）

如果你想要更好的用户体验，可以设置 Universal Links：

1. **在 Apple Developer Portal 配置 Associated Domains**
   - 添加 `applinks:yourdomain.com`

2. **创建 apple-app-site-association 文件**
   - 在你的网站根目录创建 `.well-known/apple-app-site-association`
   - 内容示例：
   ```json
   {
     "applinks": {
       "apps": [],
       "details": [
         {
           "appID": "TEAM_ID.com.resonance.lifelab",
           "paths": ["/auth/confirm"]
         }
       ]
     }
   }
   ```

3. **在 Supabase 中配置**
   - Site URL: `https://yourdomain.com`
   - Redirect URLs: `https://yourdomain.com/auth/confirm`

### 方法 3：临时解决方案（仅用于测试）

如果你只是想测试功能，可以：

1. **在 Supabase Dashboard 中设置**
   - Site URL: `https://inlzhosqbccyynofbmjt.supabase.co`
   - Redirect URLs: `https://inlzhosqbccyynofbmjt.supabase.co/auth/confirm`

2. **创建简单的确认页面**
   - 在 Supabase 项目中创建一个简单的 HTML 页面
   - 页面内容：
   ```html
   <!DOCTYPE html>
   <html>
   <head>
       <title>Email Confirmed</title>
   </head>
   <body>
       <h1>Email Confirmed!</h1>
       <p>Your email has been confirmed. You can now close this page and return to the app.</p>
       <script>
           // Try to open the app
           window.location.href = "lifelab://auth/confirm";
       </script>
   </body>
   </html>
   ```

### 方法 4：在代码中设置 redirect_to（已实现）

代码中已经添加了 `redirect_to` 参数，但你需要确保：

1. **在 Supabase Dashboard 中配置了对应的 Redirect URL**
2. **在 Xcode 中配置了自定义 URL scheme**
   - 打开 `LifeLab.xcodeproj`
   - 选择 **LifeLab** target
   - 进入 **Info** 标签
   - 展开 **URL Types**
   - 点击 **+** 添加新的 URL Type
   - **Identifier**: `com.resonance.lifelab`
   - **URL Schemes**: `lifelab`

## 验证配置

1. **测试邮箱注册**
   - 使用邮箱注册新账户
   - 检查收到的确认邮件
   - 点击邮件中的链接
   - 应该能够正常打开（或跳转到应用）

2. **检查日志**
   - 在 Xcode 控制台中查看是否有相关错误
   - 确认 `redirect_to` 参数是否正确传递

## 常见问题

### Q: 为什么链接显示 "localhost"？
A: 这是因为 Supabase 的默认配置使用了 localhost。你需要在 Supabase Dashboard 中配置正确的 Site URL。

### Q: 如何让链接直接打开应用？
A: 使用自定义 URL scheme (`lifelab://`) 或 Universal Links。

### Q: 如果我没有网站怎么办？
A: 可以使用 Supabase 项目 URL 作为临时解决方案，或者设置自定义 URL scheme。

## 重要提示

⚠️ **生产环境**：在生产环境中，你应该：
1. 使用自己的域名
2. 配置 Universal Links
3. 确保 SSL 证书有效
4. 测试所有重定向流程
