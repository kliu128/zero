{ config, lib, pkgs, ... }:

{
  services.kubernetes.roles = [ "node" ];
  # Only supposed to be run on masters
  services.kubernetes.controllerManager.enable = false;
  services.kubernetes.scheduler.enable = false;
  services.kubernetes.apiserver.enable = false;
}