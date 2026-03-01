{ config, pkgs, ... }:

{
  # 1. Enable Graphics (OpenGL/Vulkan)
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Critical for Steam and older games
  };

  # 2. Load the NVIDIA Driver
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    # Modesetting is required for Wayland/GNOME
    modesetting.enable = true;

    # Blackwell (50-series) requires the Open Kernel Module
    open = true;

    # Enable the NVIDIA settings menu (nvidia-settings)
    nvidiaSettings = true;

    # Select the latest stable driver for 50-series
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # 3. i7-13700K Stability & Performance
  hardware.cpu.intel.updateMicrocode = true; # Fixes 13th-gen voltage issues
  
  # Kernel parameters to ensure Blackwell GPUs boot smoothly
  boot.kernelParams = [ "nvidia-drm.fbdev=1" ];

  # Ensure Conda/Python can use the 5070-TI for AI tasks
  hardware.graphics.extraPackages = [ pkgs.nvidia-vaapi-driver ];
}
