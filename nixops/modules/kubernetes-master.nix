{ config, lib, pkgs, ... }:

{
  # Kubernetes
  services.kubernetes.roles = [ "node" "master" ];
  networking.firewall.allowedTCPPorts = [ 8888 ]; # cfssl

  services.etcd = {
    extraConf = {
      AUTO_COMPACTION_RETENTION = "1";
    };
  };
}
