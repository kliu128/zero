{ config, lib, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.chromium ];
  nixpkgs.config.chromium.enablePepperFlash = true;
}
