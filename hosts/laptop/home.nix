{ config, pkgs, ... }:

{
  # Fedora handles the drivers; we just add the tools
  home.packages = with pkgs; [
    conda  # Works natively on Fedora
    powertop # Laptop battery monitoring
  ];
}
