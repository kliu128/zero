{ config, lib, pkgs, ... }:

{
  services.xserver.displayManager.gdm = {
    enable = true;
    wayland = false;
    autoSuspend = false;
  };
  services.xserver.desktopManager.gnome3.enable = true;

  # Disable annoyances
  services.gnome3.tracker-miners.enable = false;
  services.gnome3.tracker.enable = false;
  systemd.user.services.gvfs-udisks2-volume-monitor.enable = lib.mkForce false;
  systemd.user.services.gsd-housekeeping.enable = lib.mkForce false;

  environment.systemPackages = with pkgs; [
    arc-theme papirus-icon-theme gnome3.gnome-tweak-tool
  ];

  home-manager.users.kevin = {
    gtk = {
      enable = true;
      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };
      theme = {
        name = "Arc-Dark";
        package = pkgs.arc-theme;
      };
    };
  };
}
