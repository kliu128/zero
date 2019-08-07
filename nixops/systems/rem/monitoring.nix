{ config, lib, pkgs, ... }:

{
  # Self-monitoring
  services.vnstat.enable = true;
  services.uptimed.enable = true;
  environment.systemPackages = [ pkgs.vnstat pkgs.uptimed ];
}