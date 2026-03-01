#!/bin/bash
# Michael's Smart-Sync Logic

LOCAL_DIR="$HOME/Documents/University"
REMOTE_DIR="/mnt/proxmox"

# 1. Ensure mount point is active
if ! mountpoint -q "$REMOTE_DIR"; then
    echo "❌ Proxmox not mounted. Skipping sync."
    exit 1
fi

# 2. Check if local folder is empty
if [ -z "$(ls -A "$LOCAL_DIR" 2>/dev/null)" ]; then
    echo "📥 Local folder empty. Pulling from Proxmox..."
    rsync -avzu --exclude=".conda/" "$REMOTE_DIR/" "$LOCAL_DIR/"
else
    echo "📤 Local folder has files. Pushing to Proxmox..."
    rsync -avzu --exclude=".conda/" "$LOCAL_DIR/" "$REMOTE_DIR/"
fi

