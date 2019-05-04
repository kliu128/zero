{ config, lib, pkgs, ... }:

{
  # services.xserver.displayManager.sddm.enable = true;
  # services.xserver.desktopManager.plasma5.enable = true;
  # services.xserver.desktopManager.mate.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = false;
  services.xserver.desktopManager.gnome3.enable = true;
  networking.networkmanager.enable = false;

  environment.systemPackages = with pkgs; [
    # ark kate gnome3.evince spectacle

    papirus-icon-theme arc-theme
  ];
}
