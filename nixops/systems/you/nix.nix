{ config, lib, pkgs, ... }:

let
  # This will point to whatever NIX_PATH states on the local machine,
  # unless overwritten with -I.
  hostNixpkgs = <nixpkgs>;
in {
  nix.nixPath = [
    "nixpkgs=/etc/nixos/nixpkgs"
  ];

  environment.etc."nixos/nixpkgs".source = hostNixpkgs;
}
