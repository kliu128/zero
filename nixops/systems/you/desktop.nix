{ config, lib, pkgs, ... }:

{
  virtualisation.libvirtd.enable = true;
  users.extraUsers.kevin.extraGroups = [ "libvirtd" ];

  services.synergy.client = {
    enable = true;
    serverAddress = "192.168.1.5";
  };

  home-manager.users.kevin.home.file.".config/sway/config".text = ''
    output eDP-1 scale 2
  '';
}