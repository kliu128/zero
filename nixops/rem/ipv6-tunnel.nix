{ config, lib, pkgs, ... }:

{
  systemd.services.ipv6-tunnel = {
    description = "Hurricane Electric IPv6 Tunneling";
    enable = false;
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    path = [ pkgs.iproute ];
    script = ''
      ip tunnel add he-ipv6 mode sit remote 209.51.161.14 local 192.168.1.5 ttl 255
      ip link set he-ipv6 up
      ip addr add 2001:470:1f06:1b1::2/64 dev he-ipv6
      ip -6 route add ::/0 dev he-ipv6
    '';
    preStop = ''
      ip -6 route del ::/0 dev he-ipv6
      ip link set he-ipv6 down
      ip tunnel del he-ipv6
    '';
  };

  networking.interfaces.eth0.ipv6.addresses = [ {
    address = "2001:470:8990::dead:beef"; prefixLength = 48; } ];
}