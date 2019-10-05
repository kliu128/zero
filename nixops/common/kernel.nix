{ config, lib, pkgs, ... }:

{
  boot.kernel.sysctl = {
    "net.ipv4.tcp_fastopen" = 3;
    # BBR for better TCP speeds
    "net.ipv4.tcp_congestion_control" = "bbr";
  };
  systemd.tmpfiles.rules = [
    "w /sys/kernel/mm/transparent_hugepage/enabled - - - - always"
  ];
}
