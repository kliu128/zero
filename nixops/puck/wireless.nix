# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  networking.networkmanager.enable = true;
  users.extraUsers.kevin.extraGroups = [ "networkmanager" ];
  home-manager.users.kevin.home.packages = [ pkgs.networkmanagerapplet ];
  home-manager.users.kevin.xsession.windowManager.i3.extraConfig = ''
    exec nm-applet
  '';
}
