{ config, lib, pkgs, ... }:

{
  services.xserver.displayManager.gdm = {
    enable = true;
    # Prevents auto-VT switching when wayland = true for some reason
    wayland = false;
  };
  services.xserver.desktopManager.gnome3.enable = true;

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
    qt = {
      enable = true;
      platformTheme = "gnome";
    };
  };

  # Disable laggy services
  systemd.user.services.gvfs-udisks2-volume-monitor.enable = lib.mkForce false;
}
