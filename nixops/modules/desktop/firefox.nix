{ config, lib, pkgs, ... }:

{
  nixpkgs.overlays = [
    (import ./nixpkgs-mozilla)
  ];
  environment.systemPackages = with pkgs; [
    latest.firefox-nightly-bin
  ];

  nixpkgs.config.firefox.enableAdobeFlash = true;
  environment.variables = {
    MOZ_USE_XINPUT2 = "1";
  };
}
