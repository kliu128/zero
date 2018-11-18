{ config, lib, pkgs, ... }:

{
  nix.nixPath = [ "nixpkgs=/etc/nixos/nixpkgs" "nixos-config=/etc/nixos/configuration.nix" ];
  nix.maxJobs = lib.mkDefault 8;
}
