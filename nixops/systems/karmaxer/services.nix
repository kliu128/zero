{ config, lib, pkgs, ... }:

{
  virtualisation.libvirtd.enable = true;
  # Allow kevin to manage libvirt
  users.extraUsers.kevin.extraGroups = [ "libvirtd" ];
}
