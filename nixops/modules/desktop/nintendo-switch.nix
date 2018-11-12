{ config, lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    helmfile kubectl kubernetes-helm
  ];
  home-manager.users.kevin.home.file.".local/bin/cfw-loader" = {
    executable = true;
    text = ''
      #!${pkgs.bash}/bin/bash
      exec ${pkgs.chromium}/bin/chromium --app=https://elijahzawesome.github.io/web-cfw-loader/
    '';
  };
}