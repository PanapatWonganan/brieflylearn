#!/bin/bash

# ============================================================
# BrieflyLearn Automated Backup Script
# ============================================================
# Usage: Run via cron job
# Crontab: 0 2 * * * /var/backups/brieflylearn/backup.sh
# ============================================================

set -e  # Exit on error

# Configuration
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
DATE=$(date +"%Y-%m-%d")
BACKUP_ROOT="/var/backups/brieflylearn"
PROJECT_DIR="/var/www/brieflylearn"

# Database Configuration
DB_NAME="brieflylearn_production"
DB_USER="brieflylearn_user"
DB_PASS="YOUR_SECURE_PASSWORD_HERE"  # Change this!

# Backup directories
DB_BACKUP_DIR="$BACKUP_ROOT/database"
FILES_BACKUP_DIR="$BACKUP_ROOT/files"
LOG_FILE="$BACKUP_ROOT/backup.log"

# Retention (days)
RETENTION_DAYS=7

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Function to log messages
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a $LOG_FILE
}

# Function to log errors
error() {
    echo -e "${RED}[ERROR] $1${NC}" | tee -a $LOG_FILE
}

# Function to log success
success() {
    echo -e "${GREEN}[SUCCESS] $1${NC}" | tee -a $LOG_FILE
}

# Function to log info
info() {
    echo -e "${YELLOW}[INFO] $1${NC}" | tee -a $LOG_FILE
}

# Start backup
log "=============================================="
log "Starting BrieflyLearn Backup Process"
log "=============================================="

# Create backup directories if they don't exist
mkdir -p $DB_BACKUP_DIR
mkdir -p $FILES_BACKUP_DIR

# 1. Backup Database
info "Backing up database: $DB_NAME"
if mysqldump -u $DB_USER -p$DB_PASS $DB_NAME | gzip > $DB_BACKUP_DIR/db_$TIMESTAMP.sql.gz; then
    success "Database backup completed: db_$TIMESTAMP.sql.gz"

    # Get file size
    DB_SIZE=$(du -h $DB_BACKUP_DIR/db_$TIMESTAMP.sql.gz | cut -f1)
    info "Database backup size: $DB_SIZE"
else
    error "Database backup failed!"
    exit 1
fi

# 2. Backup Storage (uploaded files)
info "Backing up storage directory..."
if tar -czf $FILES_BACKUP_DIR/storage_$TIMESTAMP.tar.gz -C $PROJECT_DIR storage/app; then
    success "Storage backup completed: storage_$TIMESTAMP.tar.gz"

    # Get file size
    STORAGE_SIZE=$(du -h $FILES_BACKUP_DIR/storage_$TIMESTAMP.tar.gz | cut -f1)
    info "Storage backup size: $STORAGE_SIZE"
else
    error "Storage backup failed!"
    exit 1
fi

# 3. Backup Environment file
info "Backing up .env file..."
if cp $PROJECT_DIR/.env $FILES_BACKUP_DIR/env_$TIMESTAMP.txt; then
    success "Environment file backed up: env_$TIMESTAMP.txt"
else
    error "Environment file backup failed!"
fi

# 4. Clean up old backups
info "Cleaning up backups older than $RETENTION_DAYS days..."

# Remove old database backups
find $DB_BACKUP_DIR -name "db_*.sql.gz" -mtime +$RETENTION_DAYS -delete
DELETED_DB=$(find $DB_BACKUP_DIR -name "db_*.sql.gz" -mtime +$RETENTION_DAYS 2>/dev/null | wc -l)
info "Deleted $DELETED_DB old database backups"

# Remove old storage backups
find $FILES_BACKUP_DIR -name "storage_*.tar.gz" -mtime +$RETENTION_DAYS -delete
DELETED_FILES=$(find $FILES_BACKUP_DIR -name "storage_*.tar.gz" -mtime +$RETENTION_DAYS 2>/dev/null | wc -l)
info "Deleted $DELETED_FILES old storage backups"

# Remove old env backups
find $FILES_BACKUP_DIR -name "env_*.txt" -mtime +$RETENTION_DAYS -delete

# 5. Create daily summary
DAILY_SUMMARY="$BACKUP_ROOT/daily_summary_$DATE.txt"
cat > $DAILY_SUMMARY << EOF
BrieflyLearn Backup Summary - $DATE
============================================

Backup Timestamp: $TIMESTAMP

Database Backup:
- File: db_$TIMESTAMP.sql.gz
- Size: $DB_SIZE

Storage Backup:
- File: storage_$TIMESTAMP.tar.gz
- Size: $STORAGE_SIZE

Retention Policy: $RETENTION_DAYS days

Total Backups:
- Database: $(ls -1 $DB_BACKUP_DIR/db_*.sql.gz 2>/dev/null | wc -l) files
- Storage: $(ls -1 $FILES_BACKUP_DIR/storage_*.tar.gz 2>/dev/null | wc -l) files

Disk Usage:
$(df -h $BACKUP_ROOT | tail -1)

============================================
EOF

success "Daily summary created: daily_summary_$DATE.txt"

# 6. Optional: Upload to Cloud Storage (S3/DigitalOcean Spaces)
# Uncomment and configure if you want to upload to cloud
# info "Uploading to cloud storage..."
# aws s3 cp $DB_BACKUP_DIR/db_$TIMESTAMP.sql.gz s3://your-bucket/backups/database/
# aws s3 cp $FILES_BACKUP_DIR/storage_$TIMESTAMP.tar.gz s3://your-bucket/backups/storage/

# 7. Optional: Send notification email
# Uncomment if you want email notifications
# echo "Backup completed successfully on $DATE" | mail -s "BrieflyLearn Backup Report" admin@brieflylearn.com

# Summary
log "=============================================="
success "Backup completed successfully!"
log "Backup location: $BACKUP_ROOT"
log "Next backup: $(date -d 'tomorrow 2:00' +'%Y-%m-%d %H:%M:%S')"
log "=============================================="

exit 0
