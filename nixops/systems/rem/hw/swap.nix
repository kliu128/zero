{ config, lib, pkgs, ... }:

{
  swapDevices = [ {
    device = "/dev/disk/by-id/ata-Samsung_SSD_860_EVO_500GB_S3Z1NB0K384615J-part3";
    randomEncryption.enable = true;
  } ];

  boot.kernel.sysctl = {
    "vm.dirty_background_ratio" = 1;
    "vm.dirty_ratio" = 2;
  };
}
