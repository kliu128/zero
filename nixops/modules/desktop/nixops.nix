{ config, lib, pkgs, ... }:

with import <nixpkgs> {};
with lib;

{
  # use latest version of nixops from master because nixpkgs doesn't build with
  # nixops 1.6
  nixpkgs.config.packageOverrides = pkgs: rec {
    nixops = pkgs.nixops.overrideAttrs (oldAttrs: rec {
      src = fetchFromGitHub {
        owner = "NixOS";
        repo = "nixops";
        rev = "8ed39f9cadddd1d35a67096d0109151ae6ddc8b5";
        sha256 = "1ninymk1jcvh3b1q0wgnmiya95rx8rdf9pw4hw3kffbg1izzp91c";
      };

      postInstall = ''
        mkdir -p $out/share/nix/nixops
        cp -av "nix/"* $out/share/nix/nixops
      '';
    });
  };

  environment.systemPackages = [ pkgs.nixops ];
}