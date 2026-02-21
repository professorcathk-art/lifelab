# Vercel 部署配置指南

## 🎯 Vercel 设置

### Application Preset（应用预设）

**选择**：`Other` 或 `Static Site`

**原因**：
- 这是一个纯静态网站（HTML 文件）
- 不需要框架（React、Next.js、Vue 等）
- 不需要构建步骤
- 只需要托管静态文件

**选项说明**：
- ✅ **Other** - 推荐选择这个
- ✅ **Static Site** - 也可以选择这个
- ❌ **Next.js** - 不适用（不是 Next.js 项目）
- ❌ **React** - 不适用（不是 React 项目）
- ❌ **Vue** - 不适用（不是 Vue 项目）

---

### Root Directory（根目录）

**设置**：`website`

**原因**：
- 网站文件都在 `website/` 目录中
- Vercel 需要知道从哪里读取文件
- 设置为 `website` 后，Vercel 会在 `website/` 目录中查找文件

**如何设置**：
1. 在 Vercel 项目设置中
2. 找到 "Root Directory" 选项
3. 输入：`website`
4. 保存

---

## 📋 完整部署步骤

### Step 1: 导入项目

1. **访问**：https://vercel.com
2. **登录**（使用 GitHub 账号）
3. **点击** "Add New Project" 或 "Import Project"
4. **选择仓库**：`professorcathk-art/lifelab`

### Step 2: 配置项目

#### 2.1 Framework Preset（框架预设）

**选择**：`Other`

#### 2.2 Root Directory（根目录）

**输入**：`website`

#### 2.3 Build Command（构建命令）

**留空** 或 **删除**（因为不需要构建）

#### 2.4 Output Directory（输出目录）

**留空** 或设置为 `.`（当前目录）

#### 2.5 Install Command（安装命令）

**留空**（不需要安装依赖）

### Step 3: 环境变量（如果需要）

**不需要设置**（这是纯静态网站）

### Step 4: 部署

1. **点击** "Deploy"
2. **等待部署完成**（通常几秒钟）
3. **获得 URL**（例如：`https://lifelab-xxx.vercel.app`）

---

## ✅ 验证部署

### 检查 URL

部署完成后，您会获得一个 URL，例如：
- `https://lifelab-xxx.vercel.app`
- `https://lifelab-xxx.vercel.app/support.html`
- `https://lifelab-xxx.vercel.app/privacy.html`

### 测试页面

1. **主页**：`https://your-url.vercel.app/`
2. **支援页面**：`https://your-url.vercel.app/support.html`
3. **隐私政策**：`https://your-url.vercel.app/privacy.html`

---

## 🔧 配置说明

### vercel.json 配置

您的 `website/vercel.json` 文件已配置好：

```json
{
  "version": 2,
  "builds": [
    {
      "src": "**/*.html",
      "use": "@vercel/static"
    }
  ],
  "routes": [
    {
      "src": "/support.html",
      "dest": "/support.html"
    },
    {
      "src": "/privacy.html",
      "dest": "/privacy.html"
    },
    {
      "src": "/",
      "dest": "/index.html"
    }
  ]
}
```

这个配置告诉 Vercel：
- 使用静态文件托管
- 路由 HTML 文件
- 主页指向 `index.html`

---

## 📝 在 App Store Connect 中使用

### Support URL（支援 URL）

```
https://your-url.vercel.app/support.html
```

### Privacy Policy URL（隐私政策 URL）

```
https://your-url.vercel.app/privacy.html
```

---

## 🎯 快速设置总结

| 设置项 | 值 |
|--------|-----|
| **Framework Preset** | `Other` |
| **Root Directory** | `website` |
| **Build Command** | （留空） |
| **Output Directory** | `.` 或（留空） |
| **Install Command** | （留空） |

---

## ✅ 检查清单

### Vercel 设置
- [ ] Framework Preset: `Other`
- [ ] Root Directory: `website`
- [ ] Build Command: （留空）
- [ ] 项目已部署
- [ ] 获得部署 URL

### 测试
- [ ] 主页可以访问
- [ ] 支援页面可以访问
- [ ] 隐私政策页面可以访问

### App Store Connect
- [ ] Support URL 已填写
- [ ] Privacy Policy URL 已填写

---

## 🚀 完成！

部署完成后，您将获得：
1. ✅ 网站 URL（用于 App Store Connect）
2. ✅ 支援页面 URL
3. ✅ 隐私政策 URL

**下一步**：在 App Store Connect 中填写这些 URL！
