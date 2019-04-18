{ config, lib, pkgs, ... }:

{
  # Configure NixOS/nix
  nixpkgs.config.allowUnfree = true;
  nix.buildCores = 0; # use all available CPU cores
  nix.daemonNiceLevel = 19;
  nix.optimise.automatic = true;
  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 1d";
}
