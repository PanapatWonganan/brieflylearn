#!/bin/bash

# Database Setup Script for BrieflyLearn
# This script helps fix database import issues

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}🗄️  BrieflyLearn Database Setup${NC}"
echo ""

# Check if .env.local exists
if [ ! -f ".env.local" ]; then
    echo -e "${RED}❌ .env.local not found!${NC}"
    exit 1
fi

# Load environment variables
export $(cat .env.local | grep -v '^#' | xargs)

echo -e "${YELLOW}Select an option:${NC}"
echo "1. Push Prisma schema to database (recommended for fresh setup)"
echo "2. Generate Prisma Client only"
echo "3. Reset database and push schema (⚠️  WARNING: Deletes all data)"
echo "4. Create migration"
echo "5. Run pending migrations"
echo ""
read -p "Enter option (1-5): " option

case $option in
    1)
        echo -e "${YELLOW}📤 Pushing Prisma schema to database...${NC}"
        npx prisma db push
        echo -e "${GREEN}✅ Schema pushed successfully!${NC}"

        echo -e "${YELLOW}📦 Generating Prisma Client...${NC}"
        npx prisma generate
        echo -e "${GREEN}✅ Prisma Client generated!${NC}"

        echo -e "${YELLOW}🌱 Seeding database (if seed script exists)...${NC}"
        npm run seed 2>/dev/null || echo "No seed script found, skipping..."
        ;;

    2)
        echo -e "${YELLOW}📦 Generating Prisma Client...${NC}"
        npx prisma generate
        echo -e "${GREEN}✅ Prisma Client generated!${NC}"
        ;;

    3)
        echo -e "${RED}⚠️  WARNING: This will delete ALL data in your database!${NC}"
        read -p "Are you sure? Type 'yes' to confirm: " confirm
        if [ "$confirm" = "yes" ]; then
            echo -e "${YELLOW}🗑️  Resetting database...${NC}"
            npx prisma db push --force-reset
            echo -e "${GREEN}✅ Database reset complete!${NC}"

            echo -e "${YELLOW}🌱 Seeding database...${NC}"
            npm run seed 2>/dev/null || echo "No seed script found"
        else
            echo "Operation cancelled"
        fi
        ;;

    4)
        read -p "Enter migration name: " migration_name
        echo -e "${YELLOW}📝 Creating migration: $migration_name${NC}"
        npx prisma migrate dev --name "$migration_name"
        echo -e "${GREEN}✅ Migration created!${NC}"
        ;;

    5)
        echo -e "${YELLOW}🔄 Running pending migrations...${NC}"
        npx prisma migrate deploy
        echo -e "${GREEN}✅ Migrations complete!${NC}"
        ;;

    *)
        echo -e "${RED}❌ Invalid option${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}✅ Database setup complete!${NC}"
echo ""
echo -e "${YELLOW}📊 Next steps:${NC}"
echo "  1. Check Prisma Studio: npx prisma studio"
echo "  2. Rebuild application: npm run build"
echo "  3. Restart PM2: pm2 restart brieflylearn"
