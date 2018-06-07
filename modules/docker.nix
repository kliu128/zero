{ config, lib, pkgs, ... }:

{
  virtualisation.docker.enable = true;
  virtualisation.docker.autoPrune.enable = true;
  # Incompatible with Docker swarm, and causes a bunch of errors on computer
  # shutdown when enabled.
  virtualisation.docker.liveRestore = false;
  systemd.services.docker.restartIfChanged = false;
  systemd.services.docker.preStop = ''
    ${pkgs.docker}/bin/docker stop $(${pkgs.docker}/bin/docker ps -q)
  '';
  systemd.services.docker.after = [ "remote-fs.target" ];
  systemd.services.docker.wants = [ "remote-fs.target" ];
  users.extraUsers.kevin.extraGroups = [ "docker" ];
  networking.firewall.allowedTCPPorts = [ 2376 2377 7946 ];
  networking.firewall.allowedUDPPorts = [ 4789 7946 ];
}
