{ config, lib, pkgs, ... }:

{
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  environment.systemPackages = [ pkgs.arc-theme pkgs.papirus-icon-theme pkgs.gnome3.nautilus ];

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

  # See https://www.reddit.com/r/kde/comments/7ey774/cant_scroll_in_gtk_apps_like_firefox_after/
  environment.variables = {
    GDK_CORE_DEVICE_EVENTS = "1";
  };

  # Disable laggy services
  # systemd.user.services.gvfs-udisks2-volume-monitor.enable = lib.mkForce false;
}
