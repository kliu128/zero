{ config, lib, pkgs, ... }:

{
  # rem-specific desktop configuration
  services.resilio = {
    enable = true;
    deviceName = "rem";
    enableWebUI = true;
  };

  home-manager.users.kevin = {
    home.file.".config/sway/config".text = builtins.readFile ./sway;
  };

  services.synergy.server.enable = true;
  services.synergy.server.configFile = ./synergyServer.conf;
  networking.firewall.allowedTCPPorts = [ 3389 24800 ]; # synergy port

  home-manager.users.kevin.xsession.windowManager.i3.extraConfig = ''
    workspace 1 output HDMI-A-0
    workspace 2 output DisplayPort-0
    workspace 3 output DVI-D-0
    workspace 4 output HDMI-A-1
    exec xrandr --output DisplayPort-1 --off --output DisplayPort-0 --primary --mode 1280x1024 --pos 2560x56 --rotate normal --output DVI-D-0 --mode 1280x1024 --pos 3840x56 --rotate normal --output HDMI-A-1 --mode 1920x1080 --pos 5120x0 --rotate normal --output HDMI-A-0 --mode 2560x1080 --pos 0x0 --rotate normal

    
    # STARTUP APPLICATIONS
    # ====================
    exec --no-startup-id i3-msg 'workspace 1; exec firefox; workspace 3; layout tabbed; exec $term; emacsclient -c; workspace 2; layout tabbed; exec thunderbird; exec Discord'
  '';

  services.xrdp = {
    enable = true;
    defaultWindowManager = "/home/kevin/.xsession";
  };
}
