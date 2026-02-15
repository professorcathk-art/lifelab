# GitHub 同步與 Vercel 部署指南

## 🎯 目標

1. 將網站文件同步到 GitHub 倉庫：`https://github.com/professorcathk-art/lifelab`
2. 部署到 Vercel
3. 獲得支援 URL 和隱私政策 URL

---

## 📋 Step 1: 準備文件

### 已創建的文件結構

```
website/
├── index.html      # 主頁面
├── support.html    # 支援頁面
├── privacy.html    # 隱私政策頁面
└── README.md       # 說明文件
```

所有文件已準備好！

---

## 🔄 Step 2: 同步到 GitHub

### 方法 1: 使用 Git 命令行（推薦）

#### 2.1 檢查 Git 狀態

```bash
cd /Users/mickeylau/lifelab
git status
```

#### 2.2 添加遠程倉庫（如果還沒有）

```bash
# 檢查是否已有遠程倉庫
git remote -v

# 如果沒有，添加遠程倉庫
git remote add origin https://github.com/professorcathk-art/lifelab.git

# 如果已有但 URL 不對，更新它
git remote set-url origin https://github.com/professorcathk-art/lifelab.git
```

#### 2.3 添加網站文件

```bash
# 只添加 website 文件夾
git add website/

# 或添加所有文件（如果這是新倉庫）
# git add .
```

#### 2.4 提交更改

```bash
git commit -m "Add website files for support and privacy policy"
```

#### 2.5 推送到 GitHub

```bash
# 如果是第一次推送
git push -u origin main

# 或如果主分支是 master
git push -u origin master

# 之後的推送
git push
```

### 方法 2: 使用 GitHub Desktop（圖形界面）

1. **打開 GitHub Desktop**
2. **添加倉庫**：
   - File → Add Local Repository
   - 選擇 `/Users/mickeylau/lifelab`
3. **提交更改**：
   - 選擇 `website/` 文件夾
   - 填寫提交訊息："Add website files for support and privacy policy"
   - 點擊 "Commit to main"
4. **推送到 GitHub**：
   - 點擊 "Push origin"

### 方法 3: 直接在 GitHub 網頁上傳

1. **訪問**：https://github.com/professorcathk-art/lifelab
2. **點擊 "Add file" → "Upload files"**
3. **拖拽 `website/` 文件夾中的所有文件**
4. **填寫提交訊息**："Add website files"
5. **點擊 "Commit changes"**

---

## 🚀 Step 3: 部署到 Vercel

### 方法 1: 通過 Vercel 網站（推薦）

#### 3.1 登錄 Vercel

1. **訪問**：https://vercel.com
2. **點擊 "Sign Up"** 或 **"Log In"**
3. **使用 GitHub 帳號登錄**（推薦，方便連接倉庫）

#### 3.2 導入項目

1. **點擊 "Add New..." → "Project"**
2. **選擇 GitHub 倉庫**：
   - 如果沒有看到 `professorcathk-art/lifelab`，點擊 "Adjust GitHub App Permissions"
   - 確保選擇了正確的倉庫
3. **選擇倉庫**：`professorcathk-art/lifelab`
4. **點擊 "Import"**

#### 3.3 配置項目

**Root Directory**：
- 選擇 `website`（重要！）
- 或保持空白，但需要修改設置

**Framework Preset**：
- 選擇 **"Other"** 或 **"Static"**

**Build Command**：
- 留空（靜態網站不需要構建）

**Output Directory**：
- 留空（文件在根目錄）

**Install Command**：
- 留空（不需要安裝依賴）

#### 3.4 部署

1. **點擊 "Deploy"**
2. **等待部署完成**（通常 1-2 分鐘）
3. **獲得 URL**：
   - 例如：`https://lifelab-xxx.vercel.app`
   - 或自定義域名（如果設置了）

### 方法 2: 使用 Vercel CLI

#### 3.1 安裝 Vercel CLI

```bash
npm install -g vercel
```

#### 3.2 登錄

```bash
vercel login
```

#### 3.3 部署

```bash
cd /Users/mickeylau/lifelab/website
vercel
```

**按照提示**：
- Set up and deploy? **Yes**
- Which scope? 選擇您的帳號
- Link to existing project? **No**（首次部署）
- Project name? `lifelab`（或您想要的名稱）
- Directory? `./`（當前目錄）

#### 3.4 生產環境部署

