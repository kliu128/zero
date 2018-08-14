{ config, lib, pkgs, ... }:

{
  networking.nameservers = lib.mkDefault [ "1.1.1.1" "1.0.0.1" ];
}