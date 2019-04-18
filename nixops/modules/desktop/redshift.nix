{ config, lib, pkgs, ... }:

{
  home-manager.users.kevin.services.redshift = {
    enable = true;
    latitude = "42.5";
    longitude = "-71.5";
    provider = "manual";
    temperature = {
      day = 5500;
      night = 3700;
    };
    tray = true;
  };
}