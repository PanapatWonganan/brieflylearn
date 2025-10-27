#!/bin/bash

# แทน YOUR_USERNAME ด้วย GitHub username ของคุณ
GITHUB_USERNAME="YOUR_USERNAME"
REPO_NAME="boostme-backend"

echo "🚀 Pushing to GitHub..."
git remote add origin https://github.com/$GITHUB_USERNAME/$REPO_NAME.git
git branch -M main  
git push -u origin main

echo "✅ Done! Code pushed to GitHub"
echo "📌 Repository URL: https://github.com/$GITHUB_USERNAME/$REPO_NAME"