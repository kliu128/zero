{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    ntfs3g
  ];
}