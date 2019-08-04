{ config, lib, pkgs, ... }:

{
  environment.etc."nixos/nixpkgs".enable = false;
  nix.maxJobs = lib.mkDefault 8;
}
