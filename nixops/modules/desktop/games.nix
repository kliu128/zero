{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Games
    lutris multimc steam steam-run-native
    # Wine
    wineWowPackages.unstable winetricks samba # for ntlm_auth
  ];

  hardware.opengl.driSupport32Bit = true; # for steam and wine

  security.pam.loginLimits = [{
    domain = "*";
    type = "hard";
    item = "nofile";
    value = "1048576";
  }];

  # Custom package overrides
  nixpkgs.config.packageOverrides = pkgs: rec {
    winetricks = pkgs.winetricks.override { wine = pkgs.wineWowPackages.unstable; };
    factorio = pkgs.factorio.override {
      username = "Pneumaticat";
      token = builtins.readFile ../../secrets/factorio-token.txt;
    };
  };
}
