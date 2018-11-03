{ config, lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    trash-cli
  ];
  home-manager.users.kevin.programs.zsh.initExtra = ''
    alias rm=trash
  '';
}