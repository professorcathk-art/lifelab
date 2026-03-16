# GitHub 同步指南

**倉庫地址**：https://github.com/professorcathk-art/lifelab.git  
**當前分支**：需要檢查

---

## 🔍 步驟 1：檢查當前 Git 狀態

```bash
cd /Users/mickeylau/lifelab

# 檢查當前分支
git branch

# 檢查遠程倉庫
git remote -v

# 檢查狀態
git status

# 檢查最近的提交
git log --oneline -5
```

---

## 📝 步驟 2：準備提交

### 2.1 檢查更改

```bash
# 查看所有更改
git status

# 查看詳細更改
git diff

# 查看新增文件
git ls-files --others --exclude-standard
```

### 2.2 添加文件到暫存區

```bash
# 添加所有更改（推薦）
git add .

# 或選擇性添加
git add LifeLab/LifeLab/Services/SupabaseServiceV2.swift
git add LifeLab/LifeLab/Services/AuthService.swift
git add LifeLab/LifeLab/Services/DataService.swift
git add LifeLab/LifeLab.xcodeproj/project.pbxproj  # 版本號更新
git add *.md  # 文檔文件
```

### 2.3 檢查暫存區

```bash
# 查看暫存的文件
git status

# 查看將要提交的更改
git diff --cached
```

---

## 💾 步驟 3：提交更改

### 3.1 創建提交信息

```bash
# 提交所有更改
git commit -m "feat: Migrate to official Supabase Swift SDK 2.5.1

- Replace custom SupabaseService with SupabaseServiceV2 using official SDK
- Update all services to use SupabaseServiceV2
- Fix authentication methods (signIn, signUp, signInWithOAuth, resetPassword)
- Fix getCurrentUser async call
- Update database operations to use client.from() instead of deprecated client.database.from()
- Implement local-first strategy with UserDefaults caching
- Add comprehensive error handling and offline support
- Update version to 1.3.3 (Build 6)

Breaking changes:
- SupabaseService.shared replaced with SupabaseServiceV2.shared
- All database operations now use new API

Technical improvements:
- Automatic token management via official SDK
- Simplified JSONB handling with Codable
- Better error handling and retry logic
- Network monitoring and offline support"
```

### 3.2 或使用多行提交信息

```bash
git commit
```

然後在編輯器中輸入：
```
feat: Migrate to official Supabase Swift SDK 2.5.1

Major Changes:
- Replace custom SupabaseService with SupabaseServiceV2
- Update all services to use official SDK
- Implement local-first data strategy

Authentication:
- Fix signIn/signUp Session handling
- Fix getCurrentUser async call
- Add signInWithOAuth for Apple Sign In
- Add resetPassword method

Database Operations:
- Update to use client.from() (new API)
- Fix JSONB encoding/decoding
- Improve error handling

Data Management:
- Implement UserDefaults caching
- Add offline support
- Smart sync strategy

Version: 1.3.3 (Build 6)
```

---

## 🔄 步驟 4：同步到 GitHub

### 4.1 拉取最新更改（推薦先拉取）

```bash
# 拉取遠程更改
git pull origin main

# 如果有衝突，解決衝突後再提交
# git add .
# git commit -m "Merge remote changes"
```

### 4.2 推送到 GitHub

```bash
# 推送到 main 分支
git push origin main

# 或推送到當前分支
git push origin $(git branch --show-current)
```

### 4.3 如果推送失敗（分支不同步）

```bash
# 先拉取並合併
git pull origin main --rebase

# 然後推送
git push origin main
```

---

## 🏷️ 步驟 5：創建 Release Tag（可選但推薦）

### 5.1 創建版本標籤

```bash
# 創建帶註釋的標籤
git tag -a v1.3.3 -m "Release 1.3.3: Supabase SDK Migration

- Migrate to official Supabase Swift SDK 2.5.1
- Implement local-first data strategy
- Improve authentication and data sync
- Update version to 1.3.3 (Build 6)"
```

### 5.2 推送標籤到 GitHub

```bash
# 推送單個標籤
git push origin v1.3.3

# 或推送所有標籤
git push origin --tags
```

---

## 📋 完整工作流程（一鍵執行）

