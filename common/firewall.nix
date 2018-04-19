{ config, lib, pkgs, ... }:

{
  # Generic firewall configuration options
  # More specific port allowances are configured in other files.
  networking.firewall.enable = true;
  networking.firewall.allowPing = false;
  networking.firewall.logRefusedConnections = false;
}