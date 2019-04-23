{ config, lib, pkgs, ... }:

{
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  environment.systemPackages = with pkgs; [
    ark kate okular spectacle

    papirus-icon-theme arc-theme
  ];
}
