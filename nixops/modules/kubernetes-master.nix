{ config, lib, pkgs, ... }:

{
  # Kubernetes
  services.kubernetes.roles = [ "node" "master" ];

  services.etcd = {
    extraConf = {
      AUTO_COMPACTION_RETENTION = "1";
    };
  };
}
