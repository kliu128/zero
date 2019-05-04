{ config, lib, pkgs, ... }:

let
  nixpkgs-mozilla = builtins.fetchTarball https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz;
in {
  nixpkgs.overlays = [
    (import nixpkgs-mozilla)
  ];
  environment.systemPackages = with pkgs; [
    latest.firefox-nightly-bin
  ];
  nixpkgs.config.firefox.enableAdobeFlash = true;
  environment.variables = {
    # Trick firefox so it doesn't create new profiles, see https://github.com/mozilla/nixpkgs-mozilla/issues/163
    SNAP_NAME = "firefox";
};
}
