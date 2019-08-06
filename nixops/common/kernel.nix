{ config, lib, pkgs, ... }:

{
  boot.kernelPackages = pkgs.linuxPackages;
  boot.kernel.sysctl = {
    "kernel.panic_on_oops" = 0;
    "kernel.io_delay_type" = 3; # no IO delay
    "net.ipv4.tcp_fastopen" = 3;
    "net.ipv4.tcp_congestion_control" = "bbr";
  };
}
