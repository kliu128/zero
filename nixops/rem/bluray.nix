{ config, lib, pkgs, ... }:

{
  # Blu-ray/disk system tools
  environment.systemPackages = with pkgs; [
    # Ripping
    k3b makemkv dvdisaster rubyripper flac
  ];
  home-manager.users.kevin.home.file.".local/bin/ripper" = {
    executable = true;
    source = ./ripper.py;
  };

  users.extraUsers.kevin.extraGroups = [ "cdrom" ];

  boot.kernel.sysctl."dev.cdrom.autoclose" = 0; # Stop CD drive from double-closing

  boot.kernelModules = [ "sg" ]; # for MakeMKV

  # Enable blu-ray support in vlc/etc.
  # libbluray does not support any decryption by default in nixpkgs (see 
  # https://github.com/NixOS/nixpkgs/blob/master/pkgs/development/libraries/libbluray/default.nix)
  #nixpkgs.config.packageOverrides = pkgs: rec {
  #  libbluray = pkgs.libbluray.override {
  #    withJava = true;
  #    withAACS = true;
  #    withBDplus = true;
  #  };
  #};
}
