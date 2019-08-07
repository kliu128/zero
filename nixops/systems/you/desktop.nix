{ config, lib, pkgs, ... }:

{
  virtualisation.libvirtd.enable = true;
  users.extraUsers.kevin.extraGroups = [ "libvirtd" ];
}