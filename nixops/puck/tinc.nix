{ config, lib, pkgs, ... }:

{
  environment.etc."tinc/omnimesh/tinc-up".source = pkgs.writeScript "tinc-up" ''
    #!${pkgs.stdenv.shell}
    export PATH=${lib.makeBinPath [ pkgs.iproute ]}

    ip link set up $INTERFACE || true
    ip addr add dev $INTERFACE 10.99.0.3/24
  '';

  security.sudo.extraConfig = ''
    tinc.omnimesh ALL=(ALL) NOPASSWD: ${pkgs.iproute}/bin/ip
  '';

  environment.etc."tinc/omnimesh/hosts/rem-up".source = pkgs.writeScript "rem-up" ''
    #!${pkgs.stdenv.shell}
    export PATH=${lib.makeBinPath [ pkgs.iproute pkgs.gnugrep pkgs.coreutils ]}:/run/wrappers/bin

    VPN_GATEWAY=10.99.0.1
    ORIGINAL_GATEWAY=`ip route show | grep ^default | cut -d ' ' -f 2-5`

    sudo ip route add $REMOTEADDRESS $ORIGINAL_GATEWAY
    sudo ip route add 0.0.0.0/1 via $VPN_GATEWAY dev $INTERFACE
  '';

  environment.etc."tinc/omnimesh/hosts/rem-down".source = pkgs.writeScript "rem-down" ''
    #!${pkgs.stdenv.shell}
    export PATH=${lib.makeBinPath [ pkgs.iproute pkgs.gnugrep pkgs.coreutils ]}:/run/wrappers/bin

    ORIGINAL_GATEWAY=`ip route show | grep ^default | cut -d ' ' -f 2-5`

    sudo ip route del $REMOTEADDRESS $ORIGINAL_GATEWAY
    sudo ip route del 0.0.0.0/1 dev $INTERFACE
  '';
}