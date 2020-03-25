{ config, lib, pkgs, ... }:

{
  services.foldingathome.enable = true;
  systemd.services.foldingathome.serviceConfig.CPUSchedulingPolicy = "idle";
}
