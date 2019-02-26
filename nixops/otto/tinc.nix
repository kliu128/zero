{ config, lib, pkgs, ... }:

{
  networking.interfaces."tinc.omnimesh".ipv4.addresses = [ { address = "10.0.0.2";prefixLength = 24; } ];
  deployment.keys."ed25519_key.priv" = {
    permissions = "400";
    destDir = "/etc/tinc/omnimesh";
    keyFile = ../secrets/tinc/otto/ed25519_key.priv;
    user = "tinc.omnimesh";
  };
  deployment.keys."rsa_key.priv" = {
    permissions = "400";
    destDir = "/etc/tinc/omnimesh";
    keyFile = ../secrets/tinc/otto/rsa_key.priv;
    user = "tinc.omnimesh";
  };
}