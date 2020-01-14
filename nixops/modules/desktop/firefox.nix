{ config, lib, pkgs, ... }:

{
  nixpkgs.overlays = [
    (import ./nixpkgs-mozilla)
  ];
  environment.systemPackages = with pkgs; [
    firefox
  ];

  environment.variables = {
    MOZ_USE_XINPUT2 = "1";
  };
}
