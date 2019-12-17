{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ chromium ];
  nixpkgs.config.chromium.enablePepperFlash = true;
}
