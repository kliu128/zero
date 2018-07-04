{ config, lib, pkgs, ... }:

{
  services.vnstat.enable = true;
  services.uptimed.enable = true;
  environment.systemPackages = [ pkgs.vnstat pkgs.uptimed ];
}