{ config, lib, pkgs, ... }:

{
  networking.interfaces."tinc.omnimesh".ipv4.addresses = [ { address = "10.0.0.2";prefixLength = 24; } ];
}