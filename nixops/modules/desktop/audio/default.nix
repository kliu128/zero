{ config, lib, pkgs, ... }:

{
  # Audio
  hardware.pulseaudio = {
    enable = true;
    extraConfig = ''
      load-module module-dbus-protocol
      load-module module-tunnel-sink-new server=192.168.1.197
    '';
    package = pkgs.pulseaudioFull;
    extraModules = [ pkgs.pulseaudio-modules-bt ];
  };
  hardware.bluetooth = {
    enable = true;
    package = pkgs.bluezFull;
  };
}