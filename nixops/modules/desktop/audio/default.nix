{ config, lib, pkgs, ... }:

{
  # Audio
  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
  };
  hardware.bluetooth = {
    enable = true;
    package = pkgs.bluezFull;
  };
}