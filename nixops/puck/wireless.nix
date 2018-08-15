{ config, pkgs, lib, ... }:

{
  networking.networkmanager.enable = true;
  users.extraUsers.kevin.extraGroups = [ "networkmanager" ];
  home-manager.users.kevin.home.packages = [ pkgs.networkmanagerapplet ];
  home-manager.users.kevin.xsession.windowManager.i3.extraConfig = ''
    exec nm-applet
  '';
  services.fail2ban.enable = lib.mkForce false;
}
