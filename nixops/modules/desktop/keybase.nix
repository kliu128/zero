{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ keybase keybase-gui ];
}
