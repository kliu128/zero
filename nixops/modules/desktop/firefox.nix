{ config, lib, pkgs, ... }:

let
  moz_overlay = import (builtins.fetchTarball https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz);
in {
  nixpkgs.overlays = [ moz_overlay ];

  environment.systemPackages = with pkgs; [ firefox ];

  home-manager.users.kevin.home.sessionVariables = {
    MOZ_USE_XINPUT2 = "1";
    MOZ_ENABLE_WAYLAND = "true";
  };
}
