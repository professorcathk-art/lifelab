# Apple Sign In - Bundle ID 配置

## 📋 您的 Bundle ID

根据您的 Xcode 项目配置：

```
com.lifelab.LifeLab
```

---

## ✅ 在 Apple Developer 中创建 App ID 时

### Bundle ID 填写：

1. **选择类型**:
   - 选择 **Explicit**（不是 Wildcard）
   - ⚠️ 不要选择 Wildcard（`*`）

2. **输入 Bundle ID**:
   ```
   com.lifelab.LifeLab
   ```

3. **验证**:
   - 确保与 Xcode 项目中的 Bundle ID 完全一致
   - 在 Xcode 中查看：项目设置 → General → Bundle Identifier

---

## 🔍 如何验证您的 Bundle ID

### 在 Xcode 中查看：
1. 打开 Xcode
2. 选择项目 → **LifeLab** target
3. **General** 标签
4. 查看 **Bundle Identifier**
5. 应该显示：`com.lifelab.LifeLab`

### 或查看项目文件：
```bash
grep PRODUCT_BUNDLE_IDENTIFIER LifeLab/LifeLab.xcodeproj/project.pbxproj
```

---

## ⚠️ 重要提醒

1. **必须完全一致**:
   - Xcode 项目: `com.lifelab.LifeLab`
   - Apple Developer App ID: `com.lifelab.LifeLab`
   - 必须完全匹配，包括大小写

2. **不要使用 Wildcard**:
   - ❌ 不要使用: `com.lifelab.*`
   - ✅ 必须使用: `com.lifelab.LifeLab`

3. **如果 Bundle ID 已被使用**:
   - 如果这个 Bundle ID 已经被其他 App ID 使用
   - 您需要：
     - 选项 1: 使用不同的 Bundle ID（需要修改 Xcode 项目）
     - 选项 2: 删除旧的 App ID（如果不再使用）

---

## 📝 完整配置信息

基于您的项目：

- **Bundle ID**: `com.lifelab.LifeLab`
- **App ID**: `com.lifelab.LifeLab`
- **Service ID**: `com.lifelab.LifeLab.service`
- **Return URL**: `https://inlzhosqbccyynofbmjt.supabase.co/auth/v1/callback`

---

## ✅ 检查清单

- [ ] Bundle ID 与 Xcode 项目完全一致
- [ ] 选择了 Explicit（不是 Wildcard）
- [ ] 勾选了 Sign In with Apple capability
- [ ] 成功注册了 App ID
