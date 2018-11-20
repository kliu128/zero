{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    firefox-beta-bin
  ];
  environment.variables.MOZ_WEBRENDER = "1";
}