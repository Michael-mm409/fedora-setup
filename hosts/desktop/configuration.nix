{ config, pkgs, ... }:

{
  imports = [ 
    ./hardware-configuration.nix 
    ./nvidia.nix
    ./network-storage.nix 
  ];

  networking.hostName = "nixos-desktop";

  # Move GNOME/System settings here from common.nix since Fedora handles its own
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  
  # Desktop-specific hardware control
  services.hardware.openrgb.enable = true;
  environment.systemPackages = [ pkgs.openrgb-with-all-plugins pkgs.psmisc ];

  system.stateVersion = "25.11";
}

