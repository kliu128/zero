{ config, lib, pkgs, ... }:

let
  nixpkgs-mozilla = builtins.fetchTarball https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz;
in {
  nixpkgs.overlays = [
    (import nixpkgs-mozilla)
  ];
  environment.systemPackages = with pkgs; [
    firefox-wayland
  ];
  nixpkgs.config.firefox-wayland.enableAdobeFlash = true;
  environment.variables = {
    # Trick firefox so it doesn't create new profiles, see https://github.com/mozilla/nixpkgs-mozilla/issues/163
    SNAP_NAME = "firefox";
    # Enable touchscreen support for Firefox
    # see https://support.mozilla.org/en-US/questions/1091627
    MOZ_USE_XINPUT2 = "1";
  };
}
