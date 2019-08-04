{ config, lib, pkgs, ... }:

{
  boot.kernelPackages = pkgs.linuxPackages;
  boot.kernel.sysctl = {
    "kernel.panic_on_oops" = 0;
    "kernel.io_delay_type" = 3; # no IO delay
    "vm.min_free_kbytes" = 256000;
    "net.ipv4.tcp_fastopen" = 3;
    "net.ipv4.tcp_congestion_control" = "bbr";
  };
  #nixpkgs.config.packageOverrides = pkgs: rec {
  #  kubernetes = pkgs.kubernetes.overrideAttrs (oldAttrs: rec {
  #    postPatch = ''
  #      ${oldAttrs.postPatch}
  #      substituteInPlace "pkg/kubelet/cm/container_manager_linux.go" --replace '"cpu", "cpuacct", "cpuset", "memory"' '"cpu", "cpuset", "memory"'
  #    '';
  #  });
  #};
  systemd.services.kubelet.restartIfChanged = false;
}
