{ config, lib, pkgs, ... }:

{
  services.transmission = {
    enable = true;
    settings = {
      download-dir = "/mnt/storage/Kevin/Incoming/local";
      incomplete-dir-enabled = false;
    };
  };
  systemd.tmpfiles.rules = [
    "d /mnt/storage/Kevin/Incoming/local 0770 transmission transmission - -"
  ];
}