{ config, lib, pkgs, ... }:

let
  moz = import (builtins.fetchTarball https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz);
in {
  nixpkgs.overlays = [ moz ];
  environment.systemPackages = with pkgs; [
    latest.firefox-nightly-bin
  ];
}