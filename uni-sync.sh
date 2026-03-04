#!/bin/bash
LOCAL_DIR="$HOME/Documents/University"
REMOTE_DIR="/mnt/proxmox_uni"

# 1. Ensure mount point is active (this triggers the automount)
if ! ls "$REMOTE_DIR" &>/dev/null; then
    echo "❌ Proxmox University not reachable. Skipping sync."
    exit 1
fi

# 2. Two-way sync logic (Pulls first, then pushes)
rsync -avzu --no-perms --no-owner --no-group --exclude=".conda/" "$REMOTE_DIR/" "$LOCAL_DIR/"
rsync -avzu --no-perms --no-owner --no-group --exclude=".conda/" "$LOCAL_DIR/" "$REMOTE_DIR/"
