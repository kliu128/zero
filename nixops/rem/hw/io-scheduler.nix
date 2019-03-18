{ config, lib, pkgs, ... }:

{
  boot.kernelParams = [ "scsi_mod.use_blk_mq=Y" ];
  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="sd*[!0-9]|sr*|nvme0n*", ATTR{queue/scheduler}="mq-deadline"
    ACTION=="add|change", KERNEL=="sdg", ATTR{queue/scheduler}="kyber"
  '';
}
