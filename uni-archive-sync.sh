#!/bin/bash
SOURCE="$HOME/Documents/University"
DEST="/mnt/Synology_Home/Documents/University"
ARCHIVE_ROOT="/mnt/Synology_Home/Documents/University_Archive"
TIMESTAMP=$(date +%Y-%m-%d_%H-%M)

# 1. Run iterative sync (moves changed/deleted files to timestamped archive)
rclone sync "$SOURCE" "$DEST" \
    --backup-dir "$ARCHIVE_ROOT/$TIMESTAMP" \
    --exclude ".conda/**" \
    --ignore-errors

# 2. Keep only last 5 versions
# Sort by time and remove older than the newest 5
cd "$ARCHIVE_ROOT" || exit
ls -1dt ./*/ | tail -n +6 | xargs rm -rf 2>/dev/null
