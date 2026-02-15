#!/bin/bash

# LifeLab Website Deployment Script
# This script helps sync website files to GitHub and prepare for Vercel deployment

set -e

echo "=== LifeLab Website Deployment ==="
echo ""

# Check if we're in the right directory
if [ ! -d "website" ]; then
    echo "❌ Error: website/ folder not found!"
    exit 1
fi

# Check git remote
echo "📋 Checking Git remote..."
REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "")
if [ -z "$REMOTE_URL" ]; then
    echo "⚠️  No git remote found. Adding remote..."
    git remote add origin https://github.com/professorcathk-art/lifelab.git
    echo "✅ Added remote: https://github.com/professorcathk-art/lifelab.git"
else
    echo "✅ Git remote: $REMOTE_URL"
    
    # Verify it's the correct repository
    if [[ "$REMOTE_URL" != *"professorcathk-art/lifelab"* ]]; then
        echo "⚠️  Warning: Remote URL doesn't match expected repository!"
        echo "   Expected: https://github.com/professorcathk-art/lifelab.git"
        echo "   Current: $REMOTE_URL"
        read -p "Do you want to update it? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git remote set-url origin https://github.com/professorcathk-art/lifelab.git
            echo "✅ Updated remote URL"
        fi
    fi
fi

echo ""
echo "📁 Website files:"
ls -la website/

echo ""
echo "📝 Next steps:"
echo ""
echo "1. Add website files to git:"
echo "   git add website/"
echo ""
echo "2. Commit:"
echo "   git commit -m 'Add website files for support and privacy policy'"
echo ""
echo "3. Push to GitHub:"
echo "   git push origin main"
echo ""
echo "4. Deploy to Vercel:"
echo "   - Go to https://vercel.com"
echo "   - Import project from GitHub"
echo "   - Select repository: professorcathk-art/lifelab"
echo "   - Set Root Directory to: website"
echo "   - Deploy!"
echo ""
echo "✅ Script completed!"
