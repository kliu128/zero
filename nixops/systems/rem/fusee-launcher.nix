{ config, lib, fetchurl, pkgs, ... }:

{
  services.udev.extraRules = ''
    ACTION=="add", ENV{ID_BUS}=="usb", ENV{ID_VENDOR_ID}=="0955", ENV{ID_MODEL_ID}=="7321", RUN+="${pkgs.fusee-launcher}/bin/fusee-launcher -w ${../../hekate_ctcaer_5.2.1.bin}"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="057e", ATTRS{idProduct}=="3000", MODE="0666"
  '';
}
