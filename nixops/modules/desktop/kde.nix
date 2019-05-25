{ config, lib, pkgs, ... }:

{
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = true;
  services.xserver.desktopManager.gnome3.enable = true;
  programs.sway.enable = true;
  networking.networkmanager.enable = false;

  environment.systemPackages = with pkgs; [
    papirus-icon-theme arc-theme
  ];

  # Disable laggy services
  systemd.user.services.gvfs-udisks2-volume-monitor.enable = lib.mkForce false;

  nixpkgs.config.firefox.enableGnomeExtensions = true;
  services.gnome3.chrome-gnome-shell.enable = true;
}
