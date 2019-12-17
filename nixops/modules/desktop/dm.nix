{ config, lib, pkgs, ... }:

{
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = false;
  services.xserver.desktopManager.gnome3.enable = true;

  services.gnome3.tracker-miners.enable = false;
  services.gnome3.tracker.enable = false;

  environment.systemPackages = with pkgs; [
    arc-theme papirus-icon-theme gnome3.nautilus gnome3.gnome-screenshot gnome3.evince
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

  systemd.user.services.gvfs-udisks2-volume-monitor.enable = lib.mkForce false;
}
