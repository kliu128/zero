{ config, lib, pkgs, ... }:

{
  nixpkgs.config.firefox.enableGnomeExtensions = true;
  services.gnome3.chrome-gnome-shell.enable = true;
  
  services.xserver.displayManager.gdm ={
    enable = true;
    wayland = false;
  };
  services.xserver.desktopManager.gnome3.enable = true;
}
