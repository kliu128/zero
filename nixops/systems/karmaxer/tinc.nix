{ config, lib, pkgs, ... }:

{
  environment.etc."tinc/omnimesh/tinc-up".source = pkgs.writeScript "tinc-up-private" ''
    #!${pkgs.stdenv.shell}
    export PATH=${lib.makeBinPath [ pkgs.iproute pkgs.iptables ]}
    ip link set up tinc.omnimesh || true
    ip addr add dev tinc.omnimesh 10.99.0.5/24
  '';
}