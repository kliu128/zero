{ config, lib, pkgs, ... }:

{
  networking.useDHCP = false;
  # Bridge configuration for libvirt
  networking.interfaces.br0.useDHCP = true;
  networking.bridges.br0.interfaces = [ "enp2s0f0" ];
  networking.interfaces.br0.macAddress = "78:e7:d1:7b:d4:b2";
}