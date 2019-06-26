{ config, lib, fetchurl, pkgs, ... }:

{
  services.udev.extraRules = ''
    ACTION=="add", ENV{ID_BUS}=="usb", ENV{ID_VENDOR_ID}=="0955", ENV{ID_MODEL_ID}=="7321", RUN+="${pkgs.fusee-launcher}/bin/fusee-launcher -w ${../hekate_ctcaer_4.6.bin}"
    ACTION=="add", ENV{ID_BUS}=="usb", ENV{ID_VENDOR_ID}=="057e", MODE="0666"
  '';
}
