{ config, lib, pkgs, ... }:

{
  # Configure NixOS/nix
  nixpkgs.config.allowUnfree = true;
  nix.buildCores = 8; # use all available CPU cores
  nix.daemonNiceLevel = 18;
  nix.autoOptimiseStore = true;
  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 1d";
  nix.extraOptions = ''
    binary-caches-parallel-connections = 4
  '';

  # Increase open file limit to avoid running out of file descriptors when
  # deploying NixOS
  systemd.extraConfig = "DefaultLimitNOFILE=1048576";
}
