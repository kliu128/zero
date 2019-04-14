{ config, lib, pkgs, ... }:

{
  # Audio
  hardware.pulseaudio = {
    enable = true;
    extraConfig = ''
      load-module module-remap-sink master=alsa_output.usb-Corsair_Corsair_VOID_PRO_Wireless_Gaming_Headset-00.iec958-stereo sink_name=mono channels=2 channel_map=mono,mono
    '';
    package = pkgs.pulseaudioFull;
    extraModules = [ pkgs.pulseaudio-modules-bt ];
  };
  hardware.bluetooth.enable = true;
}