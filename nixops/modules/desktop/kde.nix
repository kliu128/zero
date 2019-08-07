{ config, lib, pkgs, ... }:

{
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = false;
  services.xserver.desktopManager.gnome3.enable = true;
  programs.sway.enable = true;

  environment.systemPackages = with pkgs; [
    papirus-icon-theme arc-theme
  ];

  # Disable laggy services
  systemd.user.services.gvfs-udisks2-volume-monitor.enable = lib.mkForce false;
}
