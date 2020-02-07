{ config, lib, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.nixopsUnstable ];
  
  programs.zsh.interactiveShellInit = ''
    nixup() {
      ssh -t rem nixops deploy -d zero --include $(hostname)
    }
  '';
}