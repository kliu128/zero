{ config, lib, pkgs, ... }:

with import <nixpkgs> {};
with lib;

{
  home-manager.users.kevin = {
    # Emacs
    home.file.".spacemacs".text = builtins.readFile ./.spacemacs;
    home.file.".emacs.d" = {
      source = fetchFromGitHub {
        owner = "syl20bnr";
        repo = "spacemacs";
        rev = "69a89cc41243cfb189238a2297fde4498d7fcf6d";
        sha256 = "0mpv5wf55qqc305wgf98as2yk5i9f9h7wcgns066zm5fkm40lqak";
      };
      recursive = true;
    };
    home.file.".emacs.d/layers/+emacs/orgwiki" = {
      source = ./orgwiki;
      recursive = true;
    };
    home.file.".spacemacs.d/next-spec-day.el".text = builtins.readFile ./next-spec-day.el;
  };
}