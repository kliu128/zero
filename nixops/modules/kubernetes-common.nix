{ config, lib, pkgs, ... }:

{
  # Kubernetes
  boot.supportedFilesystems = [ "nfs" ];
  services.kubernetes = {
    easyCerts = true;
    masterAddress = "rem.i.potatofrom.space";
    apiserverAddress = "https://rem.i.potatofrom.space:6443";
    kubelet = {
      # Disable swap warning, and make it so that pods aren't evacuated from nodes due 
      # to low disk space (I like running my computers to the edge :D)
      extraOpts = "--fail-swap-on=false --eviction-soft=nodefs.available<2% --eviction-hard=nodefs.available<1% --eviction-soft-grace-period=nodefs.available=1m30s --image-gc-high-threshold 99
      --cni-bin-dir=/opt/cni/bin";
      networkPlugin = "cni";
    };
    apiserver = {
      allowPrivileged = true;
      securePort = 6443;
      bindAddress = "10.99.0.1";
      advertiseAddress = "10.99.0.1";
      # Re-enable legacy  api endpoints
      # https://gitlab.com/gitlab-org/charts/gitlab/issues/1562
      extraOpts = "--runtime-config=apps/v1beta1=true,apps/v1beta2=true,extensions/v1beta1/daemonsets=true,extensions/v1beta1/deployments=true,extensions/v1beta1/replicasets=true,extensions/v1beta1/networkpolicies=true,extensions/v1beta1/podsecuritypolicies=true";
    };
    flannel.enable = false;
    addons.dashboard.enable = true;
    addons.dashboard.rbac.enable = true;
    addons.dns.enable = true;
  };

  networking.firewall = {
    allowedTCPPorts = [
      # Calico BGP port 179
      179
      # Kubernetes - kubelet, etcd, apiserver
      10250 2379 2380 6443
      # Node Exporter
      9100 ];
  };

  # Calico configuration
  services.kubernetes.kubelet.cni.configDir = "/etc/cni/net.d";
  # Hardcode flannel configuration below
  services.kubernetes.kubelet.cni.config = lib.mkForce [];

  # Calico requires RP filter not to be set to "loose"
  boot.kernel.sysctl."net.ipv4.conf.all.rp_filter" = 1;
}
