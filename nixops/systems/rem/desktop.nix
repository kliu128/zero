{ config, lib, pkgs, ... }:

{
  networking.networkmanager.enable = false;

  networking.firewall.allowedTCPPorts = [ 24800 ];
}
