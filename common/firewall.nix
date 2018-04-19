{ config, lib, pkgs, ... }:

{
  networking.firewall.enable = true;
  networking.firewall.allowPing = false;
  networking.firewall.logRefusedConnections = false;
}