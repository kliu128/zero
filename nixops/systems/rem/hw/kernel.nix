{ config, lib, pkgs, ... }:

{
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernel.sysctl = {
    # "kernel.rr_interval" = 2;
    # "kernel.yield_type" = 2;
    "vm.min_free_kbytes" = 512000;
  };
  # nixpkgs.config.packageOverrides = pkgs: {
  #  kubernetes = pkgs.kubernetes.overrideAttrs (oldAttrs: rec {
  #    postPatch = ''
  #     ${oldAttrs.postPatch}
  #      substituteInPlace "pkg/kubelet/cm/container_manager_linux.go" --replace '"cpu", "cpuacct", "cpuset", "memory"' '"cpu", "cpuset", "memory"'
  #     '';
  #  });
  # };
  # systemd.services.kubelet.restartIfChanged = false;
}
