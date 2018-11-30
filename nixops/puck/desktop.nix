# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, ... }:

{
  home-manager.users.kevin = {
    home.packages = with pkgs; [ xorg.xbacklight ];
    xsession.windowManager.i3.extraConfig = ''
      # screen brightness controls
      bindsym XF86MonBrightnessUp exec xbacklight -inc 10
      bindsym XF86MonBrightnessDown exec xbacklight -dec 10
    '';
    pam.sessionVariables = {
      # Enable touchscreen support for Firefox
      # see https://support.mozilla.org/en-US/questions/1091627
      MOZ_USE_XINPUT2 = "1";
    };
  };
  virtualisation.libvirtd.enable = true;
  users.extraUsers.kevin.extraGroups = [ "libvirtd" ];

  services.synergy.client = {
    enable = true;
    serverAddress = "192.168.1.5";
  };
  
  services.logind.extraConfig = "HandlePowerKey=ignore";

  services.emacs.enable = lib.mkForce false; # seems to break shutdown
}
