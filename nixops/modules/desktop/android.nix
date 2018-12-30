{ config, lib, pkgs, ... }:

{
  nixpkgs.config.android_sdk.accept_license = true;
  environment.systemPackages = [ pkgs.android-studio ];
  programs.adb.enable = true;
}