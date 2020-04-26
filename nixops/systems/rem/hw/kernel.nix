{ config, lib, pkgs, ... }:

{
  boot.kernelPackages = pkgs.linuxPackages_ck;

  boot.kernelParams = [ "threadirqs" ];

  nixpkgs.config.packageOverrides = pkgs: {
  kubernetes = pkgs.kubernetes.overrideAttrs (oldAttrs: rec {
    postPatch = ''
     ${oldAttrs.postPatch}
      substituteInPlace "pkg/kubelet/cm/container_manager_linux.go" --replace '"cpu", "cpuacct", "cpuset", "memory"' '"cpu", "cpuset", "memory"'
     '';
  });
  };
  systemd.services.kubelet.restartIfChanged = false;
  # Liquorix sysctl
  boot.kernel.sysctl = {
    "kernel.rr_interval" = 2;
    "kernel.yield_type" = 0;
  };
  systemd.services.docker.serviceConfig.CPUSchedulingPolicy = "idle";
}
