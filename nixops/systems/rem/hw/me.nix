{ config, lib, pkgs, ... }:

{
  # Intel Management Engine: Neutralized.
  boot.blacklistedKernelModules = [ "mei_me" "mei" ];
  environment.systemPackages = with pkgs; [ intelmetool ];
}