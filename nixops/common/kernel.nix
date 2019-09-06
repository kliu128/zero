{ config, lib, pkgs, ... }:

{
  boot.kernel.sysctl = {
    "net.ipv4.tcp_fastopen" = 3;
    # BBR for better TCP speeds
    "net.ipv4.tcp_congestion_control" = "bbr";
  };

  # Use latest kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [ "threadirqs" "rqshare=none" ];
}
