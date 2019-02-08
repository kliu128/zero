{ config, lib, pkgs, ... }:

{
  boot.kernelParams = [ "scsi_mod.use_blk_mq=Y" ];
  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="sd*[!0-9]|sr*|nvme0n*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="none"
    ACTION=="add|change", KERNEL=="sd*[!0-9]|sr*|nvme0n*", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
  '';
}
