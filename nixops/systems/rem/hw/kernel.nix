{ config, lib, pkgs, ... }:

{
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