```bash
vercel --prod
```

---

## 🔧 Step 4: 配置 Vercel（重要）

### 4.1 設置 Root Directory

如果您的網站文件在 `website/` 文件夾中：

1. **在 Vercel Dashboard**：
   - 進入項目設置
   - **Settings** → **General** → **Root Directory**
   - 設置為：`website`
   - 保存

### 4.2 設置自定義域名（可選）

1. **在 Vercel Dashboard**：
   - **Settings** → **Domains**
   - 添加您的域名（例如：`lifelab.app`）
   - 按照指示配置 DNS

---

## 📝 Step 5: 獲取 URL

### 部署完成後

您會獲得以下 URL：

**主頁**：
```
https://lifelab-xxx.vercel.app/
```

**支援頁面**：
```
https://lifelab-xxx.vercel.app/support.html
```

**隱私政策頁面**：
```
https://lifelab-xxx.vercel.app/privacy.html
```

---

## ✅ Step 6: 在 App Store Connect 中使用

### 6.1 填寫 URL

在 App Store Connect 中：

**支援 URL**：
```
https://lifelab-xxx.vercel.app/support.html
```

**隱私政策 URL**：
```
https://lifelab-xxx.vercel.app/privacy.html
```

### 6.2 測試 URL

確保 URL 可以正常訪問：
1. 在瀏覽器中打開 URL
2. 檢查頁面是否正確顯示
3. 檢查所有連結是否正常

---

## 🔄 更新網站

### 更新文件後

1. **修改文件**（在本地）
2. **提交到 GitHub**：
   ```bash
   git add website/
   git commit -m "Update website content"
   git push
   ```
3. **Vercel 自動部署**：
   - Vercel 會自動檢測 GitHub 的更改
   - 自動觸發新的部署
   - 通常 1-2 分鐘內完成

---

## 🎨 自定義域名（可選）

### 設置自定義域名

1. **購買域名**（例如：`lifelab.app`）
2. **在 Vercel 中添加域名**：
   - Settings → Domains
   - 添加您的域名
3. **配置 DNS**：
   - 按照 Vercel 的指示配置 DNS 記錄
4. **等待生效**：
   - 通常需要幾分鐘到幾小時

**之後可以使用**：
- `https://lifelab.app/support.html`
- `https://lifelab.app/privacy.html`

---

## 📋 檢查清單

### GitHub 同步
- [ ] 添加遠程倉庫
- [ ] 添加 website 文件夾
- [ ] 提交更改
- [ ] 推送到 GitHub
- [ ] 確認文件在 GitHub 上可見

### Vercel 部署
- [ ] 登錄 Vercel
- [ ] 導入 GitHub 倉庫
- [ ] 設置 Root Directory 為 `website`
- [ ] 部署項目
- [ ] 獲得部署 URL
- [ ] 測試所有頁面

### App Store Connect
- [ ] 填寫支援 URL
- [ ] 填寫隱私政策 URL
- [ ] 測試 URL 可訪問
- [ ] 提交審查

---

## 🐛 常見問題

### Q1: Vercel 找不到文件

**A**: 確保設置了 **Root Directory** 為 `website`

### Q2: 頁面顯示 404

**A**: 檢查文件路徑，確保 `support.html` 和 `privacy.html` 在正確的位置

### Q3: GitHub 推送失敗

**A**: 
- 檢查是否有寫入權限
- 確認遠程倉庫 URL 正確
- 嘗試使用 SSH：`git remote set-url origin git@github.com:professorcathk-art/lifelab.git`

### Q4: Vercel 部署失敗

**A**: 
- 檢查 Root Directory 設置
- 確認文件結構正確
- 查看 Vercel 的部署日誌

---

## 📚 參考資源

### Vercel 文檔
- [Vercel 部署指南](https://vercel.com/docs)
- [GitHub 集成](https://vercel.com/docs/concepts/git)

### GitHub 文檔
- [Git 基礎](https://docs.github.com/en/get-started/getting-started-with-git)

---

## ✅ 完成！

完成這些步驟後，您將擁有：

1. ✅ **GitHub 倉庫**：包含網站文件
2. ✅ **Vercel 部署**：自動部署的網站
3. ✅ **支援 URL**：用於 App Store Connect
4. ✅ **隱私政策 URL**：用於 App Store Connect

**下一步**：在 App Store Connect 中填寫這些 URL，然後提交審查！

🎉
