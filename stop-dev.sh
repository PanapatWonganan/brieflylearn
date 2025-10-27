#!/bin/bash

# 🛑 BrieflyLearn Development Server Stopper

echo "🛑 Stopping BrieflyLearn Development Environment..."

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Function to kill process on port
kill_port() {
    local port=$1
    local name=$2
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 ; then
        echo -e "${YELLOW}Stopping $name on port $port...${NC}"
        kill -9 $(lsof -ti:$port) 2>/dev/null
        echo -e "${GREEN}✅ $name stopped${NC}"
    else
        echo -e "${YELLOW}⚠️  $name is not running on port $port${NC}"
    fi
}

# Kill by PID files if they exist
if [ -f ".backend.pid" ]; then
    BACKEND_PID=$(cat .backend.pid)
    if kill -0 $BACKEND_PID 2>/dev/null; then
        echo -e "${YELLOW}Stopping backend (PID: $BACKEND_PID)...${NC}"
        kill -9 $BACKEND_PID 2>/dev/null
        echo -e "${GREEN}✅ Backend stopped${NC}"
    fi
    rm .backend.pid
fi

if [ -f ".frontend.pid" ]; then
    FRONTEND_PID=$(cat .frontend.pid)
    if kill -0 $FRONTEND_PID 2>/dev/null; then
        echo -e "${YELLOW}Stopping frontend (PID: $FRONTEND_PID)...${NC}"
        kill -9 $FRONTEND_PID 2>/dev/null
        echo -e "${GREEN}✅ Frontend stopped${NC}"
    fi
    rm .frontend.pid
fi

# Kill by port as fallback
kill_port 8001 "Backend"
kill_port 3000 "Frontend"

echo ""
echo -e "${GREEN}🎉 All servers stopped!${NC}"
