{ config, lib, pkgs, ... }:

{
  services.keybase.enable = true;
  services.kbfs.enable = true;
  environment.systemPackages = with pkgs; [ keybase keybase-gui ];
}