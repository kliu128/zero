{ config, lib, pkgs, ... }:

{
  # Kubernetes
  services.kubernetes = {
    featureGates = ["AllAlpha"];
    roles = [ "node" "master" ];

    caFile = "/var/lib/kubernetes/certs/ca.pem";
    verbose = true;

    apiserver = {
      securePort = 6443; # Conflicts with hosting on 443
      tlsCertFile = "/var/lib/kubernetes/certs/kube-apiserver.pem";
      tlsKeyFile = "/var/lib/kubernetes/certs/kube-apiserver-key.pem";
      kubeletClientCertFile = "/var/lib/kubernetes/certs/kubelet-client.pem";
      kubeletClientKeyFile = "/var/lib/kubernetes/certs/kubelet-client-key.pem";
      serviceAccountKeyFile = "/var/lib/kubernetes/certs/kube-service-accounts.pem";
    };
    etcd = {
      servers = [ "http://192.168.1.5:2379" ];
      certFile = "/var/lib/kubernetes/certs/etcd-client.pem";
      keyFile = "/var/lib/kubernetes/certs/etcd-client-key.pem";
    };
    kubeconfig = {
      server = "https://192.168.1.5:6443";
    };
    kubelet = {
      tlsCertFile = "/var/lib/kubernetes/certs/kubelet.pem";
      tlsKeyFile = "/var/lib/kubernetes/certs/kubelet-key.pem";
      hostname = "${config.networking.hostName}.${config.networking.domain}";
      kubeconfig = {
        certFile = "/var/lib/kubernetes/certs/apiserver-client-kubelet.pem";
        keyFile = "/var/lib/kubernetes/certs/apiserver-client-kubelet-key.pem";
      };
      extraOpts = "--fail-swap-on=false";
    };
    controllerManager = {
      serviceAccountKeyFile = "/var/lib/kubernetes/certs/kube-service-accounts-key.pem";
      kubeconfig = {
        certFile = "/var/lib/kubernetes/certs/apiserver-client-kube-controller-manager.pem";
        keyFile = "/var/lib/kubernetes/certs/apiserver-client-kube-controller-manager-key.pem";
      };
    };
    scheduler = {
      kubeconfig = {
        certFile = "/var/lib/kubernetes/certs/apiserver-client-kube-scheduler.pem";
        keyFile = "/var/lib/kubernetes/certs/apiserver-client-kube-scheduler-key.pem";
      };
    };
    proxy = {
      kubeconfig = {
        certFile = "/var/lib/kubernetes/certs/apiserver-client-kube-proxy.pem";
        keyFile = "/var/lib/kubernetes/certs/apiserver-client-kube-proxy-key.pem";
      };
    };
    flannel.enable = true;
    addons.dashboard.enable = true;
  };
  networking.firewall.allowedTCPPorts = [
    # Kubernetes - kubelet, etcd, apiserver
    10250 2379 2380 6443 ];
}