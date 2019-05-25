{ config, lib, pkgs, ... }:

{
  # Kubernetes
  services.kubernetes = {
    easyCerts = true;
    masterAddress = "rem.i.potatofrom.space";
    apiserverAddress = "https://rem.i.potatofrom.space:6443";
    kubelet = {
      allowPrivileged = true;
      # Disable swap warning, and make it so that pods aren't evacuated from nodes due 
      # to low disk space (I like running my computers to the edge :D)
      extraOpts = "--fail-swap-on=false --eviction-soft=nodefs.available<2% --eviction-hard=nodefs.available<1% --eviction-soft-grace-period=nodefs.available=1m30s --image-gc-high-threshold 99";
    };
    apiserver.allowPrivileged = true;
    apiserver.securePort = 6443;
    apiserver.bindAddress = "10.99.0.1";
    apiserver.advertiseAddress = "10.99.0.1";
    flannel.enable = true;
    addons.dashboard.enable = true;
    addons.dashboard.rbac.enable = true;
    addons.dns.enable = true;
  };
  services.flannel.iface = "tinc.omnimesh";
  networking.firewall = {
    allowedTCPPorts = [
      # Kubernetes - kubelet, etcd, apiserver
      10250 2379 2380 6443
      # Node Exporter
      9100 ];
  };
  services.nfs.server.enable = true;
  systemd.services.flannel.path = [ pkgs.iptables ];
  systemd.services.mk-docker-opts.restartIfChanged = false;
  systemd.services.mk-docker-opts.serviceConfig.RemainAfterExit = true;

  boot.kernel.sysctl = {
    "net.ipv4.neigh.default.gc_thresh1" = 80000;
    "net.ipv4.neigh.default.gc_thresh2" = 90000;
    "net.ipv4.neigh.default.gc_thresh3" = 100000;
  };

  systemd.services.clean-up-flannel-ips = {
    enable = true;
    description = "Clean up Flannel IPs";
    path = [ pkgs.gawk pkgs.docker pkgs.findutils pkgs.gnugrep ];
    script = ''
      set -xeuo pipefail

      cd /var/lib/cni/networks/mynet

      for hash in $(tail -n +1 * | grep '^[A-Za-z0-9]*$' | cut -c 1-8); do if [ -z $(docker ps -a | grep $hash | awk '{print $1}') ]; then grep -ilr $hash ./; fi; done | xargs rm
    '';
  };
  systemd.timers.clean-up-flannel-ips = {
    enable = true;
    timerConfig.OnUnitActiveSec = 600; # every 5 min
    wantedBy = [ "timers.target" ];
  };
}
