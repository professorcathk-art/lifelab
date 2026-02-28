# 🚀 上线前检查清单

## ✅ 代码健康检查

### 1. 编译和警告
- [x] ✅ 所有编译错误已修复
- [x] ✅ 所有警告已处理（已修复未使用的变量和废弃的 API）
- [x] ✅ 代码可以成功构建

### 2. 功能完整性
- [x] ✅ 用户注册和登录（Email + Apple Sign In）
- [x] ✅ 初步扫描问卷流程
- [x] ✅ AI 生成生命藍圖
- [x] ✅ 支付和订阅功能
- [x] ✅ 数据同步到 Supabase
- [x] ✅ iPad 兼容性

### 3. 支付和订阅
- [x] ✅ StoreKit 2 集成
- [x] ✅ 订阅数据保存到 Supabase
- [x] ✅ 订阅状态检查（StoreKit + Supabase）
- [x] ✅ 网络错误时的后备逻辑（优先用户体验）

### 4. 数据同步
- [x] ✅ 用户数据同步到 Supabase
- [x] ✅ 订阅数据同步到 Supabase
- [x] ✅ 本地缓存机制
- [x] ✅ 网络错误处理

### 5. 用户体验
- [x] ✅ 蓝图生成后自动跳转首页
- [x] ✅ 支付按钮状态管理
- [x] ✅ 加载状态提示
- [x] ✅ 错误提示和重试机制

---

## 📋 App Store Connect 准备

### 1. 版本信息
- [ ] 版本号：`1.0.0`（或更新）
- [ ] 构建号：已增加（例如：从 10 到 11）
- [ ] 版本说明：准备好更新内容描述

### 2. 应用信息
- [ ] 应用名称
- [ ] 应用描述
- [ ] 关键词
- [ ] 支持网址
- [ ] 隐私政策网址
- [ ] 营销网址（可选）

### 3. 截图和预览
- [ ] iPhone 截图（所有必需尺寸）
- [ ] iPad 截图（如果支持）
- [ ] 应用预览视频（可选）

### 4. 应用内购买
- [ ] 年付订阅产品（`com.resonance.lifelab.annually`）
- [ ] 季付订阅产品（`com.resonance.lifelab.quarterly`）
- [ ] 月付订阅产品（`com.resonance.lifelab.monthly`）
- [ ] 所有产品状态为 "准备提交" 或 "等待审核"

### 5. 隐私和权限
- [ ] 隐私政策已更新
- [ ] 数据收集说明已填写
- [ ] 第三方服务说明已填写（AI 服务、Supabase）

---

## 🔧 Supabase 配置检查

### 1. 数据库设置
- [ ] `user_profiles` 表已创建
- [ ] `user_subscriptions` 表已创建
- [ ] RLS 策略已启用
- [ ] RLS 策略已正确配置

### 2. 认证设置
- [ ] Email/Password 认证已启用
- [ ] Apple Sign In 已配置
- [ ] Redirect URLs 已设置
- [ ] Site URL 已配置

### 3. API 密钥
- [ ] `Secrets.swift` 中的密钥已更新
- [ ] Anon Key 正确
- [ ] Project URL 正确

---

## 🧪 测试清单

### 1. 核心功能测试
- [ ] 新用户注册流程
- [ ] 用户登录流程
- [ ] 初步扫描问卷完成
- [ ] AI 生成生命藍圖
- [ ] 支付流程（Sandbox 测试）
- [ ] 订阅数据保存
- [ ] 数据同步到 Supabase

### 2. 边界情况测试
- [ ] 网络断开时的行为
- [ ] 支付失败时的处理
- [ ] 数据同步失败时的处理
- [ ] 订阅过期时的处理

### 3. 设备测试
- [ ] iPhone（最新 iOS）
- [ ] iPad（如果支持）
- [ ] 不同屏幕尺寸

---

## 📝 上传步骤

### 步骤 1: 更新版本号
1. 在 Xcode 中选择项目
2. 选择 Target "LifeLab"
3. 在 "General" 标签页：
   - **Version**: `1.0.0`
   - **Build**: 增加构建号（例如：11）

### 步骤 2: Archive
1. **Product** → **Scheme** → **LifeLab**
2. **Product** → **Destination** → **Any iOS Device**
3. **Product** → **Archive**
4. 等待构建完成

### 步骤 3: 验证和上传
1. 在 Organizer 中选择 Archive
2. 点击 **"Validate App"**
3. 验证通过后，点击 **"Distribute App"**
4. 选择 **App Store Connect** → **Upload**
5. 等待上传完成

### 步骤 4: App Store Connect
1. 登录 [App Store Connect](https://appstoreconnect.apple.com)
2. 选择应用 → **版本** 标签页
3. 选择新构建版本
4. 填写版本信息
5. 提交审核

---

## ⚠️ 重要提醒

### 上线前必须完成：
1. ✅ Supabase 数据库已设置
2. ✅ RLS 策略已配置
3. ✅ API 密钥已更新
4. ✅ 支付产品已创建并提交审核
5. ✅ 隐私政策已更新
6. ✅ 所有功能已测试

### 上线后监控：
1. 用户注册和登录数据
2. 支付和订阅数据
3. 数据同步状态
4. 错误日志和崩溃报告

---

## 🆘 遇到问题？

### 常见问题：
1. **构建失败**：检查证书和描述文件
2. **上传失败**：检查网络连接，重试上传
3. **验证失败**：检查代码签名设置
4. **审核被拒**：查看拒绝原因，参考 `APPLE_REVIEW_RESPONSE.md`

### 参考文档：
- `UPLOAD_NEW_VERSION_GUIDE.md` - 详细上传指南
- `SUPABASE_SETUP_GUIDE.md` - Supabase 设置指南
- `APP_STORE_CONNECT_SUBSCRIPTION_GUIDE.md` - IAP 设置指南

---

**最后更新**: 2024年
**状态**: ✅ 准备上线