```bash
#!/bin/bash
# 完整同步腳本

cd /Users/mickeylau/lifelab

echo "🔍 Checking Git status..."
git status

echo ""
echo "📝 Staging changes..."
git add .

echo ""
echo "💾 Committing changes..."
git commit -m "feat: Migrate to official Supabase Swift SDK 2.5.1

- Replace custom SupabaseService with SupabaseServiceV2
- Update all services to use official SDK
- Fix authentication and database operations
- Implement local-first strategy
- Update version to 1.3.3 (Build 6)"

echo ""
echo "🔄 Pulling latest changes..."
git pull origin main --rebase

echo ""
echo "📤 Pushing to GitHub..."
git push origin main

echo ""
echo "🏷️ Creating release tag..."
git tag -a v1.3.3 -m "Release 1.3.3: Supabase SDK Migration"
git push origin v1.3.3

echo ""
echo "✅ Done! Changes synced to GitHub"
```

**保存為 `sync_to_github.sh` 並執行**：
```bash
chmod +x sync_to_github.sh
./sync_to_github.sh
```

---

## 🔐 步驟 6：處理認證（如果需要）

### 6.1 使用 Personal Access Token

如果推送時需要認證：

1. **創建 Token**
   - GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
   - 生成新 token，選擇 `repo` 權限

2. **使用 Token**
   ```bash
   # 設置遠程 URL（使用 token）
   git remote set-url origin https://YOUR_TOKEN@github.com/professorcathk-art/lifelab.git
   
   # 或使用 SSH（推薦）
   git remote set-url origin git@github.com:professorcathk-art/lifelab.git
   ```

### 6.2 配置 SSH（推薦）

```bash
# 檢查 SSH 密鑰
ls -la ~/.ssh

# 如果沒有，生成新的 SSH 密鑰
ssh-keygen -t ed25519 -C "your_email@example.com"

# 添加到 SSH agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# 複製公鑰（添加到 GitHub）
cat ~/.ssh/id_ed25519.pub

# 更新遠程 URL
git remote set-url origin git@github.com:professorcathk-art/lifelab.git
```

---

## 📊 步驟 7：驗證同步

### 7.1 檢查遠程狀態

```bash
# 檢查遠程分支
git remote show origin

# 比較本地和遠程
git log origin/main..main  # 本地有但遠程沒有的提交
git log main..origin/main  # 遠程有但本地沒有的提交
```

### 7.2 在 GitHub 上驗證

1. 訪問：https://github.com/professorcathk-art/lifelab
2. 檢查最新提交
3. 檢查文件更改
4. 檢查標籤（如果創建了）

---

## 🚨 常見問題處理

### 問題 1：推送被拒絕

```bash
# 原因：遠程有新的提交
# 解決：先拉取再推送
git pull origin main --rebase
git push origin main
```

### 問題 2：合併衝突

```bash
# 1. 拉取時出現衝突
git pull origin main

# 2. 解決衝突（編輯文件）
# 3. 標記為已解決
git add .
git commit -m "Resolve merge conflicts"

# 4. 推送
git push origin main
```

### 問題 3：忘記提交某些文件

```bash
# 添加遺漏的文件
git add missing_file.swift
git commit --amend --no-edit  # 添加到上次提交
git push origin main --force-with-lease  # 強制推送（謹慎使用）
```

---

## ✅ 同步檢查清單

- [ ] Git 狀態檢查完成
- [ ] 所有更改已添加到暫存區
- [ ] 提交信息已創建
- [ ] 已拉取最新更改
- [ ] 已推送到 GitHub
- [ ] 版本標籤已創建（可選）
- [ ] 在 GitHub 上驗證同步成功

---

## 📚 Git 最佳實踐

### 提交信息格式
```
<type>: <subject>

<body>

<footer>
```

**類型**：
- `feat`: 新功能
- `fix`: Bug 修復
- `docs`: 文檔更改
- `style`: 代碼格式
- `refactor`: 重構
- `test`: 測試
- `chore`: 構建/工具

### 分支策略
- `main`: 生產代碼
- `develop`: 開發分支
- `feature/*`: 功能分支
- `hotfix/*`: 緊急修復

---

**準備就緒！可以開始同步到 GitHub 了！** 🚀
