{ config, lib, pkgs, ... }:

{
  swapDevices = [ {
    device = "/dev/disk/by-id/ata-Samsung_SSD_860_EVO_500GB_S3Z1NB0K384615J-part3";
    randomEncryption.enable = true;
  } ];
  
  systemd.tmpfiles.rules = [
    "w /sys/module/zswap/parameters/enabled - - - - Y"
    "w /sys/module/zswap/parameters/compressor - - - - lz4"
    "w /sys/module/zswap/parameters/zpool - - - - z3fold"
  ];
}
