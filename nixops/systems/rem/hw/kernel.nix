{ config, lib, pkgs, ... }:

{
  boot.kernel.sysctl = {
    "vm.min_free_kbytes" = 256000;
  };
  boot.kernelParams = [ "amdgpu.gpu_recovery=1" ];
  nixpkgs.config.packageOverrides = pkgs: rec {
    kubernetes = pkgs.kubernetes.overrideAttrs (oldAttrs: rec {
      postPatch = ''
        ${oldAttrs.postPatch}
        substituteInPlace "pkg/kubelet/cm/container_manager_linux.go" --replace '"cpu", "cpuacct", "cpuset", "memory"' '"cpu", "cpuset", "memory"'
      '';
    });
  };
  systemd.services.kubelet.restartIfChanged = false;
}
