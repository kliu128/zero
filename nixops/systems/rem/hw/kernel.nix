{ config, lib, pkgs, ... }:

{
  boot.kernelPackages = pkgs.linuxPackages;
  boot.kernelParams = [ "threadirqs" ];
  boot.kernelPatches = lib.singleton {
    name = "enable-preempt";
    patch = null;
    extraConfig = ''
      PREEMPT_VOLUNTARY n
      PREEMPT y
    '';
  };
  #nixpkgs.config.packageOverrides = pkgs: {
  # kubernetes = pkgs.kubernetes.overrideAttrs (oldAttrs: rec {
  #   postPatch = ''
  #    ${oldAttrs.postPatch}
  #     substituteInPlace "pkg/kubelet/cm/container_manager_linux.go" --replace '"cpu", "cpuacct", "cpuset", "memory"' '"cpu", "cpuset", "memory"'
  #    '';
  # });
  #};
  #systemd.services.kubelet.restartIfChanged = false;
}
