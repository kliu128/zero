{ config, lib, pkgs, ... }:

{
  virtualisation.docker.enable = true;
  virtualisation.docker.autoPrune.enable = true;
  virtualisation.docker.liveRestore = false;
  systemd.services.docker.restartIfChanged = false;
  users.extraUsers.kevin.extraGroups = [ "docker" ];
  networking.firewall.allowedTCPPorts = [ 2376 2377 7946 ];
  networking.firewall.allowedUDPPorts = [ 4789 7946 ];
}