{ config, lib, pkgs, ... }:

{
  # Audio
  hardware.pulseaudio = {
    enable = true;
    extraConfig = ''
      load-module module-dbus-protocol
    '';
    package = pkgs.pulseaudioFull;
    extraModules = [ pkgs.pulseaudio-modules-bt ];
  };
  hardware.bluetooth = {
    enable = true;
    package = pkgs.bluezFull;
  };
}