{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    firefox
  ];
  nixpkgs.config.firefox.enableAdobeFlash = true;
  environment.variables = {
    # Trick firefox so it doesn't create new profiles, see https://github.com/mozilla/nixpkgs-mozilla/issues/163
    SNAP_NAME = "firefox";
    # Enable touchscreen support for Firefox
    # see https://support.mozilla.org/en-US/questions/1091627
    MOZ_USE_XINPUT2 = "1";
  };
}
