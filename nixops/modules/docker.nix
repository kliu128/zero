{ config, lib, pkgs, ... }:

{
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = false; # Use better prune script below
    # Enabling live restore breaks flannel -- see a similar note at
    # https://github.com/kubernetes-incubator/kubespray/blob/a39e78d42d5bcb6893d0981fc478a3883364fdae/roles/network_plugin/flannel/handlers/main.yml#L12
    # When flannel changes its subnet and changes `/run/flannel/docker`, thus
    # changing Docker's `--bip` argument, Docker appears to ignore it when
    # liveRestore is enabled, and keeps using the old IP for `docker0`. So, uh,
    # don't do that.
    liveRestore = false;
  };
  systemd.services.docker = {
    after = [ "nfs-server.service" "remote-fs.target" ];
    wants = [ "nfs-server.service" "remote-fs.target" ];
    restartIfChanged = false;
    serviceConfig.Nice = 10;
  };

  systemd.services.docker-prune-enhanced = {
    description = "Enhanced Docker Prune";
    path = [ pkgs.docker ];
    script = ''
      docker system prune --volumes --force --all
    '';
    startAt = "*-*-* 03:00:00";
  };

  users.extraUsers.kevin.extraGroups = [ "docker" ];
}
