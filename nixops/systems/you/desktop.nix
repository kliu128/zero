{ config, lib, pkgs, ... }:

{
  virtualisation.libvirtd.enable = true;
  users.extraUsers.kevin.extraGroups = [ "libvirtd" ];

  home-manager.users.kevin.home.file.".config/sway/config".text = ''
    output eDP-1 scale 2
  '';
}