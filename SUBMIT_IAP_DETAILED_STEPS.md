# 详细步骤：如何在版本页面添加订阅产品

## ⚠️ 为什么看不到 "App 内购买项目和订阅项目"？

可能的原因：
1. **还没有上传新的 Build（Binary）**
2. **还没有创建新版本**
3. **Build 还在处理中**
4. **界面位置不同**

---

## 📋 完整步骤（按顺序）

### 步骤 1：确认订阅产品已创建 ✅
你已经完成了：
- ✅ 创建了订阅组
- ✅ 创建了 3 个订阅产品（年付、季付、月付）

### 步骤 2：上传新的 App Binary（必须先完成）

#### 2.1 在 Xcode 中 Archive
1. 打开 Xcode
2. 选择 **Product** → **Archive**
3. 等待 Archive 完成（可能需要几分钟）

#### 2.2 上传到 App Store Connect
1. Archive 完成后，会弹出 **Organizer** 窗口
2. 选择你刚创建的 Archive（最新的那个）
3. 点击 **Distribute App** 按钮
4. 选择 **App Store Connect**
5. 点击 **Next**
6. 选择 **Upload**（不是 Export）
7. 点击 **Next**
8. 选择你的开发者账号和证书
9. 点击 **Upload**
10. 等待上传完成

#### 2.3 等待处理
1. 登录 [App Store Connect](https://appstoreconnect.apple.com)
2. 进入 **My Apps** → **LifeLab**
3. 点击 **TestFlight** 标签
4. 等待你的 Build 出现并显示为：
   - ✅ "Processing"（处理中）
   - ✅ "Ready to Submit"（准备提交）

**⏰ 通常需要 10-30 分钟**

---

### 步骤 3：创建新版本并选择 Build

1. **进入 App Store 标签**
   - 在 App Store Connect 中
   - 点击 **App Store** 标签（不是 TestFlight）

2. **创建新版本**
   - 如果这是第一次提交，点击 **+ Version** 按钮
   - 或者点击现有的版本号（如果有）

3. **填写版本信息**
   - **Version:** 例如 `1.0.0`
   - **What's New in This Version:** 填写更新说明

4. **选择 Build（重要！）**
   - 滚动到 **Build** 部分
   - 点击 **+** 按钮（或 "Select a build before you submit your app"）
   - 选择你刚上传的 Build（应该显示为 "Ready to Submit"）
   - 点击 **Done**

**⚠️ 必须完成这一步，否则看不到订阅产品选项！**

---

### 步骤 4：添加订阅产品（关键步骤）

#### 方法 A：标准位置

1. **在版本页面中，滚动查找：**
   - 查找 **"App 内购买项目和订阅项目"** 或
   - **"In-App Purchases and Subscriptions"** 或
   - **"订阅项目"** 或
   - **"Subscriptions"**

2. **如果看到这个部分：**
   - 点击 **+** 按钮
   - 会弹出订阅组选择窗口
   - 选择你的订阅组（LifeLab Premium Subscriptions）
   - 选择所有 3 个产品：
     - ✅ com.resonance.lifelab.annually
     - ✅ com.resonance.lifelab.quarterly
     - ✅ com.resonance.lifelab.monthly
   - 点击 **Done**

#### 方法 B：如果找不到这个部分

**可能的原因和解决方案：**

**原因 1：Build 还没处理完成**
- ✅ 解决方案：等待 Build 状态变为 "Ready to Submit"
- ✅ 检查位置：TestFlight 标签

**原因 2：还没有选择 Build**
- ✅ 解决方案：先完成步骤 3（选择 Build）

**原因 3：界面位置不同**
- ✅ 尝试查找：
    - 在 **Build** 部分下方
    - 在 **App 信息** 部分下方
    - 在页面右侧的侧边栏
    - 在 **"准备提交"** 或 **"Ready to Submit"** 按钮附近

**原因 4：需要先填写其他信息**
- ✅ 尝试先填写：
    - App 截图（至少一张）
    - 描述
    - 关键词
    - 然后保存，再查看是否出现

---

### 步骤 5：替代方法 - 通过 Features 标签

如果版本页面确实找不到，可以尝试：

1. **进入 Features 标签**
   - App Store Connect → My Apps → LifeLab
   - 点击 **Features** 标签（顶部导航）

2. **进入 In-App Purchases**
   - 点击左侧的 **In-App Purchases**
   - 你应该能看到你的 3 个订阅产品

3. **检查产品状态**
   - 每个产品应该显示状态：
     - "Ready to Submit"（准备提交）
     - "Waiting for Review"（等待审核）
     - "In Review"（审核中）

4. **如果产品状态是 "Ready to Submit"：**
   - 点击每个产品
   - 查看页面底部是否有 **"Submit for Review"** 按钮
   - **但是**：首次提交时，这个按钮可能不可用，因为需要与 App 版本一起提交

---

### 步骤 6：通过 App 版本一起提交（推荐方法）

**如果版本页面确实没有订阅产品选项，尝试：**

1. **确保所有信息已填写：**
   - ✅ Build 已选择
   - ✅ 至少一张截图已上传
   - ✅ 描述已填写
   - ✅ 关键词已填写
   - ✅ 支持网址已填写
   - ✅ 隐私政策网址已填写

2. **保存版本**
   - 点击页面右上角的 **Save** 按钮
   - 等待保存完成

3. **刷新页面**
   - 按 Cmd+R (Mac) 或 F5 (Windows)
   - 或者关闭标签页重新打开

4. **再次查找订阅产品部分**
   - 应该在 Build 部分下方出现

---

### 步骤 7：如果还是找不到 - 联系 Apple 支持

如果以上方法都不行：

1. **检查你的账号权限**
   - 确保你有 **Admin** 或 **App Manager** 权限
   - 只有这些角色可以提交应用

2. **检查订阅产品状态**
   - Features → In-App Purchases
   - 确保所有产品都已创建完成
   - 确保所有必需信息都已填写

3. **联系 Apple 支持**
   - [Apple Developer Support](https://developer.apple.com/contact/)
   - 说明：无法在版本页面找到 "App 内购买项目和订阅项目" 选项

---

## 🔍 界面截图指引

### 你应该看到的界面结构：

```
App Store Connect → My Apps → LifeLab → App Store 标签

版本页面应该包含：
├── Version Information（版本信息）
│   ├── Version
│   └── What's New
├── Build（构建版本）
│   └── [选择 Build 的按钮]
├── App 内购买项目和订阅项目 ← 这里！
│   └── [添加订阅产品的按钮]
├── Screenshots（截图）
├── Description（描述）
└── ... 其他信息
```

---

## ✅ 检查清单

在提交之前，确认：

- [ ] Build 已上传并处理完成（TestFlight 标签中显示 "Ready to Submit"）
- [ ] 在 App Store 标签中创建了新版本
- [ ] 选择了新的 Build
- [ ] 上传了至少一张截图
- [ ] 填写了描述
- [ ] 填写了关键词
- [ ] 填写了支持网址
- [ ] 填写了隐私政策网址
- [ ] **找到了 "App 内购买项目和订阅项目" 部分**
- [ ] **选择了所有 3 个订阅产品**
- [ ] 点击了 "Submit for Review"

---

## 🆘 如果还是找不到

请告诉我：
1. 你是否已经上传了 Build？
2. Build 的状态是什么？（Processing / Ready to Submit）
3. 你是否已经创建了新版本？
4. 你是否已经选择了 Build？
5. 你看到的版本页面有哪些部分？（截图最好）

这样我可以更准确地帮你定位问题。
