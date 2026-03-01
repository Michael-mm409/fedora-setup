#!/bin/bash
# hosts/laptop.sh - Michael's IdeaPad-Specific Logic

echo "🔋 Configuring IdeaPad Power & Input..."

# 1. Power Management
# Replaces the basic powertop install with auto-tuning for better battery
sudo dnf install -y powertop
sudo powertop --auto-tune

# 2. Battery Conservation Mode (Specific to IdeaPads)
# This prevents the battery from charging past 60-80% to extend its lifespan
if [ -d "/sys/bus/platform/drivers/ideapad_acpi" ]; then
    echo "🔋 Enabling IdeaPad Battery Conservation Mode..."
    # Note: Requires ideapad_acpi module, standard on Fedora
    echo 1 | sudo tee /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode
fi

# 3. Touchpad Gestures (KDE/Libinput)
echo "🖐️  Optimizing IdeaPad touchpad..."
gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true
