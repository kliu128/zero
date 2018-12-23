{ config, lib, pkgs, ... }:

{
  boot.kernelParams = [ "scsi_mod.use_blk_mq=N" ];
}
