{ config, lib, pkgs, ... }:

{
  virtualisation.docker.enable = true;
  virtualisation.docker.autoPrune.enable = true;
  # Enabling live restore breaks flannel -- see a similar note at
  # https://github.com/kubernetes-incubator/kubespray/blob/a39e78d42d5bcb6893d0981fc478a3883364fdae/roles/network_plugin/flannel/handlers/main.yml#L12
  # When flannel changes its subnet and changes `/run/flannel/docker`, thus
  # changing Docker's `--bip` argument, Docker appears to ignore it when
  # liveRestore is enabled, and keeps using the old IP for `docker0`. So, uh,
  # don't do that.
  virtualisation.docker.liveRestore = false;
  systemd.services.docker = {
    after = [ "nfs-server.service" ];
    wants = [ "nfs-server.service" ];
    restartIfChanged = false;
  };
  users.extraUsers.kevin.extraGroups = [ "docker" ];
  networking.firewall.allowedTCPPorts = [ 2376 2377 7946 ];
  networking.firewall.allowedUDPPorts = [ 4789 7946 ];
}
