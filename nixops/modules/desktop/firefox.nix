{ config, lib, pkgs, ... }:

let
  moz = import (builtins.fetchTarball https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz);
in {
  nixpkgs.overlays = [ moz ];
  environment.systemPackages = with pkgs; [
    firefox-beta-bin
  ];
}
