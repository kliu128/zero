{ config, lib, pkgs, ... }:

{
  # Blu-ray/disk system tools
  environment.systemPackages = with pkgs; [ k3b makemkv ];
  boot.kernelModules = [ "sg" ];
}
