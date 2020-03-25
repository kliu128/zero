{ config, lib, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.chromium ];
  programs.chromium.enable = true;
  nixpkgs.config.chromium = {
    enablePepperFlash = false;
    enableWideVine = true;
  };
}
