# 同步代码到 GitHub 指南

## 🎯 目标仓库

**GitHub 仓库**：`https://github.com/professorcathk-art/lifelab`

**重要**：确保不会与其他 GitHub 仓库混淆！

---

## 📋 Step 1: 检查 Git 配置

### 1.1 检查远程仓库

```bash
cd /Users/mickeylau/lifelab
git remote -v
```

**应该显示**：
```
origin	https://github.com/professorcathk-art/lifelab.git (fetch)
origin	https://github.com/professorcathk-art/lifelab.git (push)
```

### 1.2 如果远程仓库不正确

```bash
# 更新远程仓库 URL
git remote set-url origin https://github.com/professorcathk-art/lifelab.git

# 验证
git remote -v
```

---

## 🔄 Step 2: 同步代码

### 2.1 添加所有更改

```bash
cd /Users/mickeylau/lifelab

# 添加所有更改的文件
git add .

# 或只添加特定文件/文件夹
# git add website/
# git add LifeLab/
```

### 2.2 提交更改

```bash
git commit -m "Update LifeLab app: Add website, payment integration, data sync fixes, and promo code feature"
```

### 2.3 推送到 GitHub

```bash
# 检查当前分支
git branch --show-current

# 推送到 main 分支
git push origin main

# 或如果是 master 分支
# git push origin master
```

---

## ⚠️ 注意事项

### 不要提交敏感文件

确保以下文件在 `.gitignore` 中：
- `Secrets.swift`（包含 API 密钥）
- `*.xcuserstate`
- `build/`
- `DerivedData/`

### 检查 .gitignore

```bash
cat .gitignore | grep -E "Secrets|xcuserstate|build|DerivedData"
```

---

## ✅ 验证同步

### 检查 GitHub

1. **访问**：https://github.com/professorcathk-art/lifelab
2. **确认文件已上传**
3. **确认是最新的提交**

---

## 🎯 快速命令（一键同步）

```bash
cd /Users/mickeylau/lifelab && \
git add . && \
git commit -m "Update LifeLab app with latest features" && \
git push origin main
```

---

## 📋 同步检查清单

- [ ] 确认远程仓库：`professorcathk-art/lifelab`
- [ ] 检查敏感文件已忽略
- [ ] 添加更改的文件
- [ ] 提交更改
- [ ] 推送到 GitHub
- [ ] 验证 GitHub 上的文件

---

## ✅ 完成！

代码已同步到 GitHub！
