{ config, lib, pkgs, ... }:

{
  # Blu-ray/disk system tools
  environment.systemPackages = with pkgs; [ k3b makemkv dvdisaster rubyripper flac ];
  boot.kernelModules = [ "sg" ]; # for MakeMKV
}
