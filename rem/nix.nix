{ config, lib, pkgs, ... }:

{
  # Configure NixOS/nix
  nix.autoOptimiseStore = true;
  nix.useSandbox = true;
  nix.nixPath = [ "/etc/nixos" "nixos-config=/etc/nixos/configuration.nix" ];
  nix.buildCores = 0; # use all available CPU cores
  nix.daemonNiceLevel = 19;
  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 1d";
  system.copySystemConfiguration = true; # to /run/current-system/configuration.nix
}
