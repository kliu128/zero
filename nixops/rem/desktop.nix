{ config, lib, pkgs, ... }:

{
  # rem-specific desktop configuration
  home-manager.users.kevin.xsession.windowManager.i3.extraConfig = ''
    workspace 1 output HDMI-1
    workspace 2 output DP-1
    workspace 3 output DVI-D-1
    exec xrandr --output DVI-D-1 --mode 1280x1024 --pos 3840x56 --rotate normal --output HDMI-1 --mode 2560x1080 --pos 0x0 --rotate normal --output DP-2 --off --output DP-1 --mode 1280x1024 --pos 2560x56 --rotate normal --output HDMI-2 --off
    
    # STARTUP APPLICATIONS
    # ====================
    exec --no-startup-id i3-msg 'workspace 1; exec firefox; workspace 3; layout tabbed; exec $term; emacsclient -c; workspace 2; layout tabbed; exec thunderbird; exec Discord'
  '';
}