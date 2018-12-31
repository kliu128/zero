{ config, lib, pkgs, ... }:

{
  # Blu-ray/disk system tools
  environment.systemPackages = with pkgs; [
    # Ripping
    k3b makemkv dvdisaster rubyripper flac
  ];

  boot.kernelModules = [ "sg" ]; # for MakeMKV

  # Enable blu-ray support in vlc/etc.
  nixpkgs.config.packageOverrides = pkgs: rec {
    libbluray = pkgs.libbluray.override { withAACS = true; };
  };
}
