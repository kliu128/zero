{ config, lib, pkgs, ... }:

{
  networking.networkmanager.enable = false;

  home-manager.users.kevin.home.file.".config/sway/config".text = ''
    output HDMI-A-1 mode 2560x1080@60Hz pos 0,0
    output DP-1 mode 1280x1024@60Hz pos 2560,0
    output DVI-D-1 mode 1280x1024@60Hz pos 3840,0
    output HDMI-A-2 mode 1920x1080@60Hz pos 5120,0
    workspace 1 output HDMI-A-1
    workspace 2 output DP-1
    workspace 3 output DVI-D-1
    workspace 4 output HDMI-A-2
  '';
}
