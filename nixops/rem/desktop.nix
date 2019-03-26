{ config, lib, pkgs, ... }:

{
  # rem-specific desktop configuration
  services.synergy.server.enable = true;
  services.synergy.server.configFile = ./synergyServer.conf;
  networking.firewall.allowedTCPPorts = [ 3389 24800 ]; # synergy port
  networking.networkmanager.enable = false;
}
