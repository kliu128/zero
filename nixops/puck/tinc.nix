{ config, lib, pkgs, ... }:

{
  networking.interfaces."tinc.omnimesh".ipv4.addresses = [ { address = "10.0.0.3";prefixLength = 24; } ];
}