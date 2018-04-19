{ config, lib, pkgs, ... }:

{
  # Kubernetes
  services.kubernetes.roles = [ "node" "master" ];
  services.etcd = {
    enable = true;
    listenClientUrls = [ "https://0.0.0.0:2379" ];
    advertiseClientUrls = [ "https://192.168.1.5:2379" ];

    # Serving certificates
    certFile = "/var/lib/kubernetes/certs/etcd.pem";
    keyFile = "/var/lib/kubernetes/certs/etcd-key.pem";

    # Check client-sent certificates to make sure they were signed by the
    # trusted CA
    clientCertAuth = true;
    trustedCaFile = "/var/lib/kubernetes/certs/ca.pem";
  };
}