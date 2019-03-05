{ config, lib, pkgs, ... }:

{
  # boot.kernelParams = [ "rqshare=smp" ];
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_4_19;
  # boot.kernelPatches = [
  #   {
  #     name = "ck2";
  #     patch = ./patch-4.20-ck1.patch;
  #     extraConfig = ''
  #       SCHED_MUQSS y
  #       PREEMPT y
  #     '';
  #   }
  #   {
  #     name = "fix-kvm-intel";
  #     patch = ./7c660f6524371c3f9d693deb9595ff6c0725942c.patch;
  #   }
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
