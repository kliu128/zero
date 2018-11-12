{ config, lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    helmfile kubectl kubernetes-helm
  ];
  home-manager.users.kevin.programs.zsh.initExtra = ''
    alias kwatch='watch kubectl logs --tail 20'
  '';
}