{ config, lib, pkgs, ... }:

{
  services.kubernetes.roles = [ "node" ];
  # Only supposed to be run on masters
  services.kubernetes.scheduler.enable = false;
}