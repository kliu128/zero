{ config, lib, pkgs, ... }:

{
  boot.kernelParams = [ "scsi_mod.use_blk_mq=Y" ];
  boot.kernel.sysctl = {
    "vm.dirty_ratio" = 2;
    "vm.dirty_background_ratio" = 1;
  };
  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="sd*[!0-9]|sr*|nvme0n*", ATTR{queue/scheduler}="kyber"
  '';
}
