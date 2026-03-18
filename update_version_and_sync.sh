#!/bin/bash

# LifeLab 版本更新和同步腳本
# 用途：更新版本號/構建號，並同步到 GitHub

set -e  # 遇到錯誤立即退出

cd /Users/mickeylau/lifelab

echo "🚀 LifeLab 版本更新和同步腳本"
echo "=================================="
echo ""

# 當前版本信息
CURRENT_VERSION="1.3.2"
CURRENT_BUILD="5"
NEW_VERSION="1.3.3"
NEW_BUILD="6"

echo "📊 當前版本信息："
echo "   版本號：$CURRENT_VERSION"
echo "   構建號：$CURRENT_BUILD"
echo ""
echo "📝 將更新為："
echo "   版本號：$NEW_VERSION"
echo "   構建號：$NEW_BUILD"
echo ""

# 確認
read -p "是否繼續？(y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ 已取消"
    exit 1
fi

echo ""
echo "📝 步驟 1: 備份 project.pbxproj..."
cp LifeLab/LifeLab.xcodeproj/project.pbxproj LifeLab/LifeLab.xcodeproj/project.pbxproj.backup
echo "   ✅ 備份完成"

echo ""
echo "📝 步驟 2: 更新版本號 ($CURRENT_VERSION → $NEW_VERSION)..."
sed -i '' "s/MARKETING_VERSION = $CURRENT_VERSION;/MARKETING_VERSION = $NEW_VERSION;/g" LifeLab/LifeLab.xcodeproj/project.pbxproj
echo "   ✅ 版本號已更新"

echo ""
echo "📝 步驟 3: 更新構建號 ($CURRENT_BUILD → $NEW_BUILD)..."
sed -i '' "s/CURRENT_PROJECT_VERSION = $CURRENT_BUILD;/CURRENT_PROJECT_VERSION = $NEW_BUILD;/g" LifeLab/LifeLab.xcodeproj/project.pbxproj
echo "   ✅ 構建號已更新"

echo ""
echo "📝 步驟 4: 驗證更改..."
VERSION_COUNT=$(grep -c "MARKETING_VERSION = $NEW_VERSION;" LifeLab/LifeLab.xcodeproj/project.pbxproj || echo "0")
BUILD_COUNT=$(grep -c "CURRENT_PROJECT_VERSION = $NEW_BUILD;" LifeLab/LifeLab.xcodeproj/project.pbxproj || echo "0")

if [ "$VERSION_COUNT" -ge "2" ] && [ "$BUILD_COUNT" -ge "2" ]; then
    echo "   ✅ 驗證通過（找到 $VERSION_COUNT 個版本號，$BUILD_COUNT 個構建號）"
else
    echo "   ⚠️  警告：可能未完全更新，請手動檢查"
fi

echo ""
echo "📝 步驟 5: 檢查 Git 狀態..."
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "   ⚠️  不是 Git 倉庫，跳過 Git 操作"
    echo ""
    echo "✅ 版本更新完成！"
    echo "   請在 Xcode 中打開項目驗證版本號"
    exit 0
fi

echo ""
read -p "是否同步到 GitHub？(y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "✅ 版本更新完成！"
    echo "   Git 同步已跳過"
    exit 0
fi

echo ""
echo "📝 步驟 6: 添加更改到 Git..."
git add LifeLab/LifeLab.xcodeproj/project.pbxproj
git add *.md 2>/dev/null || true
echo "   ✅ 文件已添加到暫存區"

echo ""
echo "📝 步驟 7: 提交更改..."
git commit -m "chore: Update version to $NEW_VERSION (Build $NEW_BUILD)

- Update MARKETING_VERSION to $NEW_VERSION
- Update CURRENT_PROJECT_VERSION to $NEW_BUILD
- Prepare for App Store release" || {
    echo "   ⚠️  提交失敗（可能沒有更改或已提交）"
}

echo ""
echo "📝 步驟 8: 拉取最新更改..."
git pull origin main --rebase || {
    echo "   ⚠️  拉取失敗，繼續推送..."
}

echo ""
echo "📝 步驟 9: 推送到 GitHub..."
git push origin main || {
    echo "   ❌ 推送失敗，請手動處理"
    exit 1
}

echo ""
echo "📝 步驟 10: 創建版本標籤..."
git tag -a "v$NEW_VERSION" -m "Release $NEW_VERSION (Build $NEW_BUILD)

- Supabase SDK Migration
- Local-first data strategy
- Improved authentication and sync" 2>/dev/null || {
    echo "   ⚠️  標籤可能已存在，跳過"
}

git push origin "v$NEW_VERSION" 2>/dev/null || {
    echo "   ⚠️  標籤推送失敗（可能已存在）"
}

echo ""
echo "=================================="
echo "✅ 完成！"
echo ""
echo "📊 更新摘要："
echo "   版本號：$CURRENT_VERSION → $NEW_VERSION"
echo "   構建號：$CURRENT_BUILD → $NEW_BUILD"
echo "   Git 同步：✅ 完成"
echo ""
echo "📋 下一步："
echo "   1. 在 Xcode 中打開項目驗證版本號"
echo "   2. 創建 Archive（Product → Archive）"
echo "   3. 上傳到 App Store Connect"
echo "   4. 配置 App Store Connect 並提交審核"
echo ""
echo "📚 詳細指南請查看："
echo "   - APP_STORE_RELEASE_GUIDE.md"
echo "   - GITHUB_SYNC_GUIDE.md"
echo ""
