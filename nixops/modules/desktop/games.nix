{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Games
    dolphinEmuMaster factorio multimc steam steam-run-native
    # Wine
    wineWowPackages.staging winetricks samba # for ntlm_auth
  ];

  hardware.opengl.driSupport32Bit = true; # for steam and wine

  # Set limits for esync.
  # see https://github.com/NixOS/nixpkgs/issues/45492
  systemd.extraConfig = "DefaultLimitNOFILE=1048576";

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