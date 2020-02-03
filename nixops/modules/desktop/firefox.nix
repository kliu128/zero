{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ firefox ];
  
  nixpkgs.config.firefox.enableGnomeExtensions = true;
  nixpkgs.config.firefox.enableAdobeFlash = true;

  environment.variables = {
    MOZ_USE_XINPUT2 = "1";
  };
}
