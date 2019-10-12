{ config, lib, pkgs, ... }:

{
  nix.nixPath = [ "nixpkgs=/etc/nixos/nixpkgs" ];
  nix.maxJobs = 14;
}
