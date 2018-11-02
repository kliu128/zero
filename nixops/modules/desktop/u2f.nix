{ config, lib, pkgs, ... }:
{
  # U2F
  hardware.u2f.enable = true;
  services.pcscd.enable = true;

  environment.systemPackages = with pkgs; [
    # U2F
    yubikey-personalization-gui yubikey-manager
  ];
  services.udev.packages = [ pkgs.yubikey-personalization-gui ];
}