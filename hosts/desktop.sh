#!/bin/bash
# hosts/desktop.sh - Michael's Desktop-Specific Logic

echo "⚙️  Configuring Desktop Hardware & Storage..."

# 1. NVIDIA Blackwell (50-series) Drivers
# Replaces nvidia.nix logic
sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
                    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda openrgb

# Force driver build for the 5070-Ti
sudo akmods --force
sudo systemctl enable nvidia-hibernate.service nvidia-resume.service nvidia-suspend.service

# 2. Tailscale NFS Mounts
# Replaces network-storage.nix using Tailscale IPs
TS_NAS_IP="100.90.5.80"
TS_PROXMOX_IP="100.70.100.118"

if ! grep -q "/mnt/nas" /etc/fstab; then
    echo "🔗 Adding Tailscale mounts to /etc/fstab..."
    echo "$TS_NAS_IP:/volume1/University /mnt/nas nfs rw,_netdev,x-systemd.automount,noauto,soft,timeo=14 0 0" | sudo tee -a /etc/fstab
    echo "$TS_PROXMOX_IP:/home/michael/University/USQ /mnt/proxmox nfs rw,_netdev,x-systemd.automount,noauto,soft,timeo=14 0 0" | sudo tee -a /etc/fstab
    sudo systemctl daemon-reload
fi

# 3. Create Local University Folders
mkdir -p $HOME/Documents/University
mkdir -p $HOME/Synology_Home
