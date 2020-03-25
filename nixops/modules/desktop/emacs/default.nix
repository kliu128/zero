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
        rev = "d46eacd83842815b24afcb2e1fee5c80c38187c5";
        sha256 = "1r8q7bnszkrxh4q9l78n6xgxflpc52hcd18d3n9kc5r8xma20387";
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