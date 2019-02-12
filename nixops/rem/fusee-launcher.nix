{ config, lib, pkgs, ... }:

{
  home-manager.users.kevin.programs.zsh.initExtra = ''
    fusee() {
      ${pkgs.fusee-launcher}/bin/fusee-launcher -w ${../hekate_ctcaer_4.6.bin}
    }
  '';
}
