{ config, lib, pkgs, ... }:

{
  boot.kernelPackages = pkgs.linuxPackages_ck;
  boot.kernelParams = [ "rqshare=none" "amdgpu.vm_update_mode=3" ];
  nixpkgs.config.packageOverrides = pkgs: {
   kubernetes = pkgs.kubernetes.overrideAttrs (oldAttrs: rec {
     postPatch = ''
       ${oldAttrs.postPatch}
       substituteInPlace "pkg/kubelet/cm/container_manager_linux.go" --replace '"cpu", "cpuacct", "cpuset", "memory"' '"cpu", "cpuset", "memory"'
      '';
   });
  };
  systemd.services.kubelet.restartIfChanged = false;
}
