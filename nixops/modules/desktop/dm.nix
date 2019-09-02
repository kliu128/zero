{ config, lib, pkgs, ... }:

{
  services.xserver.displayManager.gdm = {
    enable = true;
    # Prevents auto-VT switching when wayland = true for some reason
    wayland = false;
  };
  services.xserver.desktopManager.gnome3.enable = true;

  environment.systemPackages = with pkgs; [
    papirus-icon-theme arc-theme
  ];

  # Disable laggy services
  systemd.user.services.gvfs-udisks2-volume-monitor.enable = lib.mkForce false;
}
