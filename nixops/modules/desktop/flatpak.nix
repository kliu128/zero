{ config, lib, pkgs, ... }:

{
  services.flatpak.enable = true;
  systemd.user.services.xdg-desktop-portal.enable = lib.mkForce false;
  systemd.user.services.xdg-desktop-portal-gtk.enable = lib.mkForce false;
}
