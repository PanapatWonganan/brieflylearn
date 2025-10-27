#!/bin/bash

# 🚀 BrieflyLearn Development Server Starter
# This script starts both backend and frontend servers

echo "🚀 Starting BrieflyLearn Development Environment..."
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if running from correct directory
if [ ! -d "fitness-lms" ] || [ ! -d "fitness-lms-admin" ]; then
    echo -e "${RED}❌ Error: Please run this script from /Users/panapat/brieflylearn/${NC}"
    echo -e "${YELLOW}Current directory: $(pwd)${NC}"
    exit 1
fi

# Function to check if port is in use
check_port() {
    local port=$1
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 ; then
        return 0  # Port is in use
    else
        return 1  # Port is free
    fi
}

# Function to kill process on port
kill_port() {
    local port=$1
    echo -e "${YELLOW}⚠️  Port $port is already in use. Killing existing process...${NC}"
    kill -9 $(lsof -ti:$port) 2>/dev/null
    sleep 1
}

echo -e "${BLUE}📋 Checking prerequisites...${NC}"

# Check MySQL
if ! command -v mysql &> /dev/null; then
    echo -e "${RED}❌ MySQL is not installed. Please install MySQL first.${NC}"
    echo -e "${YELLOW}Install with: brew install mysql${NC}"
    exit 1
else
    echo -e "${GREEN}✅ MySQL found${NC}"
fi

# Check PHP
if ! command -v php &> /dev/null; then
    echo -e "${RED}❌ PHP is not installed. Please install PHP 8.2+${NC}"
    echo -e "${YELLOW}Install with: brew install php@8.2${NC}"
    exit 1
else
    PHP_VERSION=$(php -v | head -n 1 | cut -d " " -f 2 | cut -d "." -f 1,2)
    echo -e "${GREEN}✅ PHP $PHP_VERSION found${NC}"
fi

# Check Node.js
if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js is not installed. Please install Node.js 18+${NC}"
    echo -e "${YELLOW}Install with: brew install node@20${NC}"
    exit 1
else
    NODE_VERSION=$(node -v)
    echo -e "${GREEN}✅ Node.js $NODE_VERSION found${NC}"
fi

echo ""
echo -e "${BLUE}🔧 Setting up environment...${NC}"

# Check and kill if ports are in use
if check_port 8001; then
    kill_port 8001
fi

if check_port 3000; then
    kill_port 3000
fi

# Start MySQL if not running
if ! brew services list | grep mysql | grep started > /dev/null; then
    echo -e "${YELLOW}🔄 Starting MySQL service...${NC}"
    brew services start mysql
    sleep 2
fi

echo ""
echo -e "${BLUE}🎯 Starting Backend (Laravel)...${NC}"

# Start backend in background
cd fitness-lms-admin

# Check if vendor directory exists
if [ ! -d "vendor" ]; then
    echo -e "${YELLOW}📦 Installing backend dependencies...${NC}"
    composer install
fi

# Start Laravel server
php artisan serve --host=0.0.0.0 --port=8001 > ../backend.log 2>&1 &
BACKEND_PID=$!

sleep 3

# Check if backend started successfully
if check_port 8001; then
    echo -e "${GREEN}✅ Backend started on http://localhost:8001${NC}"
    echo -e "${GREEN}   Admin Panel: http://localhost:8001/admin${NC}"
    echo -e "${GREEN}   API: http://localhost:8001/api/v1${NC}"
else
    echo -e "${RED}❌ Failed to start backend. Check backend.log for errors.${NC}"
    exit 1
fi

cd ..

echo ""
echo -e "${BLUE}⚡ Starting Frontend (Next.js)...${NC}"

# Start frontend in background
cd fitness-lms

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    echo -e "${YELLOW}📦 Installing frontend dependencies...${NC}"
    npm install
fi

# Start Next.js server
npm run dev > ../frontend.log 2>&1 &
FRONTEND_PID=$!

sleep 5

# Check if frontend started successfully
if check_port 3000; then
    echo -e "${GREEN}✅ Frontend started on http://localhost:3000${NC}"
else
    echo -e "${RED}❌ Failed to start frontend. Check frontend.log for errors.${NC}"
    # Kill backend if frontend failed
    kill $BACKEND_PID 2>/dev/null
    exit 1
fi

cd ..

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🎉 BrieflyLearn is running!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}📱 Access URLs:${NC}"
echo -e "   Frontend:    ${GREEN}http://localhost:3000${NC}"
echo -e "   Backend API: ${GREEN}http://localhost:8001/api/v1${NC}"
echo -e "   Admin Panel: ${GREEN}http://localhost:8001/admin${NC}"
echo ""
echo -e "${BLUE}📋 Process IDs:${NC}"
echo -e "   Backend PID:  ${YELLOW}$BACKEND_PID${NC}"
echo -e "   Frontend PID: ${YELLOW}$FRONTEND_PID${NC}"
echo ""
echo -e "${BLUE}📝 Logs:${NC}"
echo -e "   Backend:  ${YELLOW}tail -f backend.log${NC}"
echo -e "   Frontend: ${YELLOW}tail -f frontend.log${NC}"
echo ""
echo -e "${RED}⏹  To stop servers:${NC}"
echo -e "   ${YELLOW}./stop-dev.sh${NC}"
echo -e "   or press ${YELLOW}Ctrl+C${NC} (will stop this script only)"
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Save PIDs to file for stop script
echo "$BACKEND_PID" > .backend.pid
echo "$FRONTEND_PID" > .frontend.pid

# Keep script running
echo -e "${YELLOW}Press Ctrl+C to stop monitoring (servers will keep running)${NC}"
echo ""

# Monitor processes
while true; do
    if ! kill -0 $BACKEND_PID 2>/dev/null; then
        echo -e "${RED}❌ Backend stopped unexpectedly. Check backend.log${NC}"
        break
    fi
    if ! kill -0 $FRONTEND_PID 2>/dev/null; then
        echo -e "${RED}❌ Frontend stopped unexpectedly. Check frontend.log${NC}"
        break
    fi
    sleep 5
done
