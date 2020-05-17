{ config, lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    nodejs-10_x yarn python2 binutils
  ];
  home-manager.users.kevin.programs.zsh.initExtra = ''
    export PATH="$(yarn global bin):$PATH"
  '';

  boot.kernel.sysctl."fs.inotify.max_user_watches" = 2097152;
}