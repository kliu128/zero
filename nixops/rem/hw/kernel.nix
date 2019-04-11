{ config, lib, pkgs, ... }:

{
  boot.kernelParams = [ "rqshare=smp" ];
  boot.kernelPackages = pkgs.linuxPackages_4_19;
  #nixpkgs.config.packageOverrides = pkgs: rec {
  #  kubernetes = pkgs.kubernetes.overrideAttrs (oldAttrs: rec {
  #    postPatch = ''
  #      ${oldAttrs.postPatch}
  #      substituteInPlace "pkg/kubelet/cm/container_manager_linux.go" --replace '"cpu", "cpuacct", "cpuset", "memory"' '"cpu", "cpuset", "memory"'
  #    '';
  #  });
  #};
  #systemd.services.kubelet.restartIfChanged = false;
}
