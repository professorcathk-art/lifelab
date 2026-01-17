#!/bin/bash

echo "🔍 驗證 Lifelab 專案結構..."
echo ""

# 檢查必要的資料夾
folders=("Models" "ViewModels" "Views" "Services" "Utilities")
for folder in "${folders[@]}"; do
    if [ -d "$folder" ]; then
        echo "✅ $folder/ 存在"
    else
        echo "❌ $folder/ 不存在"
    fi
done

echo ""
echo "📁 檢查關鍵文件..."

# 檢查關鍵文件
files=("LifeLabApp.swift" "Models/UserProfile.swift" "ViewModels/InitialScanViewModel.swift" "Views/ContentView.swift")
for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file 存在"
    else
        echo "❌ $file 不存在"
    fi
done

echo ""
echo "📊 Swift 文件統計:"
swift_count=$(find . -name "*.swift" -type f | wc -l | xargs)
echo "   找到 $swift_count 個 Swift 文件"

echo ""
echo "✨ 專案結構驗證完成！"
echo ""
echo "📝 下一步："
echo "   1. 打開 Xcode"
echo "   2. 創建新的 iOS App 專案（SwiftUI）"
echo "   3. 將所有文件添加到專案中"
echo "   4. 詳見 SETUP.md 文件"
