{ config, lib, pkgs, ... }:

{
  services.foldingathome.enable = true;
  systemd.services.foldingathome.serviceConfig.CPUSchedulingPolicy = "idle";
  networking.firewall.allowedTCPPorts = [ 36330 ];
}
