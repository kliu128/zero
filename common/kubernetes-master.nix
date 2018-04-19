{ config, lib, pkgs, ... }:

{
  # Kubernetes
  services.kubernetes.roles = [ "node" "master" ];
  services.etcd = {
    enable = true;
    listenClientUrls = [ "http://0.0.0.0:2379" ];
    advertiseClientUrls = [ "http://192.168.1.5:2379" ];

    # Check client-sent certificates to make sure they were signed by the
    # trusted CA
    clientCertAuth = true;
    trustedCaFile = "/var/lib/kubernetes/certs/ca.pem";
  };
}