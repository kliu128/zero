{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ keybase keybase-gui ];
  home-manager.users.kevin.services = {
    kbfs.enable = true;
    keybase.enable = true;
  };
}
