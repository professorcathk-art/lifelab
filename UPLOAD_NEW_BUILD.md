# 如何上传新构建版本到 App Store Connect

## 问题
在 App Store Connect 的"建置版本"中只能看到旧版本，无法选择新版本提交审核。

## 解决方案：上传新构建版本

### 方法 1：使用 Xcode（推荐）

#### 步骤 1：更新版本号（如果需要）
1. 打开 Xcode
2. 选择项目 `LifeLab.xcodeproj`
3. 选择 **LifeLab** target
4. 进入 **General** 标签
5. 检查 **Version** 和 **Build** 号：
   - **Version**: 1.0（或更新为 1.0.1）
   - **Build**: 需要比之前的构建号更高（例如：如果之前是 1，现在改为 2）

#### 步骤 2：Archive（归档）
1. 在 Xcode 顶部工具栏，选择 **Any iOS Device** 或 **Generic iOS Device**（不要选择模拟器）
2. 菜单：**Product** → **Archive**
3. 等待构建完成（可能需要几分钟）

#### 步骤 3：上传到 App Store Connect
1. Archive 完成后，**Organizer** 窗口会自动打开
2. 选择刚创建的 Archive
3. 点击 **Distribute App**
4. 选择 **App Store Connect**
5. 点击 **Next**
6. 选择 **Upload**（上传）
7. 点击 **Next**
8. 选择分发选项（通常选择默认选项）
9. 点击 **Next**
10. 检查签名设置（通常自动管理）
11. 点击 **Upload**
12. 等待上传完成（可能需要 5-15 分钟）

#### 步骤 4：等待处理
1. 上传完成后，前往 **App Store Connect**
2. 进入 **我的 App** → **LifeLab** → **TestFlight** 或 **App Store** → **App 审核**
3. 等待 Apple 处理构建版本（通常需要 10-30 分钟）
4. 处理完成后，新版本会出现在"建置版本"下拉菜单中

---

### 方法 2：使用命令行（如果 Xcode GUI 有问题）

#### 步骤 1：更新版本号
在 Xcode 中手动更新 Build 号（见方法 1 步骤 1）

#### 步骤 2：Archive
```bash
cd /Users/mickeylau/lifelab

# 清理之前的构建
xcodebuild clean -project LifeLab/LifeLab.xcodeproj \
                 -scheme LifeLab \
                 -configuration Release

# 创建 Archive
xcodebuild archive -project LifeLab/LifeLab.xcodeproj \
                   -scheme LifeLab \
                   -configuration Release \
                   -archivePath ./build/LifeLab.xcarchive \
                   -destination 'generic/platform=iOS' \
                   CODE_SIGN_IDENTITY="Apple Development" \
                   CODE_SIGN_STYLE=Automatic \
                   DEVELOPMENT_TEAM=YUNUL5V5R6
```

#### 步骤 3：导出 IPA
```bash
# 导出 IPA（用于上传）
xcodebuild -exportArchive \
           -archivePath ./build/LifeLab.xcarchive \
           -exportPath ./build/export \
           -exportOptionsPlist exportOptions.plist
```

**注意**：需要先创建 `exportOptions.plist` 文件（见下方）

#### 步骤 4：使用 Transporter 或 altool 上传
```bash
# 使用 altool（需要 Xcode 13 或更早版本）
xcrun altool --upload-app \
             --type ios \
             --file ./build/export/LifeLab.ipa \
             --username "your-apple-id@example.com" \
             --password "@keychain:Application-Specific-Password"
```

---

### 创建 exportOptions.plist（方法 2 需要）

创建文件 `/Users/mickeylau/lifelab/exportOptions.plist`：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>YUNUL5V5R6</string>
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
    <key>compileBitcode</key>
    <false/>
    <key>signingStyle</key>
    <string>automatic</string>
</dict>
</plist>
```

---

## 常见问题

### Q: Archive 按钮是灰色的？
**A**: 确保选择了 **Any iOS Device** 或 **Generic iOS Device**，而不是模拟器。

### Q: 上传后看不到新版本？
**A**: 等待 10-30 分钟让 Apple 处理构建版本。可以在 **App Store Connect** → **TestFlight** 中查看处理状态。

### Q: 构建失败？
**A**: 
1. 检查签名设置：**Signing & Capabilities** → 确保选择了正确的 Team
2. 检查证书是否有效
3. 清理构建：**Product** → **Clean Build Folder** (⇧⌘K)

### Q: 版本号需要更新吗？
**A**: 
- **Version**（版本号）：如果只是修复，可以保持 1.0
- **Build**（构建号）：**必须**比之前的构建号更高（例如：1 → 2 → 3）

---

## 快速检查清单

- [ ] 更新了 Build 号（比之前更高）
- [ ] 选择了 **Any iOS Device**（不是模拟器）
- [ ] 成功创建了 Archive
- [ ] 成功上传到 App Store Connect
- [ ] 等待 Apple 处理完成（10-30 分钟）
- [ ] 在 App Store Connect 中看到新版本
- [ ] 可以在"建置版本"下拉菜单中选择新版本

---

## 下一步

上传完成后：
1. 在 **App Store Connect** → **App 审核** → **建置版本**中选择新版本
2. 在 **Resolution Center** 中回复 Apple 的问题（使用 `APPLE_REVIEW_RESPONSE_FINAL.txt`）
3. 确保 **App Privacy** 信息已更新
4. 确保 **Privacy Policy URL** 已填写
5. 点击 **提交以供審核**
