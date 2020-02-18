{ config, lib, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.nixopsUnstable ];
  
  programs.zsh.interactiveShellInit = ''
    nixup() {
      ssh -t rem env NIX_PATH=nixpkgs=/etc/nixos/nixpkgs nixops deploy -d zero --include $(hostname)
    }
  '';
}