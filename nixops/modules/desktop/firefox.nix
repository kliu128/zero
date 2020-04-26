{ config, lib, pkgs, ... }:

let
  moz_overlay = import (builtins.fetchTarball https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz);
in {
  nixpkgs.overlays = [ moz_overlay ];

  environment.systemPackages = with pkgs; [ latest.firefox-nightly-bin ];

  environment.variables = {
    MOZ_USE_XINPUT2 = "1";
    MOZ_ENABLE_WAYLAND = "true";
  };
}
