{ config, lib, pkgs, ... }:
let
    # This will point to whatever NIX_PATH states on the local machine,
    # unless overwritten with -I.
    hostNixpkgs = import <nixpkgs> {};
in {
  # Configure NixOS/nix
  nixpkgs.config.allowUnfree = true;
  nix.buildCores = 0; # use all available CPU cores
  nix.daemonNiceLevel = 19;
  systemd.services.nix-daemon.serviceConfig.CPUSchedulingPolicy = "idle";
  nix.optimise.automatic = true;
  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 1d";
  nix.extraOptions = ''
    binary-caches-parallel-connections = 4
  '';
  nix.nixPath = [ "nixpkgs=/etc/nixos/nixpkgs" ];
  environment.etc."nixos/nixpkgs" = {
    source = /etc/nixos/nixpkgs;
  };

  # Increase open file limit to avoid running out of file descriptors when
  # deploying NixOS
  systemd.extraConfig = "DefaultLimitNOFILE=1048576";
}
