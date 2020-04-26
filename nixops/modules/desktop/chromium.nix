{ config, lib, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.chromium pkgs.brave ];
  programs.chromium.enable = true;
  nixpkgs.config.chromium = {
    enablePepperFlash = false;
    enableWideVine = true;
  };
}
