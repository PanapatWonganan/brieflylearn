#!/bin/bash

# BrieflyLearn - GitHub Setup Script
# This script will help you create repositories and push code to GitHub

set -e

echo "🚀 BrieflyLearn GitHub Setup"
echo "============================"
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Get GitHub username
echo -e "${BLUE}📝 Please enter your GitHub username:${NC}"
read -p "GitHub username: " GITHUB_USERNAME

if [ -z "$GITHUB_USERNAME" ]; then
    echo -e "${RED}❌ GitHub username cannot be empty${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}⚠️  IMPORTANT NOTES:${NC}"
echo "1. You need to create 2 repositories on GitHub first:"
echo "   - ${GITHUB_USERNAME}/brieflylearn-backend (Private recommended)"
echo "   - ${GITHUB_USERNAME}/brieflylearn-frontend (Private recommended)"
echo ""
echo "2. Go to https://github.com/new to create each repository"
echo "   - Repository name: brieflylearn-backend"
echo "   - Description: BrieflyLearn LMS - Laravel Backend API"
echo "   - Visibility: Private"
echo "   - DO NOT initialize with README, .gitignore, or license"
echo ""
echo "   Then create second repository:"
echo "   - Repository name: brieflylearn-frontend"
echo "   - Description: BrieflyLearn LMS - Next.js Frontend"
echo "   - Visibility: Private"
echo "   - DO NOT initialize with README, .gitignore, or license"
echo ""

read -p "Have you created both repositories? (y/n): " CREATED_REPOS

if [ "$CREATED_REPOS" != "y" ]; then
    echo -e "${YELLOW}Please create the repositories first, then run this script again.${NC}"
    exit 0
fi

echo ""
echo -e "${BLUE}🔐 You will need a GitHub Personal Access Token${NC}"
echo "If you don't have one:"
echo "1. Go to https://github.com/settings/tokens"
echo "2. Click 'Generate new token (classic)'"
echo "3. Give it a name: 'BrieflyLearn Deployment'"
echo "4. Select scopes: repo (all)"
echo "5. Generate and copy the token"
echo ""
read -p "Press Enter when you have your token ready..."

echo ""
echo -e "${GREEN}📦 Setting up Backend Repository...${NC}"

# Backend setup
cd /Users/panapat/brieflylearn/fitness-lms-admin

# Check if git is already initialized
if [ -d ".git" ]; then
    echo -e "${YELLOW}⚠️  Git already initialized in backend. Removing...${NC}"
    rm -rf .git
fi

# Initialize git
git init
echo -e "${GREEN}✅ Git initialized${NC}"

# Add all files
git add .
echo -e "${GREEN}✅ Files added${NC}"

# Create initial commit
git commit -m "Initial commit - BrieflyLearn Laravel Backend

- Laravel 11 backend with Filament Admin
- Course management system
- Garden gamification system
- User authentication and API
- MySQL database integration"

echo -e "${GREEN}✅ Initial commit created${NC}"

# Add remote
git remote add origin "https://github.com/${GITHUB_USERNAME}/brieflylearn-backend.git"
echo -e "${GREEN}✅ Remote added${NC}"

# Rename to main
git branch -M main
echo -e "${GREEN}✅ Branch renamed to main${NC}"

echo ""
echo -e "${BLUE}🔐 Pushing backend to GitHub...${NC}"
echo "Enter your GitHub username when prompted for username"
echo "Enter your Personal Access Token when prompted for password"

# Push to GitHub
git push -u origin main

echo -e "${GREEN}✅ Backend pushed successfully!${NC}"

echo ""
echo -e "${GREEN}📦 Setting up Frontend Repository...${NC}"

# Frontend setup
cd /Users/panapat/brieflylearn/fitness-lms

# Check if git is already initialized
if [ -d ".git" ]; then
    echo -e "${YELLOW}⚠️  Git already initialized in frontend. Removing...${NC}"
    rm -rf .git
fi

# Initialize git
git init
echo -e "${GREEN}✅ Git initialized${NC}"

# Add all files
git add .
echo -e "${GREEN}✅ Files added${NC}"

# Create initial commit
git commit -m "Initial commit - BrieflyLearn Next.js Frontend

- Next.js 15.4.4 with TypeScript
- Tailwind CSS styling
- Course browsing and enrollment
- Garden gamification UI
- User authentication
- Responsive design"

echo -e "${GREEN}✅ Initial commit created${NC}"

# Add remote
git remote add origin "https://github.com/${GITHUB_USERNAME}/brieflylearn-frontend.git"
echo -e "${GREEN}✅ Remote added${NC}"

# Rename to main
git branch -M main
echo -e "${GREEN}✅ Branch renamed to main${NC}"

echo ""
echo -e "${BLUE}🔐 Pushing frontend to GitHub...${NC}"

# Push to GitHub
git push -u origin main

echo -e "${GREEN}✅ Frontend pushed successfully!${NC}"

echo ""
echo -e "${GREEN}🎉 SUCCESS! Both repositories are now on GitHub${NC}"
echo ""
echo "Backend: https://github.com/${GITHUB_USERNAME}/brieflylearn-backend"
echo "Frontend: https://github.com/${GITHUB_USERNAME}/brieflylearn-frontend"
echo ""
echo -e "${BLUE}📝 Next Steps:${NC}"
echo "1. Review the repositories on GitHub"
echo "2. Follow VULTR_SINGLE_HOST_DEPLOYMENT.md for server deployment"
echo "3. Setup SSH deploy keys on the Vultr server"
echo ""
echo -e "${YELLOW}⚠️  Remember to keep your Personal Access Token secure!${NC}"
