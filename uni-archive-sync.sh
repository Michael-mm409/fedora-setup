#!/bin/bash
# uni-archive-sync.sh - Iterative rclone backup with rotation

SOURCE="$HOME/Documents/University"
DEST="/mnt/Synology_Home/Documents/University"
ARCHIVE_ROOT="/mnt/Synology_Home/Documents/University_Archive"
TIMESTAMP=$(date +%Y-%m-%d_%H-%M)

# 1. Run iterative sync
rclone sync "$SOURCE" "$DEST" \
    --backup-dir "$ARCHIVE_ROOT/$TIMESTAMP" \
    --progress

# 2. Keep only last 5 versions
ls -1dt "$ARCHIVE_ROOT"/*/ | tail -n +6 | xargs rm -rf 2>/dev/null
