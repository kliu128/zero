{ config, lib, pkgs, ... }:

{
  boot.kernel.sysctl = {
    "kernel.panic_on_oops" = lib.mkForce 0;
    "net.ipv4.tcp_fastopen" = 3;
    "net.ipv4.tcp_congestion_control" = "bbr";
  };
  boot.kernelPackages = pkgs.linuxPackages_4_19;
}
