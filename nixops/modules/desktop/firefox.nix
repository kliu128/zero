{ config, lib, pkgs, ... }:

{
  nixpkgs.overlays = [ (import ./nixpkgs-mozilla) ];
  environment.systemPackages = with pkgs; [
    latest.firefox-nightly-bin
  ];

  # Enable remote debugger server by default
  home-manager.users.kevin.home.file.".local/share/applications/firefox.desktop".source = ./firefox.desktop;

  nixpkgs.config.firefox.enableAdobeFlash = true;
  environment.variables = {
    # Trick firefox so it doesn't create new profiles, see https://github.com/mozilla/nixpkgs-mozilla/issues/163
    SNAP_NAME = "firefox";
  };
}
