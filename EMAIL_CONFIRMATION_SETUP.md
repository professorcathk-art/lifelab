# 邮箱确认流程配置指南

## 问题描述

Supabase 发送的邮箱确认链接指向网站 (`lifelab-tau.vercel.app`)，但用户希望链接能直接打开应用或显示确认页面。

## 解决方案

### 方案 1：使用 Universal Links（推荐）

Universal Links 可以让确认链接直接打开应用，如果应用未安装则打开网页。

#### 步骤 1：配置 Associated Domains

1. **在 Apple Developer Portal 配置**
   - 登录：https://developer.apple.com
   - 选择你的 App ID：`com.resonance.lifelab`
   - 启用 **Associated Domains** capability
   - 添加域名：`applinks:lifelab-tau.vercel.app`

2. **在 Xcode 中配置**
   - 打开 `LifeLab.xcodeproj`
   - 选择 **LifeLab** target
   - 进入 **Signing & Capabilities** 标签
   - 点击 **+ Capability**
   - 添加 **Associated Domains**
   - 添加：`applinks:lifelab-tau.vercel.app`

#### 步骤 2：创建 apple-app-site-association 文件

在 Vercel 项目的 `public` 目录创建 `.well-known/apple-app-site-association` 文件：

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

**重要**：
- 将 `TEAM_ID` 替换为你的 Apple Team ID
- 文件必须是纯文本，**不要**添加 `.json` 扩展名
- 文件必须可以通过 HTTPS 访问：`https://lifelab-tau.vercel.app/.well-known/apple-app-site-association`

#### 步骤 3：配置 Supabase

1. **在 Supabase Dashboard 中设置**
   - Site URL: `https://lifelab-tau.vercel.app`
   - Redirect URLs: `https://lifelab-tau.vercel.app/auth/confirm`

2. **在代码中设置**（已完成）
   - `redirect_to`: `https://lifelab-tau.vercel.app/auth/confirm`

#### 步骤 4：创建确认页面

确认页面 (`public/auth/confirm.html`) 已创建，它会：
1. 显示确认成功消息
2. 尝试通过 Universal Link 打开应用
3. 如果应用未安装，显示手动打开应用的提示

### 方案 2：使用自定义 URL Scheme（简单但有限制）

如果 Universal Links 配置复杂，可以使用自定义 URL scheme：

1. **在 Xcode 中配置 URL Types**
   - 选择 **LifeLab** target
   - 进入 **Info** 标签
   - 展开 **URL Types**
   - 添加新的 URL Type：
     - **Identifier**: `com.resonance.lifelab`
     - **URL Schemes**: `lifelab`

2. **在 Supabase 中设置**
   - `redirect_to`: `lifelab://auth/confirm`

3. **在代码中处理**（已完成）
   - `LifeLabApp.swift` 中的 `handleURL` 函数会处理这个 URL

**限制**：
- 如果应用未安装，链接无法打开
- 不如 Universal Links 优雅

## 当前实现

### 代码更改

1. **`SupabaseService.swift`**
   - `redirect_to` 设置为：`https://lifelab-tau.vercel.app/auth/confirm`

2. **`LifeLabApp.swift`**
   - 添加了 `onOpenURL` 处理
   - 添加了 `handleURL` 函数来处理确认链接

3. **`EmailConfirmationView.swift`**（新文件）
   - 显示确认状态的 SwiftUI 视图

4. **`public/auth/confirm.html`**（新文件）
   - 确认页面，显示成功消息并尝试打开应用

## 测试步骤

### 1. 测试邮箱注册

1. 使用邮箱注册新账户
2. 检查收到的确认邮件
3. 点击邮件中的链接
4. 应该：
   - 如果应用已安装：直接打开应用
   - 如果应用未安装：打开网页，显示确认消息

### 2. 验证 Universal Links

```bash
# 测试 apple-app-site-association 文件
curl https://lifelab-tau.vercel.app/.well-known/apple-app-site-association
```

应该返回 JSON 内容（无 `.json` 扩展名）。

### 3. 验证 URL 处理

在应用中测试：
- 打开 Safari
- 访问：`https://lifelab-tau.vercel.app/auth/confirm`
- 应该自动打开应用（如果已安装）

## 重要提示

⚠️ **Universal Links 要求**：
1. 必须使用 HTTPS
2. `apple-app-site-association` 文件必须可访问
3. 文件必须是纯文本 JSON（无扩展名）
4. 必须在 Apple Developer Portal 配置 Associated Domains
5. 必须在 Xcode 中启用 Associated Domains capability

⚠️ **Vercel 部署**：
- 确保 `public/.well-known/apple-app-site-association` 文件被部署
- 文件必须可以通过 HTTPS 访问
- 检查 Vercel 的部署日志确认文件已上传

## 故障排查

### 问题：链接不打开应用

1. **检查 Associated Domains**
   - 确认在 Apple Developer Portal 和 Xcode 中都已配置

2. **检查 apple-app-site-association**
   - 确认文件可以通过 HTTPS 访问
   - 确认文件格式正确（纯文本 JSON）

3. **清除缓存**
   - iOS 会缓存 Universal Links
   - 重启设备或清除 Safari 缓存

### 问题：网页显示但应用不打开

- 检查 URL scheme 是否正确
- 检查 `onOpenURL` 是否正确处理
- 查看 Xcode 控制台日志

## 总结

✅ **当前状态**：
- 代码已更新，使用 Vercel 域名作为 redirect URL
- 确认页面已创建
- URL 处理已实现

📋 **需要你做的**：
1. 在 Apple Developer Portal 配置 Associated Domains
2. 在 Xcode 中启用 Associated Domains capability
3. 在 Vercel 部署 `apple-app-site-association` 文件
4. 测试邮箱确认流程
