{ config, lib, pkgs, ... }:

{
  services.xserver.displayManager.gdm = {
    enable = true;
    wayland = true;
    autoSuspend = false;
  };
  services.pipewire.enable = true;
  services.xserver.desktopManager.gnome3.enable = true;

  # Disable annoyances
  services.gnome3.tracker-miners.enable = false;
  services.gnome3.tracker.enable = false;

  systemd.user.services.gvfs-udisks2-volume-monitor.enable = false;

  environment.systemPackages = with pkgs; [
    papirus-icon-theme gnome3.gnome-tweak-tool
  ];
}
