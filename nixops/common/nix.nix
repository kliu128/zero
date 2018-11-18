{ config, lib, pkgs, ... }:

{
  # Configure NixOS/nix
  nix.autoOptimiseStore = true;
  nixpkgs.config.allowUnfree = true;
  nix.buildCores = 0; # use all available CPU cores
  nix.daemonNiceLevel = 19;
  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 1d";
}