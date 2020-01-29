{ config, lib, pkgs, ... }:

{
  networking.networkmanager.enable = false;

  environment.systemPackages = [ pkgs.barrier ];
  
  home-manager.users.kevin.services.redshift = {
    enable = true;
    latitude = "72";
    longitude = "-42";
    tray = true;
  };
}
