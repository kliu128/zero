{ config, lib, pkgs, ... }:

{
  virtualisation.libvirtd.enable = true;
  users.extraUsers.kevin.extraGroups = [ "libvirtd" ];

  systemd.tmpfiles.rules = [
    "w /sys/devices/platform/huawei-wmi/fn_lock_state - - - - 1"
  ];
}