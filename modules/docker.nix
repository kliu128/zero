{ config, lib, pkgs, ... }:

{
  virtualisation.docker.enable = true;
  virtualisation.docker.autoPrune.enable = true;
  systemd.services.docker.after = [ "remote-fs.target" ];
  systemd.services.docker.wants = [ "remote-fs.target" ];
  systemd.services.docker.serviceConfig.CPUSchedulingPolicy = "idle";
  systemd.services.docker-shutdown = {
    wantedBy = [ "multi-user.target" ];
    restartIfChanged = false;
    serviceConfig.Type = "oneshot";
    serviceConfig.RemainAfterExit = true;
    after = [ "docker.service" "docker.socket" "local-fs.target" "nfs-server.service" "remote-fs.target" ];
    before = [ "kubelet.service" ];
    preStop = ''
      ${pkgs.docker}/bin/docker stop $(${pkgs.docker}/bin/docker ps -q)
    '';
  };
  users.extraUsers.kevin.extraGroups = [ "docker" ];
  networking.firewall.allowedTCPPorts = [ 2376 2377 7946 ];
  networking.firewall.allowedUDPPorts = [ 4789 7946 ];
}
