# 上传新版本到 App Store Connect 指南

## 📋 准备工作

### 0. ⚠️ 重要：设置 Supabase 数据库（首次上传前必须完成）

**如果你还没有设置 Supabase 数据库，请先完成以下步骤：**

1. **阅读 `SUPABASE_SETUP_GUIDE.md`** - 完整的 Supabase 设置指南
2. **运行 `SUPABASE_COMPLETE_SETUP.sql`** - 在 Supabase SQL Editor 中执行
3. **配置 Apple Sign In** - 在 Supabase Dashboard 中设置 OAuth
4. **验证数据同步** - 测试用户数据和订阅数据是否能正确保存

**重要说明**：
- ✅ **不需要 Vercel** - Supabase 本身就是完整的后端
- ✅ iOS 应用直接通过 HTTPS 调用 Supabase REST API
- ✅ 数据会自动同步到 PostgreSQL 数据库

### 1. 更新版本号

在 Xcode 中：
1. 选择项目文件（LifeLab）
2. 选择 Target "LifeLab"
3. 在 "General" 标签页中：
   - **Version**: 增加版本号（例如：1.0.1）
   - **Build**: 增加构建号（例如：如果当前是 10，改为 11）

### 2. 健康检查清单

✅ **代码检查**：
- [ ] 所有编译错误已修复
- [ ] 所有警告已处理
- [ ] iPad 兼容性已验证
- [ ] 支付功能正常工作
- [ ] 数据同步到 Supabase 正常

✅ **功能测试**：
- [ ] 支付流程完整测试
- [ ] 蓝图生成后自动跳转首页
- [ ] 订阅数据保存到 Supabase
- [ ] 用户数据同步正常
- [ ] iPad 界面显示正常

## 🚀 上传步骤

### 步骤 1: Archive（归档）

1. 在 Xcode 顶部菜单选择：
   - **Product** → **Scheme** → **LifeLab**
   - **Product** → **Destination** → **Any iOS Device**（不要选择模拟器）

2. 创建 Archive：
   - **Product** → **Archive**
   - 等待构建完成（可能需要几分钟）

3. Organizer 窗口会自动打开

### 步骤 2: 验证 Archive

1. 在 Organizer 窗口中，选择刚创建的 Archive
2. 点击 **"Validate App"** 按钮
3. 选择分发选项：
   - ✅ **App Store Connect**
   - 点击 **Next**
4. 选择分发选项：
   - ✅ **Upload**
   - 点击 **Next**
5. 选择证书和描述文件（通常自动选择）
6. 点击 **Validate**
7. 等待验证完成（检查是否有错误）

### 步骤 3: 上传到 App Store Connect

1. 验证通过后，点击 **"Distribute App"** 按钮
2. 选择分发方式：
   - ✅ **App Store Connect**
   - 点击 **Next**
3. 选择上传选项：
   - ✅ **Upload**
   - 点击 **Next**
4. 选择分发选项：
   - ✅ **Automatically manage signing**（推荐）
   - 或手动选择证书和描述文件
   - 点击 **Next**
5. 确认信息：
   - 检查版本号和构建号
   - 点击 **Upload**
6. 等待上传完成（可能需要 10-30 分钟）

### 步骤 4: 在 App Store Connect 中处理

1. 登录 [App Store Connect](https://appstoreconnect.apple.com)
2. 进入 **"我的 App"** → 选择你的应用
3. 等待处理完成（通常需要 10-30 分钟）：
   - 状态会显示为 **"处理中"**
   - 完成后状态变为 **"准备提交"**

4. 选择新版本：
   - 进入 **"版本"** 标签页
   - 点击 **"+"** 创建新版本（如果还没有）
   - 在 **"建置版本"** 下拉菜单中选择新上传的构建

5. 填写版本信息：
   - **版本号**：例如 1.0.1
   - **此版本的新功能**：描述本次更新的内容
   - **关键词**：保持不变或更新
   - **支持网址**：保持不变
   - **营销网址**：保持不变
   - **隐私政策网址**：保持不变

6. 添加截图（如果需要更新）：
   - iPhone 截图
   - iPad 截图（如果支持）

7. 检查 App 内购买项目：
   - 确保 IAP 产品状态为 **"准备提交"** 或 **"等待审核"**
   - 如果状态是 **"缺少元数据"**，需要完成产品信息

8. 提交审核：
   - 点击右上角 **"提交以供审核"**
   - 确认所有必填信息已填写
   - 点击 **"提交"**

## ⚠️ 常见问题

### 问题 1: "建置版本" 下拉菜单中没有新版本

**解决方案**：
- 等待 App Store Connect 处理完成（可能需要 30-60 分钟）
- 刷新页面
- 检查 Archive 是否成功上传

### 问题 2: 验证失败

**常见原因**：
- 证书过期
- 描述文件不匹配
- 代码签名问题

**解决方案**：
- 在 Xcode 中：**Preferences** → **Accounts** → 选择你的 Apple ID → **Download Manual Profiles**
- 重新创建 Archive

### 问题 3: 上传失败

**常见原因**：
- 网络问题
- 文件太大
- 服务器问题

**解决方案**：
- 检查网络连接
- 重试上传
- 如果持续失败，使用 **Transporter** 应用上传

## 📝 本次更新内容摘要

### 修复的问题：
1. ✅ 支付按钮状态：支付后按钮保持禁用，防止重复购买
2. ✅ 自动导航：蓝图生成完成后立即跳转到首页
3. ✅ 订阅数据同步：订阅计划自动保存到 Supabase 数据库
4. ✅ 用户数据同步：所有用户数据自动同步到 Supabase
5. ✅ iPad 兼容性：所有界面在 iPad 上正常显示

### 技术改进：
- 优化了支付流程的状态管理
- 改进了数据同步机制
- 增强了错误处理
- 优化了用户体验

## 🔍 上传后检查清单

上传完成后，在 App Store Connect 中检查：

- [ ] 新构建已出现在 "建置版本" 列表中
- [ ] 版本号正确
- [ ] 构建号已增加
- [ ] IAP 产品状态正确
- [ ] 所有必填信息已填写
- [ ] 截图已更新（如需要）

## 📞 需要帮助？

如果遇到问题：
1. 检查 Xcode 控制台的错误信息
2. 查看 App Store Connect 的 "活动" 标签页
3. 参考 [Apple 官方文档](https://developer.apple.com/documentation/appstoreconnectapi)

---

**最后更新**: 2024年
**版本**: 1.0
