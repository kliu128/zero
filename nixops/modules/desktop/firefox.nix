{ config, lib, pkgs, ... }:

let
  moz = import (builtins.fetchTarball https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz);
in {
  nixpkgs.overlays = [ moz ];
  nixpkgs.config.firefox.enableAdobeFlash = true;
  environment.systemPackages = with pkgs; [
    latest.firefox-nightly-bin
    # firefox
  ];
}
