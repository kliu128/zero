{ config, lib, pkgs, ... }:

with import <nixpkgs> {};
with lib;

{
  environment.systemPackages = with pkgs; [ emacs ];
  home-manager.users.kevin = {
    # Emacs
    home.file.".spacemacs".text = builtins.readFile ./.spacemacs;
    home.file.".emacs.d" = {
      source = fetchFromGitHub {
        owner = "syl20bnr";
        repo = "spacemacs";
        rev = "504fd6c1206239391f5c46ab1740088c0beac159";
        sha256 = "0c77j56qkf0rf8d8877k38c9hqmzdhq34papgir4z5vay6sqnfl6";
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