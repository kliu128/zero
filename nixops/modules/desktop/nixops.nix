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
        rev = "e795b963f626162221ccccee9464a3a973a94e98";
        sha256 = "1zd5c7mkx1s0fd0a5q7hsmp7p7a69nknxza0941in1py3lcv5pz9";
      };

      postInstall = ''
        mkdir -p $out/share/nix/nixops
        cp -av "nix/"* $out/share/nix/nixops
      '';
    });
  };

  environment.systemPackages = [ pkgs.nixops ];
}