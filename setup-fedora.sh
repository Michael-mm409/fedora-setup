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
code --install-extension ms-python.python
code --install-extension ms-toolsai.jupyter

# 3. Official Social Apps & Discord
echo "💬 Configuring Discord & Social..."
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak uninstall dev.vencord.Vesktop -y 2>/dev/null
flatpak install flathub com.discordapp.Discord -y
mkdir -p "$HOME/.config/discord"
echo '{"SKIP_HOST_UPDATE": true}' > "$HOME/.config/discord/settings.json"

# 4. Native Zoom Block
echo "📹 Transitioning to Native Zoom..."
flatpak uninstall us.zoom.Zoom -y 2>/dev/null
sudo curl --location https://repo.zoom.us/repo/rpm/zoom_release.repo --output /etc/yum.repos.d/zoom_release.repo
sudo dnf install -y zoom

# 5. University Sync & Terminal Logic
echo "🔗 Finalizing Aliases and Terminal Logic..."
# Update these in your script's ALIASES block
ALIASES=(
    "alias uni-pull='rsync -avzu --exclude=\".conda/\" /mnt/proxmox/ ~/Documents/University/'"
    "alias uni-push='rsync -avzu --exclude=\".conda/\" ~/Documents/University/ /mnt/Synology_Home/Documents/University/'"
    "alias nas-sync='rsync -avzu ~/Documents/Synology_Home/ /mnt/Synology_Home/'"
    "alias sys-sync='cd ~/fedora-setup && git pull && chmod +x setup-fedora.sh && ./setup-fedora.sh'"
)

for line in "${ALIASES[@]}"; do
    grep -qF "$line" "$HOME/.bashrc" || echo "$line" >> "$HOME/.bashrc"
done

# 6. Terminal Polish (Direnv & Prompt)
sudo dnf install -y direnv
if ! grep -q "PROMPT_COMMAND=set_bash_prompt" "$HOME/.bashrc"; then
cat << 'EOF' >> "$HOME/.bashrc"

eval "$(direnv hook bash)"
parse_git_branch() { git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'; }
set_bash_prompt() {
    local CY='\[\033[01;33m\]' CG='\[\033[01;32m\]' CB='\[\033[01;34m\]' CP='\[\033[01;35m\]' CR='\[\033[00m\]'
    PS1="${CY}\${CONDA_DEFAULT_ENV:+(\$CONDA_DEFAULT_ENV) }${CR}${CG}\u@\h${CR}:${CB}\w${CR}${CP}\$(parse_git_branch)${CR}\$ "
}
PROMPT_COMMAND=set_bash_prompt
EOF
fi

# 7. KDE UI Components (Updated for Fedora 43)
echo "🎨 Ensuring KDE Plasma components are present..."
sudo dnf install -y kde-plasma-addons kde-connect

# 8. Chassis-Aware Automation
if [[ "$CHASSIS" == "desktop" ]]; then
    echo "🖥  Desktop Detected: Setting up High-Performance Sync..."
    (crontab -l 2>/dev/null | grep -v "uni-sync.sh"; echo "*/30 * * * * $HOME/fedora-setup/uni-sync.sh") | crontab -
elif [[ "$CHASSIS" == "laptop" ]]; then
    echo "💻 Laptop Detected: Setting up Battery-Safe Sync..."
    SAFE_CRON="[ \$(cat /sys/class/power_supply/AC/online 2>/dev/null || echo 0) -eq 1 ] && $HOME/fedora-setup/uni-sync.sh"
    (crontab -l 2>/dev/null | grep -v "uni-sync.sh"; echo "0 * * * * $SAFE_CRON") | crontab -
fi

# 9. Dual-NAS & Local Sync Setup
echo "🔗 Setting up Dual Synology Mounts..."
sudo mkdir -p /mnt/Synology_Homes /mnt/Synology_Home
mkdir -p ~/Documents/Synology_Home

# setup-fedora.sh - Corrected Dual-Mount Logic
HOMES_ENTRY="100.90.5.80:/volume1/homes /mnt/Synology_Homes nfs nfsvers=3,nolock,tcp,defaults,_netdev,nofail 0 0"
BIND_ENTRY="/mnt/Synology_Homes/Michael /mnt/Synology_Home none defaults,bind 0 0"

# Use sed to remove ALL previous Synology entries before appending new ones
sudo sed -i '/Synology_Home/d' /etc/fstab
sudo sed -i '/Synology_Homes/d' /etc/fstab

echo "$HOMES_ENTRY" | sudo tee -a /etc/fstab
echo "$BIND_ENTRY" | sudo tee -a /etc/fstab

sudo umount -l /mnt/Synology_Homes /mnt/Synology_Home 2>/dev/null
sudo mount -a
echo "✅ Setup Complete! Please restart your terminal."
