# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  #networking.wireless.enable = true;
  networking.networkmanager.enable = true;
  users.extraUsers.kevin.extraGroups = [ "networkmanager" ];
  #networking.wireless.networks."9WJP3-5GHz" = {
  #  psk = "***REMOVED***";
  #};
}
