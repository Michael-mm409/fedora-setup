#!/bin/bash
# setup-fedora.sh - Universal Master Script (Michael's Final)

CHASSIS=$(hostnamectl chassis)
echo "🚀 Starting Michael's Fedora Setup on a $CHASSIS..."

# 1. Universal Essentials & Hardware
sudo dnf update -y
sudo dnf install -y nfs-utils rclone psmisc curl git wget --allowerasing

# Trigger Hardware-Specific Scripts (NVIDIA, etc.)
if [[ "$CHASSIS" == "desktop" && -f "./hosts/desktop.sh" ]]; then
    chmod +x ./hosts/desktop.sh && ./hosts/desktop.sh
elif [[ "$CHASSIS" == "laptop" && -f "./hosts/laptop.sh" ]]; then
    chmod +x ./hosts/laptop.sh && ./hosts/laptop.sh
fi

# 2. Stable Native VS Code (RPM)
echo "💻 Installing Visual Studio Code (Native RPM)..."
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
sudo dnf install -y code

# Optional: Pre-install common University extensions
code --install-extension ms-python.python
code --install-extension ms-toolsai.jupyter

# 3. Official Social Apps & Discord
echo "💬 Configuring Discord & Social..."
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak uninstall dev.vencord.Vesktop -y 2>/dev/null
flatpak install flathub com.discordapp.Discord -y

# Apply Discord Update-Fix
mkdir -p "$HOME/.config/discord"
echo '{"SKIP_HOST_UPDATE": true}' > "$HOME/.config/discord/settings.json"

# 4. Native Zoom Block
echo "📹 Transitioning to Native Zoom..."
flatpak uninstall us.zoom.Zoom -y 2>/dev/null
rm -f "$HOME/.local/share/applications/us.zoom.Zoom.desktop"
sudo curl --location https://repo.zoom.us/repo/rpm/zoom_release.repo --output /etc/yum.repos.d/zoom_release.repo
sudo rpmkeys --import "https://zoom.us/linux/download/pubkey?version=6-3-10"
sudo dnf install -y zoom

# 5. University Sync Aliases
echo "🔗 Finalizing Sync Aliases..."
ALIASES=(
    "alias uni-pull='rsync -avzu --exclude=\".conda/\" /mnt/proxmox/ \$HOME/Documents/University/'"
    "alias uni-push='rsync -avzu --exclude=\".conda/\" \$HOME/Documents/University/ /mnt/proxmox/'"
    "alias nas-sync='rsync -avzu \$HOME/Documents/University/ /mnt/nas/'"
    "alias zoom='zoom'"
    # Add this to the Aliases section of setup-fedora.
    "alias sync-now='$HOME/fedora-setup/uni-sync.sh'"
)
for line in "${ALIASES[@]}"; do
    grep -qF "$line" "$HOME/.bashrc" || echo "$line" >> "$HOME/.bashrc"
done

# 6. UI Cleanup
echo "🧹 Refreshing Application Database..."
update-desktop-database "$HOME/.local/share/applications"
sudo update-desktop-database /usr/share/applications

# 7. Chassis-Aware Automation
CHASSIS=$(hostnamectl chassis)

if [[ "$CHASSIS" == "desktop" ]]; then
    echo "🖥️  Desktop Detected: Setting up High-Performance Sync..."
    # Desktop: Sync every 30 mins, no battery checks needed
    (crontab -l 2>/dev/null | grep -v "uni-sync.sh"; \
     echo "*/30 * * * * $HOME/fedora-setup/uni-sync.sh") | crontab -

elif [[ "$CHASSIS" == "laptop" ]]; then
    echo "💻 Laptop Detected: Setting up Battery-Safe Sync..."
    # Laptop: Only sync if plugged into AC power (saves battery in lectures)
    SAFE_CRON="[ \$(cat /sys/class/power_supply/AC/online 2>/dev/null || echo 0) -eq 1 ] && $HOME/fedora-setup/uni-sync.sh"
    (crontab -l 2>/dev/null | grep -v "uni-sync.sh"; \
     echo "0 * * * * $SAFE_CRON") | crontab -
fi
