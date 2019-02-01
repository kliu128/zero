{ config, lib, pkgs, ... }:

{
  home-manager.users.kevin = {
    services.keybase.enable = true;
  };
  environment.systemPackages = with pkgs; [ keybase keybase-gui ];
}