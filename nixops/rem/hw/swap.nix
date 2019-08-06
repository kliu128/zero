{ config, lib, pkgs, ... }:

{
  swapDevices = [ {
    device = "/dev/disk/by-id/ata-Samsung_SSD_860_EVO_500GB_S3Z1NB0K384615J-part3";
    randomEncryption.enable = true;
  } ];
  # 2GB max arc
  systemd.tmpfiles.rules = [
    "w /sys/kernel/mm/transparent_hugepage/enabled - - - - always"
    "w /sys/kernel/mm/transparent_hugepage/defrag - - - - defer+madvise"
  ];
}
