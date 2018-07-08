{ config, lib, pkgs, ... }:

{
  services.redshift = {
    enable = true;
    provider = "manual"; # Provide own longitude + latitude
    latitude = "42";
    longitude = "-71";
  };
}