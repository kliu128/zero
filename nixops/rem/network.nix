{ config, lib, pkgs, ... }:

{
  networking.useNetworkd = true;
  networking.useDHCP = true;
  systemd.network.networks."40-br0".linkConfig.MACAddress = "74:d4:35:e2:52:9b";
  systemd.network.networks."40-br0".networkConfig.DHCP = lib.mkForce "ipv4";
  systemd.network.enable = true;
  systemd.network.networks."99-main".enable = false;

  systemd.services.ipv6-tunnel = {
    description = "Hurricane Electric IPv6 Tunneling";
    enable = true;
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

  networking.interfaces.br0.ipv6.addresses = [ {
    address = "2001:470:8990::dead:beef"; prefixLength = 48; } ];
  # Fix failing network upon big NixOS updates
  systemd.services.systemd-networkd.restartIfChanged = false;
  systemd.services.systemd-resolved.restartIfChanged = false;
  systemd.services.unbound.restartIfChanged = false;
}