{ config, lib, pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [ 34197 ];
}
