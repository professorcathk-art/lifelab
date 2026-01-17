#!/bin/bash

# LifeLab - TestFlight Setup Script
# This helps you build and prepare your app for TestFlight distribution

set -e

PROJECT_PATH="LifeLab/LifeLab.xcodeproj"
SCHEME="LifeLab"
ARCHIVE_PATH="./build/LifeLab.xcarchive"
EXPORT_PATH="./build/export"

echo "🚀 LifeLab - TestFlight Setup"
echo "=============================="
echo ""

# Check if Apple Developer account is configured
check_developer_account() {
    echo "🔍 Checking Apple Developer account..."
    if security find-identity -v -p codesigning | grep -q "Apple Development"; then
        echo "✅ Developer account found"
        return 0
    else
        echo "❌ No Apple Developer account found"
        echo ""
        echo "To set up:"
        echo "1. Open Xcode"
        echo "2. Xcode > Settings > Accounts"
        echo "3. Add your Apple ID"
        echo "4. Select your team"
        return 1
    fi
}

# Build archive
build_archive() {
    echo "📦 Building archive..."
    
    # Clean first
    xcodebuild clean \
        -project "$PROJECT_PATH" \
        -scheme "$SCHEME"
    
    # Build archive
    xcodebuild archive \
        -project "$PROJECT_PATH" \
        -scheme "$SCHEME" \
        -configuration Release \
        -archivePath "$ARCHIVE_PATH" \
        -allowProvisioningUpdates
    
    if [ $? -eq 0 ]; then
        echo "✅ Archive created at: $ARCHIVE_PATH"
    else
        echo "❌ Archive build failed"
        exit 1
    fi
}

# Export IPA
export_ipa() {
    echo "📤 Exporting IPA..."
    
    # Create export options plist
    cat > "$EXPORT_PATH/ExportOptions.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>YOUR_TEAM_ID</string>
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
    <key>compileBitcode</key>
    <false/>
</dict>
</plist>
EOF
    
    echo "⚠️  Note: You need to:"
    echo "1. Update YOUR_TEAM_ID in ExportOptions.plist"
    echo "2. Or use Xcode GUI: Window > Organizer > Distribute App"
    echo ""
    echo "Archive location: $ARCHIVE_PATH"
}

# Main menu
case "${1:-help}" in
    check)
        check_developer_account
        ;;
    archive)
        check_developer_account || exit 1
        build_archive
        ;;
    export)
        export_ipa
        ;;
    all)
        check_developer_account || exit 1
        build_archive
        echo ""
        echo "📝 Next steps:"
        echo "1. Open Xcode"
        echo "2. Window > Organizer"
        echo "3. Select your archive"
        echo "4. Click 'Distribute App'"
        echo "5. Choose 'App Store Connect'"
        echo "6. Follow the wizard"
        ;;
    help|*)
        echo "Usage: $0 [command]"
        echo ""
        echo "Commands:"
        echo "  check   - Check if Apple Developer account is configured"
        echo "  archive - Build archive for TestFlight"
        echo "  export  - Export IPA (requires manual setup)"
        echo "  all     - Build archive and show next steps"
        echo ""
        echo "Example:"
        echo "  $0 archive    # Build archive"
        echo "  $0 all        # Full workflow"
        ;;
esac
