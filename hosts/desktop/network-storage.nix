{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ nfs-utils ];

  # Synology NAS Mount
  fileSystems."/mnt/nas" = {
    device = "192.168.8.3:/volume1/University"; # Verify your actual shared folder path
    fsType = "nfs";
    options = [ "rw" "x-systemd.automount" "noauto" "x-systemd.idle-timeout=600" "soft" ];
  };

  # Mini PC (Proxmox) Mount
  fileSystems."/mnt/proxmox" = {
    device = "192.168.8.2:/home/michael/University/USQ"; # Only if you have NFS exports set up on PVE
    fsType = "nfs";
    options = [ "rw" "x-systemd.automount" "noauto" "x-systemd.idle-timeout=600" "soft" ];
  };
}
