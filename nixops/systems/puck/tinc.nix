{ config, lib, pkgs, ... }:

{
  environment.etc."tinc/omnimesh/tinc-up".source = pkgs.writeScript "tinc-up" ''
    #!${pkgs.stdenv.shell}
    export PATH=${lib.makeBinPath [ pkgs.iproute ]}

    ip link set up $INTERFACE || true
    ip addr add dev $INTERFACE 10.99.0.3/24
  '';
}
