{ config, lib, pkgs, ... }:

{
  boot.kernelParams = [  ];
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_4_20;
  # boot.kernelPatches = [
  #   {
  #       name = "ck";
  #       patch = ./patch-4.19-ck1;
  #       extraConfig = ''
  #         SCHED_MUQSS y
  #         HZ_PERIODIC y
  #       '';
  #     }
  # ];
  # programs.criu.enable = true;
  # nixpkgs.config.packageOverrides = pkgs: rec {
  #   kubernetes = pkgs.kubernetes.overrideAttrs (oldAttrs: rec {
  #     postPatch = ''
  #       ${oldAttrs.postPatch}
  #       substituteInPlace "pkg/kubelet/cm/container_manager_linux.go" --replace '"cpu", "cpuacct", "cpuset", "memory"' '"cpu", "cpuset", "memory"'
  #     '';
  #   });
  # };
}
