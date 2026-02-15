# Bundle ID 更新记录

## ✅ Bundle ID 已更新

### 新的 Bundle ID
```
com.resonance.lifelab
```

---

## 📝 已更新的文件

### 1. Xcode 项目文件
- **文件**: `LifeLab/LifeLab.xcodeproj/project.pbxproj`
- **更改**: 
  - `PRODUCT_BUNDLE_IDENTIFIER = com.lifelab.LifeLab;` 
  - → `PRODUCT_BUNDLE_IDENTIFIER = com.resonance.lifelab;`
- **位置**: 第 272 行和第 317 行（Debug 和 Release 配置）

### 2. Makefile
- **文件**: `Makefile`
- **更改**: 更新了 `launch` 命令中的 Bundle ID

### 3. 测试脚本
- **文件**: `test_without_xcode.sh`
- **更改**: 更新了启动命令中的 Bundle ID

---

## 🔍 验证更新

### 在 Xcode 中验证：
1. 打开 Xcode
2. 选择项目 → **LifeLab** target
3. **General** 标签
4. **Bundle Identifier** 应该显示：`com.resonance.lifelab`

### 使用命令行验证：
```bash
grep PRODUCT_BUNDLE_IDENTIFIER LifeLab/LifeLab.xcodeproj/project.pbxproj
```

应该看到：
```
PRODUCT_BUNDLE_IDENTIFIER = com.resonance.lifelab;
```

---

## 📋 Apple Developer 配置

### App ID
- **Bundle ID**: `com.resonance.lifelab`
- **Description**: `LifeLab`
- **Capabilities**: ✅ Sign In with Apple

### Service ID
- **Identifier**: `com.resonance.lifelab.service`
- **Description**: `LifeLab Service`
- **Return URL**: `https://inlzhosqbccyynofbmjt.supabase.co/auth/v1/callback`

---

## ⚠️ 重要提醒

1. **确保一致性**:
   - ✅ Xcode 项目: `com.resonance.lifelab`
   - ✅ Apple Developer App ID: `com.resonance.lifelab`
   - ✅ 必须完全匹配

2. **Supabase 配置**:
   - **Client ID**: `com.resonance.lifelab.service`
   - 在 Supabase Dashboard → Authentication → Providers → Apple 中配置

3. **重新构建**:
   - 更新 Bundle ID 后，建议清理并重新构建项目
   - 在 Xcode: Product → Clean Build Folder (Shift + Cmd + K)
   - 然后重新构建

---

## ✅ 更新完成

所有必要的文件已更新。您现在可以：
1. 在 Xcode 中验证 Bundle ID
2. 在 Apple Developer 中使用 `com.resonance.lifelab` 创建 App ID
3. 创建 Service ID: `com.resonance.lifelab.service`
4. 在 Supabase 中配置 Apple Sign In
