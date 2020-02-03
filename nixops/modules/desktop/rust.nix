{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    direnv
  ];
  home-manager.users.kevin.programs.zsh.initExtra = ''
    eval "$(direnv hook zsh)"
  '';
}
