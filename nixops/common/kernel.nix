{ config, lib, pkgs, ... }:

{
  boot.kernelParams = [ "threadirqs" ];
  boot.kernel.sysctl = {
    "net.ipv4.tcp_fastopen" = 3;
    # BBR for better TCP speeds
    "net.ipv4.tcp_congestion_control" = "bbr";
  };
}
