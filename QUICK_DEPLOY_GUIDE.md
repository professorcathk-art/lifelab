# 快速部署指南 - GitHub + Vercel

## 🎯 目標

將網站文件同步到 GitHub 並部署到 Vercel，獲得支援 URL 和隱私政策 URL。

---

## 📋 Step 1: 同步到 GitHub

### 方法 A: 使用命令行（推薦）

```bash
cd /Users/mickeylau/lifelab

# 1. 檢查 Git 狀態
git status

# 2. 添加網站文件
git add website/

# 3. 提交更改
git commit -m "Add website files for support and privacy policy"

# 4. 推送到 GitHub
git push origin main
```

**如果主分支是 `master`**：
```bash
git push origin master
```

### 方法 B: 使用腳本

```bash
cd /Users/mickeylau/lifelab
./DEPLOY_WEBSITE.sh
```

然後按照腳本提示執行。

### 方法 C: 直接在 GitHub 網頁上傳

1. **訪問**：https://github.com/professorcathk-art/lifelab
2. **點擊 "Add file" → "Upload files"**
3. **拖拽整個 `website/` 文件夾**
4. **填寫提交訊息**："Add website files"
5. **點擊 "Commit changes"**

---

## 🚀 Step 2: 部署到 Vercel

### 方法 1: 通過 Vercel 網站（最簡單）

#### 2.1 登錄 Vercel

1. **訪問**：https://vercel.com
2. **點擊 "Sign Up"** 或 **"Log In"**
3. **使用 GitHub 帳號登錄**（推薦！）

#### 2.2 導入項目

1. **點擊 "Add New..." → "Project"**
2. **選擇 GitHub 倉庫**：
   - 如果沒有看到 `professorcathk-art/lifelab`，點擊 "Adjust GitHub App Permissions"
   - 確保選擇了正確的倉庫
3. **選擇倉庫**：`professorcathk-art/lifelab`
4. **點擊 "Import"**

#### 2.3 配置項目（重要！）

**Root Directory**：
- 點擊 "Root Directory" 旁邊的 "Edit"
- 輸入：`website`
- 點擊 "Continue"

**Framework Preset**：
- 選擇 **"Other"**

**Build Command**：
- 留空（靜態網站不需要構建）

**Output Directory**：
- 留空

**Install Command**：
- 留空

#### 2.4 部署

1. **點擊 "Deploy"**
2. **等待部署完成**（通常 1-2 分鐘）
3. **獲得 URL**：
   - 例如：`https://lifelab-xxx.vercel.app`
   - 或自定義域名（如果設置了）

---

### 方法 2: 使用 Vercel CLI

#### 2.1 安裝 Vercel CLI

```bash
npm install -g vercel
```

#### 2.2 登錄

```bash
vercel login
```

#### 2.3 部署

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

#### 2.4 生產環境部署

```bash
vercel --prod
```

---

## 📝 Step 3: 獲取 URL

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

## ✅ Step 4: 在 App Store Connect 中使用

### 4.1 填寫 URL

在 App Store Connect 中：

**支援 URL**：
```
https://lifelab-xxx.vercel.app/support.html
```

**隱私政策 URL**：
```
https://lifelab-xxx.vercel.app/privacy.html
```

### 4.2 測試 URL

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
   git push origin main
   ```
3. **Vercel 自動部署**：
   - Vercel 會自動檢測 GitHub 的更改
   - 自動觸發新的部署
   - 通常 1-2 分鐘內完成

---

## ⚠️ 重要提示

### Root Directory 設置

**必須設置為 `website`**！

如果沒有設置：
- Vercel 會在項目根目錄尋找文件
- 找不到 `support.html` 和 `privacy.html`
- 會顯示 404 錯誤

**如何設置**：
1. 在 Vercel Dashboard
2. **Settings** → **General** → **Root Directory**
3. 設置為：`website`
4. 保存並重新部署

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
- [ ] 確認遠程倉庫：`https://github.com/professorcathk-art/lifelab`
- [ ] 添加 `website/` 文件夾
- [ ] 提交更改
- [ ] 推送到 GitHub
- [ ] 確認文件在 GitHub 上可見

### Vercel 部署
- [ ] 登錄 Vercel
- [ ] 導入 GitHub 倉庫：`professorcathk-art/lifelab`
- [ ] **設置 Root Directory 為 `website`**（重要！）
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

**解決方法**：
1. Settings → General → Root Directory
2. 設置為：`website`
3. 保存並重新部署

### Q2: 頁面顯示 404

**A**: 檢查文件路徑和 Root Directory 設置

**解決方法**：
- 確認 `support.html` 和 `privacy.html` 在 `website/` 文件夾中
- 確認 Root Directory 設置為 `website`
- 確認文件已推送到 GitHub

### Q3: GitHub 推送失敗

**A**: 檢查權限和遠程倉庫設置

**解決方法**：
```bash
# 檢查遠程倉庫
git remote -v

# 如果 URL 不對，更新它
git remote set-url origin https://github.com/professorcathk-art/lifelab.git

# 重新推送
git push origin main
```

### Q4: Vercel 部署失敗

**A**: 檢查 Root Directory 和文件結構

**解決方法**：
- 確認 Root Directory 設置為 `website`
- 確認文件結構正確
- 查看 Vercel 的部署日誌

---

## 📚 參考資源

### Vercel 文檔
- [Vercel 部署指南](https://vercel.com/docs)
- [GitHub 集成](https://vercel.com/docs/concepts/git)
- [Root Directory 設置](https://vercel.com/docs/projects/configuration#root-directory)

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
