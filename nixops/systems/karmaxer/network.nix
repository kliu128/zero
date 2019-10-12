{ config, lib, pkgs, ... }:

{
  networking.useDHCP = false;
  networking.interfaces.enp2s0f0.useDHCP = true;
}