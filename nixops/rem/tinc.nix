{ config, lib, pkgs, ... }:

{
  environment.etc."tinc/omnimesh/tinc-up".source = pkgs.writeScript "tinc-up-private" ''
    #!${pkgs.stdenv.shell}
    ${pkgs.iproute}/bin/ip link set up tinc.omnimesh || true
    ${pkgs.iproute}/bin/ip addr add dev tinc.omnimesh 10.99.0.1/24
  '';
}