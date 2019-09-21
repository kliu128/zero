{ config, lib, pkgs, ... }:

{
  networking.networkmanager.enable = false;

  home-manager.users.kevin.home.file.".config/sway/config".text = ''
    output HDMI-A-2 mode 2560x1080@60Hz pos 1280,0
    output DVI-D-1 mode 1600x900@60Hz pos 3840,0
    output HDMI-A-1 mode 1280x1024@60Hz pos 0,0
    workspace 1 output HDMI-A-2
    workspace 2 output DVI-D-1
    workspace 3 output HDMI-A-1
  '';
}
