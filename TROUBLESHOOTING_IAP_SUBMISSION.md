# 故障排除：找不到订阅产品选项

## 快速诊断

### 问题：在版本页面看不到 "App 内购买项目和订阅项目"

### 可能的原因和解决方案：

---

## ✅ 原因 1：Build 还没上传或处理完成

**症状：**
- 在 TestFlight 标签中看不到新的 Build
- Build 状态显示 "Processing"

**解决方案：**
1. 先完成 Build 上传（Xcode → Archive → Distribute App）
2. 等待 Build 处理完成（10-30 分钟）
3. 在 TestFlight 标签中确认 Build 状态为 "Ready to Submit"
4. 然后回到 App Store 标签

---

## ✅ 原因 2：还没有选择 Build

**症状：**
- 在版本页面，Build 部分显示 "Select a build before you submit your app"
- 或者 Build 部分为空

**解决方案：**
1. 在版本页面的 **Build** 部分
2. 点击 **+** 按钮或 "Select a build"
3. 选择你刚上传的 Build
4. 点击 **Done**
5. **保存版本**（点击右上角 Save）
6. 刷新页面
7. 现在应该能看到订阅产品选项了

---

## ✅ 原因 3：需要先填写必需信息

**症状：**
- Build 已选择
- 但订阅产品选项还是不出现

**解决方案：**
1. 先填写所有必需信息：
   - ✅ 上传至少一张截图（必需！）
   - ✅ 填写描述
   - ✅ 填写关键词
   - ✅ 填写支持网址
   - ✅ 填写隐私政策网址
2. 点击 **Save** 保存
3. 刷新页面
4. 现在应该能看到订阅产品选项了

---

## ✅ 原因 4：界面位置不同（中文/英文）

**中文界面可能显示为：**
- "App 内购买项目和订阅项目"
- "订阅项目"
- "应用内购买"

**英文界面显示为：**
- "In-App Purchases and Subscriptions"
- "Subscriptions"
- "In-App Purchases"

**查找位置：**
- 在 **Build** 部分下方
- 在 **Screenshots** 部分上方或下方
- 在页面右侧（如果有侧边栏）

---

## ✅ 原因 5：订阅产品还没准备好

**症状：**
- 在 Features → In-App Purchases 中
- 产品状态显示 "Missing Metadata" 或其他错误

**解决方案：**
1. 进入 Features → In-App Purchases
2. 检查每个产品的状态
3. 确保所有必需信息都已填写：
   - ✅ 产品 ID
   - ✅ 显示名称（至少英文）
   - ✅ 描述（至少英文）
   - ✅ 价格
   - ✅ 持续时间
4. 保存每个产品
5. 然后回到 App Store 标签

---

## ✅ 原因 6：账号权限不足

**症状：**
- 看不到某些选项
- 某些按钮是灰色的

**解决方案：**
1. 确认你的账号角色：
   - ✅ **Admin**（管理员）- 可以提交
   - ✅ **App Manager**（应用管理员）- 可以提交
   - ❌ **Developer**（开发者）- 不能提交
   - ❌ **Marketing**（营销）- 不能提交

2. 如果需要，联系账号管理员提升权限

---

## 🔍 详细查找步骤

### 步骤 1：确认你在正确的位置

1. App Store Connect → My Apps → LifeLab
2. 点击 **App Store** 标签（不是 TestFlight，不是 Features）
3. 点击 **+ Version** 或选择现有版本
4. 你现在应该在版本编辑页面

### 步骤 2：检查页面结构

版本页面应该包含这些部分（从上到下）：
1. Version Information（版本信息）
2. Build（构建版本）← 必须先选择这个！
3. **App 内购买项目和订阅项目** ← 在这里！
4. Screenshots（截图）
5. Description（描述）
6. Keywords（关键词）
7. Support URL（支持网址）
8. Marketing URL（营销网址，可选）
9. Privacy Policy URL（隐私政策网址）

### 步骤 3：如果 Build 部分下方没有订阅产品选项

尝试：
1. 点击 **Save** 保存当前版本
2. 刷新页面（Cmd+R 或 F5）
3. 重新打开版本页面
4. 检查是否出现

---

## 🆘 最后的解决方案

如果以上方法都不行：

### 方案 A：通过 App Review Information

1. 在版本页面，找到 **App Review Information** 部分
2. 查看是否有订阅产品相关的选项
3. 或者查看 **Notes** 部分，可以在这里说明订阅产品

### 方案 B：联系 Apple 支持

1. 访问：[Apple Developer Support](https://developer.apple.com/contact/)
2. 选择 "App Store Connect" → "In-App Purchases"
3. 说明你的问题：
   - "我已经创建了 3 个订阅产品"
   - "但在版本页面找不到 'App 内购买项目和订阅项目' 选项"
   - "无法将订阅产品与 App 版本一起提交"

### 方案 C：临时解决方案

如果急需发布，可以考虑：
1. 先提交 App 版本（不包含订阅产品）
2. 在 App Review Notes 中说明：
   - "订阅功能将在下一个版本中启用"
   - "当前版本为免费版本"
3. 等 App 通过审核后，再提交包含订阅产品的版本

---

## 📸 需要的信息

如果你需要进一步帮助，请提供：

1. **截图：**
   - 版本页面的完整截图
   - 显示你看到的所有部分

2. **状态信息：**
   - Build 是否已上传？
   - Build 状态是什么？
   - 是否已选择 Build？
   - 订阅产品状态是什么？

3. **界面语言：**
   - 你使用的是中文还是英文界面？

---

## ✅ 标准流程回顾

正确的顺序应该是：

1. ✅ 创建订阅产品（已完成）
2. ✅ 上传 App Build（Xcode Archive）
3. ✅ 等待 Build 处理完成
4. ✅ 在 App Store 标签创建新版本
5. ✅ **选择 Build**（关键！）
6. ✅ **添加订阅产品**（在版本页面）
7. ✅ 填写其他信息
8. ✅ 提交审核

**关键点：必须先选择 Build，订阅产品选项才会出现！**
