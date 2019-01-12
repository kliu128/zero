{ config, lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    pidgin-with-plugins
  ];
  nixpkgs.config = {
    packageOverrides = pkgs: with pkgs; {
      pidgin-with-plugins = pkgs.pidgin-with-plugins.override {
        ## Add whatever plugins are desired (see nixos.org package listing).
        plugins = [ skype4pidgin ];
      };
    };
  };
}