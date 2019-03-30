{ config, lib, pkgs, ... }:

{
  nixpkgs.config.firefox.enableAdobeFlash = true;
  environment.systemPackages = with pkgs; [
    firefox
  ];
}
