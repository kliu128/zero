{ config, lib, pkgs, ... }:

{
  services.locate = {
    enable = true;
    locate = pkgs.mlocate;
    localuser = "root";
    pruneBindMounts = true;
    prunePaths =	[
      "/tmp" "/var/tmp" "/var/cache" "/var/lock" "/var/run" "/var/spool" "/nix/store"
      "/mnt/data0" "/mnt/data1" "/mnt/data2" "/mnt/data3" "/mnt/data4"
      "/var/lib/docker"
    ];
  };
}