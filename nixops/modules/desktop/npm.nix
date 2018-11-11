{ config, lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    nodejs-10_x # includes npm
  ];
  home-manager.users.kevin.programs.zsh.initExtra = ''
    export PATH=~/.npm-global/bin:$PATH
  '';
  home-manager.users.kevin.home.file.".npmrc".text = ''
    prefix=~/.npm-global
  '';
}